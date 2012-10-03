%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function shadowFeatures = computeShadowBoundaryTextonFeatures(img, univTextons, filterBank, boundaries, varargin)
%  Computes texton-based features on the boundaries of the image
%
% Input parameters:
%  - img: input image
%  - univTextons: texton dictionnary
%  - filterBank: filter bank used to compute the textons
%  - boundaries: image boundaries
%
% Output parameters:
%  - shadowFeatures: texton features
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function shadowFeatures = computeShadowBoundaryTextonFeatures(img, univTextons, filterBank, boundaries, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2010 Jean-Francois Lalonde
% Carnegie Mellon University
% Consult the LICENSE.txt file for licensing information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% parse arguments
defaultArgs = struct('NbScales', 1, 'ScaleInit', 1);
args = parseargs(defaultArgs, varargin{:});

%% Compute filtered image
imgGray = rgb2gray(img);
filteredImg = cellfun(@(x) filter2(x, imgGray, 'same'), filterBank, 'UniformOutput', 0);

filteredImg = cell2mat(permute(filteredImg(:), [3 2 1]));
filteredImg = reshape(filteredImg, size(filteredImg,1)*size(filteredImg,2), size(filteredImg,3));

% find nearest neighbors for each pixel, and assign its index
textonMap = BruteSearchMex(univTextons, filteredImg');
textonMap = reshape(textonMap, size(img,1), size(img,2));

%%
boundariesCat = cat(1, boundaries{:});
[gX,gY] = gradient(conv2(imgGray, fspecial('gaussian', 7, 1.5), 'same'));

% find gradient orientation by interpolation the pixel gradients
gXCat = interp2(1:size(gX,2), 1:size(gX,1), gX, min(boundariesCat(:,1), size(gX,2)), min(boundariesCat(:,2), size(gX,1)), '*linear');
gYCat = interp2(1:size(gY,2), 1:size(gY,1), gY, min(boundariesCat(:,1), size(gY,2)), min(boundariesCat(:,2), size(gY,1)), '*linear');

gTheta = atan2(gYCat, gXCat);

% create filter bank of "half-filters" at multiple orientations
nbOrientations = 12;
filterOrientations = linspace(0, pi, nbOrientations+1);
filterOrientations = filterOrientations(1:end-1);

angleDiff = min(mod(repmat(gTheta, 1, nbOrientations) - repmat(filterOrientations(:)', size(boundariesCat,1), 1), 2*pi), ...
    mod(repmat(gTheta, 1, nbOrientations) - repmat(filterOrientations(:)'+pi, size(boundariesCat,1), 1), 2*pi));

[m,mind] = min(angleDiff, [], 2);

%% Loop over scales
texHistDist = zeros(size(boundariesCat,1), args.NbScales);
skewDist = zeros(size(boundariesCat,1), args.NbScales);
scales = 2.^(args.ScaleInit:(args.ScaleInit+args.NbScales-1));

for s=1:args.NbScales
    fb = buildTextureFeaturesFilterBank(filterOrientations, scales(s), 'UsePixelBoundaries', 0);
    
    % compute row and column transformations (from center)
    [fbR, fbC] = cellfun(@(x) ind2sub(size(x), find(x)), fb, 'UniformOutput', 0);
    
    % normalize wrt filter
    centerR = ceil(size(fb{1}, 1)/2);
    centerC = ceil(size(fb{1}, 2)/2);
    
    fbR = cellfun(@(r) r-centerR-0.5, fbR, 'UniformOutput', 0);
    fbC = cellfun(@(c) c-centerC-0.5, fbC, 'UniformOutput', 0);
    
%     [rB,cB] = ind2sub([size(img,1) size(img,2)], boundaryInd);
    
    %% Compute features
    [nbImgR, nbImgC, c] = size(img);
    histBins = 1:size(univTextons, 2);
    for i=1:size(boundariesCat,1)
        % compute indices on the right
        bR = min(max(fbR{mind(i),1} + boundariesCat(i,2), 1), nbImgR);
        bC = min(max(fbC{mind(i),1} + boundariesCat(i,1), 1), nbImgC);
        
        bIndRight = unique(sub2ind([nbImgR nbImgC], bR, bC));
        
        % compute indices on the left
        bR = min(max(fbR{mind(i),2} + boundariesCat(i,2), 1), nbImgR);
        bC = min(max(fbC{mind(i),2} + boundariesCat(i,1), 1), nbImgC);
        
        bIndLeft = unique(sub2ind([nbImgR nbImgC], bR, bC));
        
        % histogram textons (or filter responses) on both sides, compute distances
        %     histDist = cellfun(@(f) chisq(histc(f(bIndRight), histBins), histc(f(bIndLeft), histBins)), filteredImg);
        texHistDist(i,s) = chisq(histc(textonMap(bIndRight), histBins), histc(textonMap(bIndLeft), histBins));
        
        % [Zhu et al. CVPR'10] also suggest computing the skewness
        if numel(bIndRight) > 1 && numel(bIndLeft) > 1
            skewRight = skewness(imgGray(bIndRight));
            skewLeft = skewness(imgGray(bIndLeft));
            
            skewDist(i,s) = max(skewRight-skewLeft, skewLeft-skewRight);
        end
    end
end

%% Mean over all boundary
boundariesLength = cellfun(@(x) length(x), boundaries);
boundariesCumsum = [0 cumsum(boundariesLength)];
boundariesLineInd = arrayfun(@(i) boundariesCumsum(i)+1:boundariesCumsum(i+1), 1:(length(boundariesCumsum)-1), 'UniformOutput', 0);

shadowFeatures.Textons.histDist = cell2mat(cellfun(@(x) mean(texHistDist(x, :), 1), boundariesLineInd, 'UniformOutput', 0)');
shadowFeatures.Textons.skewDist = cell2mat(cellfun(@(x) mean(skewDist(x, :), 1), boundariesLineInd, 'UniformOutput', 0)');
