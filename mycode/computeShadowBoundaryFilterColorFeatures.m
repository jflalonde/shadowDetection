%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function feats = computeShadowBoundaryFilterColorFeatures(img, intImg, featName, boundaries, varargin)
%  Compute boundary features on input image (in whatever color space)
%
% Input parameters:
%  - img: input image
%  - intImg: input image in intensity (grayscale) space
%  - featName: name of the color space that we want
%  - boundaries: image boundaries
%
% Output parameters:
%  - feats: filter features for the given color space
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function feats = computeShadowBoundaryFilterColorFeatures(img, intImg, featName, boundaries, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2010 Jean-Francois Lalonde
% Carnegie Mellon University
% Consult the LICENSE.txt file for licensing information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

defaultArgs = struct('Verbose', 0, 'NbScales', 1, ...
    'NormalizeEdges', 0, 'UseBoundaryOrientations', 0, 'BoundaryOrientations', []);
args = parseargs(defaultArgs, varargin{:});

featBndOrientName = sprintf('%sBndOrient', featName);

boundariesLength = cellfun(@(x) length(x), boundaries);
boundariesCumsum = [0 cumsum(boundariesLength)];
boundariesLineInd = arrayfun(@(i) boundariesCumsum(i)+1:boundariesCumsum(i+1), 1:(length(boundariesCumsum)-1), 'UniformOutput', 0);

%% Boundary orientations
if args.UseBoundaryOrientations
    % build matrix of orientations
    error('fix me for sub-pixel boundary representation');

    edgeOrientations = zeros(size(img,1), size(img,2));
    for j=1:length(boundaries)
        edgeOrientations(boundaryInd(boundaryLineInd{j})) = args.BoundaryOrientations(j);
    end
    
    % use boundary indices to compute orientations
    edgeImg = ones(size(img,1), size(img,2));
    allEdgeBndOrientFeatures = computeShadowBoundaryFilterFeatures(img, 'DoEdges', 1, 'DoFilters', 1, 'Edges', edgeImg, 'EdgeOrientations', edgeOrientations, 'GrayImg', intImg, 'NbScales', args.NbScales);
    
    feats.(featBndOrientName).minInt = cell2mat(cellfun(@(x) mean(allEdgeBndOrientFeatures.minInt(boundaryInd(x), :, :), 1), boundaryLineInd, 'UniformOutput', 0)');
    feats.(featBndOrientName).maxInt = cell2mat(cellfun(@(x) mean(allEdgeBndOrientFeatures.maxInt(boundaryInd(x), :, :), 1), boundaryLineInd, 'UniformOutput', 0)');
end

%% Compute filter-based features
allEdgeFeatures = computeShadowBoundaryFilterFeatures(img, boundaries, 'GrayImg', intImg, 'NbScales', args.NbScales);

% Build features for each boundary line: mean filter response for all points on that boundary
feats.(featName).minInt = cell2mat(cellfun(@(x) mean(allEdgeFeatures.minInt(x, :, :), 1), boundariesLineInd, 'UniformOutput', 0)');
feats.(featName).maxInt = cell2mat(cellfun(@(x) mean(allEdgeFeatures.maxInt(x, :, :), 1), boundariesLineInd, 'UniformOutput', 0)');

%% Normalize?
if args.NormalizeEdges
    allEdgeFeatures = normalizeEdges(intImg, boundaries, boundariesLineInd, allEdgeFeatures);
    
    feats.(featName).minIntNorm = cell2mat(cellfun(@(x) mean(allEdgeFeatures.minInt(x, :, :), 1), boundariesLineInd, 'UniformOutput', 0)');
    feats.(featName).maxIntNorm = cell2mat(cellfun(@(x) mean(allEdgeFeatures.maxInt(x, :, :), 1), boundariesLineInd, 'UniformOutput', 0)');
    
    if args.UseBoundaryOrientations
        allEdgeBndOrientFeatures = normalizeEdges(intImg, boundaries, boundariesLineInd, allEdgeBndOrientFeatures);
        feats.(featBndOrientName).minIntNorm = cell2mat(cellfun(@(x) mean(allEdgeBndOrientFeatures.minInt(x, :, :), 1), boundariesLineInd, 'UniformOutput', 0)');
        feats.(featBndOrientName).maxIntNorm = cell2mat(cellfun(@(x) mean(allEdgeBndOrientFeatures.maxInt(x, :, :), 1), boundariesLineInd, 'UniformOutput', 0)');
    end
end

%% Reshape for scales
if args.NbScales > 1
    
    [r,c,d] = size(feats.(featName).minInt);
    feats.(featName).minInt = reshape(feats.(featName).minInt, [r, c*d]);
    feats.(featName).maxInt = reshape(feats.(featName).maxInt, [r, c*d]);
    
    if args.NormalizeEdges
        feats.(featName).minIntNorm = reshape(feats.(featName).minIntNorm, [r, c*d]);
        feats.(featName).maxIntNorm = reshape(feats.(featName).maxIntNorm, [r, c*d]);
    end
    
    if args.UseBoundaryOrientations
        feats.(featBndOrientName).minInt = reshape(feats.(featBndOrientName).minInt, [r, c*d]);
        feats.(featBndOrientName).maxInt = reshape(feats.(featBndOrientName).maxInt, [r, c*d]);
        
        if args.NormalizeEdges
            feats.(featBndOrientName).minIntNorm = reshape(feats.(featBndOrientName).minIntNorm, [r, c*d]);
            feats.(featBndOrientName).maxIntNorm = reshape(feats.(featBndOrientName).maxIntNorm, [r, c*d]);
        end
    end
end
