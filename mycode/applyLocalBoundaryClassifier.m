%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% boundaryProbabilities = applyLocalBoundaryClassifier(imgInfo, bdtClassifInfo, boundaryFeatures, imageFeatures, boundaryInd, boundaryLineInd, varargin)
%  
% 
% Input parameters:
%  - img: input image
%  - imgInfo: unused, set to []
%  - bdtClassifInfo: classifier structure (loaded from file)
%  - boundaryFeatures: image features computed on boundaries
%  - imageFeatures: global image features (unused)
%  - boundaries: image boundaries
%  - junction2BoundaryInd: mapping from junctions to boundaries
%  - boundary2JunctionInd: mapping from boundaries to junctions
%
% Output parameters:
%  - boundaryProbabilities: probabilities for each strong boundary
%  - indStrongBnd: indices of strong boundaries
%  - allBoundarProbabilities: probabilities for each boundary (0 if not strong)
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [boundaryProbabilities, indStrongBnd, allBoundaryProbabilities] = applyLocalBoundaryClassifier(img, imgInfo, bdtClassifInfo, ...
    boundaryFeatures, imageFeatures, boundaries, junction2BoundaryInd, boundary2JunctionInd, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2010 Jean-Francois Lalonde
% Carnegie Mellon University
% Consult the LICENSE.txt file for licensing information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% Parse arguments
defaultArgs = struct('Verbose', 0, 'IndStrongBnd', [], 'SingleScaleClassifierInfo', []);
args = parseargs(defaultArgs, varargin{:});

if isempty(args.IndStrongBnd)
    % keep strong boundaries
    myfprintf(args.Verbose, 'Finding strong boundaries...');
    imgEdges = zeros(size(img,1), size(img,2));
    sigmas = 2.^(0:3); cannyThresh = 0.3;
    for s=sigmas
        imgEdges = imgEdges + edge(rgb2gray(img), 'canny', cannyThresh, s);
    end
    imgEdges = imdilate(imgEdges>0, strel('disk', 3));
    
    indStrongBnd = getBoundaryIndicesFromEdges(boundaries, imgEdges, 'PctBoundaryLength', 0.75);
else
    indStrongBnd = args.IndStrongBnd;
end

% apply classifier
bdtClassifInfo.multiScale = 0;
boundaryProbabilities = applyClassifier(imgInfo, bdtClassifInfo, indStrongBnd, boundaryFeatures, imageFeatures);

allBoundaryProbabilities = zeros(length(boundaries), 1);
allBoundaryProbabilities(indStrongBnd) = boundaryProbabilities;

myfprintf(args.Verbose, 'done!\n');

%% Useful function: apply classifier on input boundaries
function bndProbabilities = applyClassifier(imgInfo, bdtClassifInfo, bndInd, boundaryFeatures, imageFeatures)

% select features
bndFeats = selectBoundaryFeatures(boundaryFeatures, bndInd, bdtClassifInfo.boundaryFeatSel{:});
imageFeats = selectImageFeatures(imageFeatures, bdtClassifInfo.imageFeatSel{:});

featuresCat = cat(2, bndFeats, repmat(imageFeats, size(bndFeats, 1), 1));

classifIndToUse = 1:(length(bdtClassifInfo.indFolds)-1);

% Run the features through the classifier
if iscell(bdtClassifInfo.classifier)
    bndProbabilities = zeros(size(featuresCat, 1), length(classifIndToUse));
    for c=classifIndToUse
        testConfidences = test_boosted_dt_mc(bdtClassifInfo.classifier{c}, featuresCat);
        bndProbabilities(:, c==classifIndToUse) = 1./(1+exp(-(1).*testConfidences));
    end
    
else
    
    % use input classifier
    bndConfidences = test_boosted_dt_mc(bdtClassifInfo.classifier, featuresCat);
    
    % convert confidences to probabilities
    bndProbabilities = 1./(1+exp(-(1).*bndConfidences));
end

bndProbabilities = median(bndProbabilities, 2);
