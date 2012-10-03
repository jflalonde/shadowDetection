%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function fb = buildTextureFeaturesFilterBank(filterOrientations, support, varargin)
%   Builds a filter bank to compute "half-filters". 
% 
% Input parameters:
%  - filterOrientations: different orientations to try
%  - support: filter size
%
% Output parameters:
%  - fb: filter bank
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fb = buildTextureFeaturesFilterBank(filterOrientations, support, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2009 Jean-Francois Lalonde
% Carnegie Mellon University
% Consult the LICENSE.txt file for licensing information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% parse arguments
defaultArgs = struct('UsePixelBoundaries', 1);
args = parseargs(defaultArgs, varargin{:});

nbOrientations = numel(filterOrientations);

fb = cell(nbOrientations, 2);
for t=1:nbOrientations
    % use pb code
    theta = filterOrientations(t)-pi/2;
    radius = support;
    
    theta = mod(theta,pi);
    
    % radius of discrete disc
    wr = floor(radius);
    
    % count number of pixels in a disc
    if ~args.UsePixelBoundaries
        wr = wr-0.5;
    end
    [u,v] = meshgrid(-wr:wr,-wr:wr);
    
    gamma = atan2(v,u);
    mask = (u.^2 + v.^2 <= radius^2);
    if args.UsePixelBoundaries
        mask(wr+1,wr+1) = 0; % mask out center pixel to remove bias
    end
    count = sum(mask(:));
    
    % determine which half of the disc pixels fall in
    % (0=masked 1=left 2=right)
    side = 1 + (mod(gamma-theta,2*pi) < pi);
    side = side .* mask;
    if sum(sum(side==1)) ~= sum(sum(side==2)), error('bug:inbalance'); end
    
    fb{t, 1} = (side==1);
    fb{t, 2} = (side==2);
end

