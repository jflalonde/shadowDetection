%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function edgePot = computeBoundaryEdgePotentials(boundaries, junction2BoundaryInd, varargin)
%  Computes pairwise potentials for the CRF.
%
% Input parameters:
%  - boundaries: image boundaries
%  - junction2BoundaryInd: mapping between junctions and boundaries
%
% Output parameters:
%  - edgePot: pairwise potentials (in sparse matrix form)
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function edgePot = computeBoundaryEdgePotentials(boundaries, junction2BoundaryInd, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2010 Jean-Francois Lalonde
% Carnegie Mellon University
% Consult the LICENSE.txt file for licensing information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Parse arguments
defaultArgs = struct('UseBndFeatures', 0, 'BndFeatures', [], ...
    'UseSegFeatures', 0, 'SegFeatures', [], 'BndToSegId', [], ...
    'Sigma', 0.5);
args = parseargs(defaultArgs, varargin{:});

%% Compute graph indices

junctionDegree = cellfun(@(j) length(j), junction2BoundaryInd);
bndNeighbors2Sub = cat(1, junction2BoundaryInd{junctionDegree==2});

junction3BoundaryIndVec = cat(1, junction2BoundaryInd{junctionDegree==3});
bndNeighbors3Sub = arrayfun(@(i) reshape(junction3BoundaryIndVec(i,[1 2 1 3 2 3])', 2, 3)', 1:size(junction3BoundaryIndVec,1), 'UniformOutput', 0);
bndNeighbors3Sub = cat(1, bndNeighbors3Sub{:});

junction4BoundaryIndVec = cat(1, junction2BoundaryInd{junctionDegree==4});
bndNeighbors4Sub = arrayfun(@(i) reshape(junction4BoundaryIndVec(i,[1 2 1 3 1 4 2 3 2 4 3 4])', 2, 6)', 1:size(junction4BoundaryIndVec,1), 'UniformOutput', 0);
bndNeighbors4Sub = cat(1, bndNeighbors4Sub{:});
bndNeighborsSub = unique(cat(1, bndNeighbors2Sub, bndNeighbors3Sub, bndNeighbors4Sub), 'rows');

%% Use ratios (computed from segments) to capture similarity
if args.UseSegFeatures
%     b1=cellfun(@(x) x(1), boundaryLineInd);
    segNeighborsSub = cat(1, args.BndToSegId{:});

    catSegMean = cat(3, args.SegFeatures(segNeighborsSub(:,1), :), args.SegFeatures(segNeighborsSub(:,2), :));
    catSegMag = sum(catSegMean.^2, 2);
    [m,mind] = max(catSegMag, [], 3);
    
    maxInd = sub2ind(size(catSegMean), repmat((1:size(catSegMean))', 1, size(catSegMean,2)), repmat(1:size(catSegMean,2), size(catSegMean,1), 1), repmat(mind, 1, size(catSegMean,2)));
    minInd = sub2ind(size(catSegMean), repmat((1:size(catSegMean))', 1, size(catSegMean,2)), repmat(1:size(catSegMean,2), size(catSegMean,1), 1), repmat(mod(mind,2)+1, 1, size(catSegMean,2)));
    
    % make sure the max is non zero
    catSegMeanMax = max(catSegMean(maxInd), 1/255);
    segRatio = catSegMean(minInd)./catSegMeanMax;
    
    spDistSq = sum((segRatio(bndNeighborsSub(:,1),:) - segRatio(bndNeighborsSub(:,2),:)).^2, 2);
    beta = args.Sigma./(mean(spDistSq));
    edgePotLin = exp(-beta.*spDistSq);
end

%% Use ratios to compute similarity
if args.UseBndFeatures
    error('implement me!');
    spDistSq = sum((args.BndFeatures(bndNeighborsSub(:,1),:) - args.BndFeatures(bndNeighborsSub(:,2),:)).^2, 2);
    beta = args.Sigma./(2*mean(spDistSq));
    edgePotLin = exp(-beta.*spDistSq);
end

%% Reshape in sparse matrix form
edgePot = sparse(length(boundaries), length(boundaries));

segNeighborsInd = sub2ind(size(edgePot), bndNeighborsSub(:,1), bndNeighborsSub(:,2));
edgePot(segNeighborsInd) = edgePotLin;

segNeighborsInd = sub2ind(size(edgePot), bndNeighborsSub(:,2), bndNeighborsSub(:,1));
edgePot(segNeighborsInd) = edgePotLin;
