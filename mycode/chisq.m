%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function chi = chisq(h,g)
%  Computes the chi-square statistic between two histograms. 
%
% Input parameters:
%   - h: histogram 1
%   - g: histogram 2
%
% Output parameters:
%   - chi: the chi-square statistic
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function chi = chisq(h,g)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2010 Jean-Francois Lalonde
% Carnegie Mellon University
% Consult the LICENSE.txt file for licensing information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

h = h./(sum(h(:))+eps);
g = g./(sum(g(:))+eps);
t = ((h-g).*(h-g))./(h+g+eps);
chi = 0.5*sum(t(:));


