%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function imageFeatures = computeImageFeatures(img, varargin)
%  Computes image-wide features. Actually unused by the classifier.
% 
% Input parameters:
%  - img: input image
%
% Output parameters:
%  - imageFeatures: structure containing the various image features
%   
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function imageFeatures = computeImageFeatures(img, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2010 Jean-Francois Lalonde
% Carnegie Mellon University
% Consult the LICENSE.txt file for licensing information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Parse arguments
defaultArgs = struct('Verbose', 0, 'RGBContrast', 0);
args = parseargs(defaultArgs, varargin{:});

imageFeatures = [];
tic;

%% Contrast measure
if args.RGBContrast
    myfprintf(args.Verbose, 'Estimating contrast...');
    imHistoCombined = imhist(img(:,:,1))+imhist(img(:,:,2))+imhist(img(:,:,3));
%     imHisto = imhist(rgb2gray(img))';
    imHisto = imHistoCombined'./sum(imHistoCombined(:));
    xHisto = linspace(1/(2*256),1-1/(2*256),256);
    
    % ACM
    meanVal = sum(imHisto.*xHisto);
    imageFeatures.RGBContrast.acm = sum(abs(xHisto-meanVal).*imHisto);
    
    % Ke's measure
    imHistoCumul = cumsum(imHisto);
    imageFeatures.RGBContrast.ke = (find(imHistoCumul>=0.99, 1, 'first')+1) - (find(imHistoCumul<=0.01, 1, 'last')-1);
    if isempty(imageFeatures.RGBContrast.ke)
       imageFeatures.RGBContrast.ke = find(imHistoCumul>=0.99, 1, 'first')+1;
    end
end


myfprintf(args.Verbose, 'All none in %.2fs.\n', toc);