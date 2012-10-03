%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function shadowFeatures = computeShadowLineFeatures(img, varargin)
%  Computes the shadow features for each detected shadow line
%
% Input parameters:
%  - img: input image
%
% Output parameters:
%  - shadowFeatures: features
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function shadowFeatures = computeShadowBoundaryFilterFeatures(img, boundaries, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2010 Jean-Francois Lalonde
% Carnegie Mellon University
% Consult the LICENSE.txt file for licensing information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% parse arguments
defaultArgs = struct('EdgeOrientations', [], 'GrayImg', [], 'NbScales', 1);
args = parseargs(defaultArgs, varargin{:});

nbChannels = size(img, 3);

% initial value for sigma
sigma = 1;
support = 2;

boundariesCat = cat(1, boundaries{:});

%% Compute features on edges
if isempty(args.EdgeOrientations)
    [gX,gY] = gradient(conv2(args.GrayImg, fspecial('gaussian', 7, 1.5), 'same'));
    
    % find gradient orientation by interpolation the pixel gradients
    gXCat = interp2(1:size(gX,2), 1:size(gX,1), gX, min(boundariesCat(:,1), size(gX,2)), min(boundariesCat(:,2), size(gX,1)), '*linear');
    gYCat = interp2(1:size(gY,2), 1:size(gY,1), gY, min(boundariesCat(:,1), size(gY,2)), min(boundariesCat(:,2), size(gY,1)), '*linear');
    
    gTheta = atan2(gYCat, gXCat);
else
    % add pi/2 because we want to align filters to the *gradients* (and not edge orientations)
    gTheta = args.EdgeOrientations;
end

% create filter bank of "half-filters" at multiple orientations
nbOrientations = 12;
filterOrientations = linspace(0, pi, nbOrientations+1);
filterOrientations = filterOrientations(1:end-1);

% find nearest orientation for each edge
angleDiff = min(mod(repmat(gTheta, 1, nbOrientations) - repmat(filterOrientations(:)', size(boundariesCat,1), 1), 2*pi), ...
    mod(repmat(gTheta, 1, nbOrientations) - repmat(filterOrientations(:)'+pi, size(boundariesCat,1), 1), 2*pi));

[m,mind] = min(angleDiff, [], 2);

meanRightInt = zeros(size(boundariesCat, 1), nbChannels, args.NbScales);
meanLeftInt = zeros(size(boundariesCat, 1), nbChannels, args.NbScales);

for s=1:args.NbScales
    % build the filter bank at the current scale
    fb = buildShadowFeaturesFilterBank(filterOrientations, sigma, support, 'UsePixelBoundaries', 0);
    sigma = sigma*2;
        
    % run the filter bank on the image
    for c=1:nbChannels
        filterResponses = cellfun(@(x) filter2(x, img(:,:,c), 'same'), fb, 'UniformOutput', 0);
        filterResponses = cell2mat(permute(filterResponses, [3 4 1 2]));
        
        meanRightInt(:,c,s) = filterResponses(sub2ind(size(filterResponses), boundariesCat(:,2)-0.5, boundariesCat(:,1)-0.5, mind, ones(size(boundariesCat,1),1)));
        meanLeftInt(:,c,s) = filterResponses(sub2ind(size(filterResponses), boundariesCat(:,2)-0.5, boundariesCat(:,1)-0.5, mind, 2.*ones(size(boundariesCat,1),1)));
    end
end

%% Find darker color
[m,mind] = min(cat(4, meanLeftInt, meanRightInt), [], 4);
% scales vote for their preferred side
indMinRight = sum(sum(mind-1,2)>1,3)>args.NbScales/2;

shadowFeatures.minInt = meanLeftInt;
shadowFeatures.minInt(indMinRight,:,:) = meanRightInt(indMinRight,:,:);

shadowFeatures.maxInt = meanRightInt;
shadowFeatures.maxInt(indMinRight,:,:) = meanLeftInt(indMinRight,:,:);


