%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function wseg = grad2wseg(gradImage, prctMaxNbSegs)
%  Converts a gradient image to a segmentation with watershed
% 
% Input parameters:
%  - gradImage: gradient image
%  - prctMaxNbSegs: percentage of maximum number of segments to keep
%
% Output parameters:
%  - wseg: output segmentation
%   
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [wseg, curIter] = grad2wseg(gradImage, prctMaxNbSegs)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2010 Jean-Francois Lalonde
% Carnegie Mellon University
% Consult the LICENSE.txt file for licensing information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin == 1
    prctMaxNbSegs = 1;
end

c = 1;
maxNbIter = 10;
curIter = 1;

wseg = watershed(medfilt2(gradImage, [c c]));
maxNbSegs = max(wseg(:));

nbSegs = maxNbSegs;

while nbSegs > maxNbSegs*prctMaxNbSegs && curIter <= maxNbIter
    c = c + 2;
    wseg = watershed(medfilt2(gradImage, [c c]));
    nbSegs = max(wseg(:));
    curIter = curIter + 1;
end
wseg = uint16(wseg);