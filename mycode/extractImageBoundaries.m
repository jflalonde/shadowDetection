%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [boundaries, junctions, neighbors, fseg] = extractImageBoundaries(img)
%  Extract boundaries in the image based on an over-segmentation using
%  watershed on a filtered version of the image (we use a bilateral
%  filter).
% 
% Input parameters:
%  - img: input image
%
% Output parameters:
%  - boundaries: list of (sub-pixel) boundaries in the image
%  - junctions: list of boundary junctions
%  - neighbors: neighbor structure (see seg2fragments for more details)
%  - fseg: new segmentation with holes (if any) filled. 
% 
% Notes:
%  - Uses the bilateral filtering code from Douglas R. Lanman
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [boundaries, junctions, neighbors, fseg] = extractImageBoundaries(img)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2010 Jean-Francois Lalonde
% Carnegie Mellon University
% Consult the LICENSE.txt file for licensing information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% filter the image
bfilterImg = bfilter2(img, 5, [3 0.1]);

gMag = zeros(size(img, 1), size(img,2));
for c=1:size(bfilterImg, 3)
    [gX,gY] = gradient(conv2(bfilterImg(:,:,c), fspecial('gaussian', 7, 1.5), 'same'));
    gMag(:,:,c) = sqrt(gX.^2 + gY.^2);
end

% apply watershed until we've gotten sufficiently large segments
prctMax = 0.25;
wseg = grad2wseg(max(gMag, [], 3), prctMax);            

% find boundaries, juntions, and neighboring information
[boundaries, junctions, neighbors, fseg] = seg2fragments(double(wseg), img, 25);
