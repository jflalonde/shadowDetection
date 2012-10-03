%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [shadowPenalty, nonShadowPenalty] = combineGroundOcclusionAndShadowProb(shadowProb, maxWeight, varargin)
%  Combines shadow, ground, and occlusion probabilities into a single
%  penalty term (one for shadow, one for non-shadow) to be used in the CRF.
%
% Input parameters:
%   - shadowProb: probability of shadow
%   - maxWeight: maximum weight to assign
%
% Output parameters:
%   - shadowPenalty: penalty for assigning a shadow label
%   - nonShadowPenalty: penalty for assigning a non-shadow label
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [shadowPenalty, nonShadowPenalty] = combineGroundOcclusionAndShadowProb(shadowProb, maxWeight, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2010 Jean-Francois Lalonde
% Carnegie Mellon University
% Consult the LICENSE.txt file for licensing information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% parse arguments
defaultArgs = struct('GroundProb', [], 'OcclusionProb', []);
args = parseargs(defaultArgs, varargin{:});

shadowPenalty = -log(shadowProb);
nonShadowPenalty = -log(1-shadowProb);

if ~isempty(args.GroundProb)
    shadowPenalty = shadowPenalty - log(args.GroundProb);
    nonShadowPenalty = nonShadowPenalty + (1-args.GroundProb);
end

if ~isempty(args.OcclusionProb)
    shadowPenalty = shadowPenalty - log(1-args.OcclusionProb);
    nonShadowPenalty = nonShadowPenalty + args.OcclusionProb;
end

% shadowPenalty = -log(g) - log(s) - log(1-o);
% nonShadowPenalty = (1-g) - log(1-s) + o;

shadowPenalty = min(shadowPenalty, maxWeight);
nonShadowPenalty = min(nonShadowPenalty, maxWeight);

