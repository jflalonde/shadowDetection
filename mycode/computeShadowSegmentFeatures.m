%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function shadowSegmentFeatures = computeShadowSegmentFeatures(img, seg, varargin)
%  Computes features on the segments (superpixels) of the image (used only for the CRF).
%
% Input parameters:
%  - img: input image
%  - seg: image segmentation
%
% Output parameters:
%  - shadowSegmentFeatures: segment features
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function shadowSegmentFeatures = computeShadowSegmentFeatures(img, seg, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2010 Jean-Francois Lalonde
% Carnegie Mellon University
% Consult the LICENSE.txt file for licensing information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Parse arguments
defaultArgs = struct('Verbose', 0, 'InvRespFunction', [], ...
    'RGBHist', 0, 'HistNbBins', 4, 'Normalize', 0, 'Equalize', 0);
args = parseargs(defaultArgs, varargin{:});

shadowSegmentFeatures = [];
tic;

%% Correct image for inverse response function
if ~isempty(args.InvRespFunction)
    myfprintf(args.Verbose, 'Applying inverse response function...');
    img = correctImage(img, args.InvRespFunction);
end
imgPx = reshape(img, size(img,1)*size(img,2), size(img,3));

segId = 1:max(seg(:));
segIdToPxId = arrayfun(@(x) find(seg==x), segId, 'UniformOutput', 0);

%% Compute RGB histogram
if args.RGBHist
    myfprintf(args.Verbose, 'Computing RGB histogram...');
    histEdges = linspace(0, 1, args.HistNbBins+1); histEdges(end) = histEdges(end)+eps;
    histImg = cellfun(@(x) histc(imgPx(x,:), histEdges, 1), segIdToPxId, 'UniformOutput', 0);
    histImg = cat(3, histImg{:});
    
    % drop last dimension
    histImg = histImg(1:end-1, :, :);
    
    % normalize
    histImg = histImg./repmat(sum(histImg, 1), [size(histImg, 1), 1, 1]);
    
    % reshape: [R1 G1 B1 R2 G2 B2 ...]
    shadowSegmentFeatures.RGBHist.hist = reshape(permute(histImg, [3 2 1]), size(histImg, 3), size(histImg,2)*size(histImg,1));
    
    % compute mean as well
    meanImg = cellfun(@(x) mean(imgPx(x,:), 1), segIdToPxId, 'UniformOutput', 0);
    shadowSegmentFeatures.RGBHist.mean = cat(1, meanImg{:});
    
    if args.Normalize
        myfprintf(args.Verbose, 'Computing normalized features...');
        % subtract mean, divide by stdev
        meanSegmentColor = mean(shadowSegmentFeatures.RGBHist.mean, 1);
        stdSegmentColor = std(shadowSegmentFeatures.RGBHist.mean, 1);
        
        imgPxNew = imgPx - repmat(meanSegmentColor, size(imgPx, 1), 1);
        imgPxNew = imgPxNew ./ repmat(stdSegmentColor, size(imgPx, 1), 1);
        % re-center, and rescale in [0,1] interval
        imgPxNew = imgPxNew + 0.5;
        imgPxNew = (imgPxNew - min(imgPxNew(:))) ./ (max(imgPxNew(:))-min(imgPxNew(:)));
        imgNew = reshape(imgPxNew, size(img));
        
        tmpFeatures = computeShadowSegmentFeatures(imgNew, segIdToPxId, 'RGBHist', 1, 'HistNbBins', args.HistNbBins, 'Verbose', 0);
        shadowSegmentFeatures.RGBHistNorm.hist = tmpFeatures.RGBHist.hist;
        shadowSegmentFeatures.RGBHistNorm.mean = tmpFeatures.RGBHist.mean;
    end
    
    if args.Equalize
        myfprintf(args.Verbose, 'Computing equalized features...');
        imgNew = (cat(3, histeq(img(:,:,1)), histeq(img(:,:,2)), histeq(img(:,:,3))));
        tmpFeatures = computeShadowSegmentFeatures(imgNew, segIdToPxId, 'RGBHist', 1, 'HistNbBins', args.HistNbBins, 'Verbose', 0);
        shadowSegmentFeatures.RGBHistEq.hist = tmpFeatures.RGBHist.hist;
        shadowSegmentFeatures.RGBHistEq.mean = tmpFeatures.RGBHist.mean;
    end
end

%% All none!
myfprintf(args.Verbose, 'all none in %.2fs.\n', toc);
