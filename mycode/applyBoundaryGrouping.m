%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function boundaryLabels = applyBoundaryGrouping(lambda, sigma, boundaries, junction2BoundaryInd, varargin)
%  Applies CRF to from boundary contours.  
% 
% Input parameters:
%  - lambda: See the paper for details
%  - sigma: This corresponds to beta in the paper
%  - boundaries: image boundaries
%  - junction2BoundaryInd: mapping from junctions to boundaries
%
% Output parameters:
%  - boundaryLabels: optimal labeling (0=shadows, 1=non-shadows)
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function boundaryLabels = applyBoundaryGrouping(lambda, sigma, boundaries, junction2BoundaryInd, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2010 Jean-Francois Lalonde
% Carnegie Mellon University
% Consult the LICENSE.txt file for licensing information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 


%% Parse arguments
defaultArgs = struct('Verbose', 0, ...
    'UseGroundProbability', 0, 'GroundMask', [], ...
    'UseOcclusionProbability', 0, 'OcclusionProb', [], ...
    'UseShadowProbability', 0, 'ShadowProb', [], 'ShadowProbInd', [], ...
    'UseBndFeatures', 0, 'BndFeatures', [], ...
    'UseSegFeatures', 0, 'SegFeatures', [], 'BndToSegId', []);
args = parseargs(defaultArgs, varargin{:});

%% Compute edge potentials
edgePot = computeBoundaryEdgePotentials(boundaries, junction2BoundaryInd, ...
    'UseBndFeatures', args.UseBndFeatures, 'BndFeatures', args.BndFeatures, ...
    'UseSegFeatures', args.UseSegFeatures, 'SegFeatures', args.SegFeatures, 'BndToSegId', args.BndToSegId, ...
    'Sigma', sigma);

%% Compute mean probability for each boundary
if args.UseGroundProbability
    groundProb = imerode(args.GroundMask, strel('disk', 3));
    bndGroundProb = interpBoundarySubPixel(boundaries, groundProb);
else
    bndGroundProb = zeros(size(boundaries));
end

%% Apply graph cuts
boundaryLabels = boundaryGraphCutSegmentation(length(boundaries), edgePot, lambda, ...
    'UseShadowProbability', args.UseShadowProbability, 'ShadowProb', args.ShadowProb, 'ShadowProbInd', args.ShadowProbInd, ...
    'UseGroundProbability', args.UseGroundProbability, 'BndGroundProb', bndGroundProb, ...
    'UseOcclusionProbability', args.UseOcclusionProbability', 'OcclusionProb', args.OcclusionProb);
        