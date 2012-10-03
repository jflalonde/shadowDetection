%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [X, Y, Z] = rgb2xyz(R,G,B)
%  Converts an image in RGB format to the XYZ format, as described in 
%  http://en.wikipedia.org/wiki/CIE_1931_Color_Space
% 
% Input parameters:
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [X,Y,Z] = rgb2xyz(R,G,B)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Consult the LICENSE.txt file for licensing information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (nargin == 1)
    R = im2double(R);
    
    B = R(:,:,3);
    G = R(:,:,2);
    R = R(:,:,1);
end

[m, n] = size(R);

M = [0.412453 0.357580 0.180423; 0.212671 0.715160 0.072169; 0.019334 0.119193 0.950227];

res = M * [R(:)'; G(:)'; B(:)'];

X = reshape(res(1,:), m, n);
Y = reshape(res(2,:), m, n);
Z = reshape(res(3,:), m, n);

if ((nargout == 1) || (nargout == 0))
    X = cat(3,X,Y,Z);
end