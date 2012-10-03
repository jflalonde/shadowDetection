%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% boundariesInd = getBoundaryIndicesFromEdgesSubPixel(boundaries, edgeImg, varargin)
%  Finds boundaries which overlap an edge map.
% 
% Input parameters:
%  - boundaries: image boundaries
%  - edgeImg: edge map (1=edge, 0=no edge)
%
% Output parameters:
%  - boundariesInd: indices of boundaries which overlap edge map
%   
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function boundariesInd = getBoundaryIndicesFromEdges(boundaries, edgeImg, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2010 Jean-Francois Lalonde
% Carnegie Mellon University
% Consult the LICENSE.txt file for licensing information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Parse arguments
defaultArgs = struct('PctBoundaryLength', 0);
args = parseargs(defaultArgs, varargin{:});

%%
% check if each boundary is close to an edge or not
boundariesCat = cat(1, boundaries{:});

boundariesLength = cellfun(@(x) length(x), boundaries);
boundariesCumsum = [0 cumsum(boundariesLength)];
boundariesLineInd = arrayfun(@(i) boundariesCumsum(i)+1:boundariesCumsum(i+1), 1:(length(boundariesCumsum)-1), 'UniformOutput', 0);

% look at all surrounding pixels: if at least one of them is an edge, we're good!
indStrongBoundaries = edgeImg(sub2ind(size(edgeImg), min(max(boundariesCat(:,2)-0.5, 1), size(edgeImg, 1)), min(max(boundariesCat(:,1)-0.5, 1), size(edgeImg, 2)))) | ...
    edgeImg(sub2ind(size(edgeImg), min(max(boundariesCat(:,2)-0.5, 1), size(edgeImg, 1)), min(max(boundariesCat(:,1)+0.5, 1), size(edgeImg, 2)))) | ...
    edgeImg(sub2ind(size(edgeImg), min(max(boundariesCat(:,2)+0.5, 1), size(edgeImg, 1)), min(max(boundariesCat(:,1)-0.5, 1), size(edgeImg, 2)))) | ...
    edgeImg(sub2ind(size(edgeImg), min(max(boundariesCat(:,2)+0.5, 1), size(edgeImg, 1)), min(max(boundariesCat(:,1)+0.5, 1), size(edgeImg, 2))));

% make sure each boundary overlaps sufficiently
boundariesPctCoverage = cellfun(@(x) nnz(indStrongBoundaries(x))./length(x), boundariesLineInd);
boundariesInd = find(boundariesPctCoverage >= args.PctBoundaryLength)';
% boundariesInd = cat(2, boundariesLineInd{boundariesPctCoverage >= args.PctBoundaryLength});

