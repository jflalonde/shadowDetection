%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function buildBoundaryFilter(sigma, support, theta)
%   Builds a filter bank to compute "half-filters"
% 
% Input parameters:
%  - sigma: variance parameter
%  - support: filter size
%  - theta: filter orientation
%
% Output parameters:
%  - fb: filter bank
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function f = buildBoundaryFilter(sigma, support, theta)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2010 Jean-Francois Lalonde
% Carnegie Mellon University
% Consult the LICENSE.txt file for licensing information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
fdom = (-(sigma*support)+0.5):((sigma*support)-0.5);

[x,y] = meshgrid(fdom, fdom);
su = x.*sin(-theta) + y.*cos(-theta);
sv = x.*cos(-theta) - y.*sin(-theta);

f = exp(-su.^2/(2*sigma^2)) .* (-sv/(sigma^2)).*exp(-sv.^2/(2*sigma^2));

