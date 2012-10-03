%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function fb = buildShadowFeaturesFilterBank(filterOrientations, sigma, support, varargin)
%   Builds a filter bank to compute "half-filters"
% 
% Input parameters:
%  - filterOrientations: different orientations to try
%  - sigma: variance parameter
%  - support: filter size
%
% Output parameters:
%  - fb: filter bank
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fb = buildShadowFeaturesFilterBank(filterOrientations, sigma, support, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2010 Jean-Francois Lalonde
% Carnegie Mellon University
% Consult the LICENSE.txt file for licensing information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% parse arguments
defaultArgs = struct('UsePixelBoundaries', 1);
args = parseargs(defaultArgs, varargin{:});

nbOrientations = numel(filterOrientations);

fb = cell(nbOrientations, 2);
if args.UsePixelBoundaries
    for t=1:nbOrientations
        f = oeFilter(sigma, support, filterOrientations(t)+pi/2, 1, 0, 0); f(f<0) = 0;
        fb{t, 1} = f.*2; % so that it sums up to 1
        
        % shift by pi for opposite direction
        f = oeFilter(sigma, support, filterOrientations(t)+3*pi/2, 1, 0, 0); f(f<0) = 0;
        fb{t, 2} = f.*2; % so that it sums up to 1
    end
else
    for t=1:nbOrientations
        f = buildBoundaryFilter(sigma, support, filterOrientations(t)+pi); f(f<0) = 0;
        fb{t, 1} = f./sum(f(:)); % so that it sums up to 1
        
        f = buildBoundaryFilter(sigma, support, filterOrientations(t)); f(f<0) = 0;
        fb{t, 2} = f./sum(f(:)); % so that it sums up to 1
    end
end
