%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% demoShadowDetection.m
%  Demonstration file for the shadow detection code. Use this as a starting
%  point, and edit to your liking!
%
% Copyright 2006-2010 Jean-Francois Lalonde
% Carnegie Mellon University
% Consult the LICENSE.txt file for licensing information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load image & information
verbose = 1;
imgName = 'img';

% load the image
imgFilename = fullfile('data', 'img', sprintf('%s.jpg', imgName));
img = im2double(imread(imgFilename));

% load the classifier
classifierInfo = load('data/bdt-eccv10.mat');

% whether we should use the geometric context ground probability or not
useGroundProb = 1;
if useGroundProb
    % the variable 'groundProb' was pre-computed using geometric context,
    % see README.txt
    groundProbFilename = fullfile('data', 'img', sprintf('%s-groundProb.mat', imgName));
    
    if exist(groundProbFilename, 'file')
        load(groundProbFilename, 'groundProb');
        myfprintf(verbose, 'Successfully loaded ground probability.\n');
    else
        myfprintf(verbose, 'Warning: you specified useGroundProb = 1, but I couldn''t find the corresponding file %s!\n', groundProbFilename);
        myfprintf(verbose, 'I will keep going, but won''t be using the ground probability.\n');
        groundProb = [];
        useGroundProb = 0;
    end
else
    groundProb = [];
end

% load texton dictionary and filter bank
univTextons = load('data/univTextons_128.mat');
textonFilterBank = load('data/filterBank.mat');

%%

% parameters for the CRF
lambda = 0.5;
beta = 16;

%% Find boundaries
myfprintf(verbose, 'Finding image boundaries...\n');
[boundaries, junctions, neighbors, fseg] = extractImageBoundaries(img);

% Let's display them
figure(1); imshow(img);
displayBoundaries(figure(1), boundaries, 'b', 3);
title(sprintf('Oversegmentation, %d boundaries found', length(boundaries)));

%% Compute boundary features
myfprintf(verbose, 'Computing boundary features (this will take a while...)\n');
bndFeatures = computeAllShadowBoundaryFilterFeatures(img, boundaries, ...
    'Verbose', verbose, ...
    'RGBFilters', 1, 'LABFilters', 1, 'ILLFilters', 1, 'NbScales', 4, ...
    'Textons', 1, 'UnivTextons', univTextons.clusterCenters, 'TextonFilterBank', textonFilterBank.filterBank);

%% Compute image features (unused)
myfprintf(verbose, 'Computing image features...\n');
imageFeatures = computeImageFeatures(img, 'Verbose', verbose, 'RGBContrast', 1);

%% Run the boundary classifier
myfprintf(verbose, 'Applying boundary classifier...\n');

[boundaryProbabilities, indStrongBnd, allBoundaryProbabilities] = applyLocalBoundaryClassifier(img, [], ...
    classifierInfo, bndFeatures, imageFeatures, ...
    boundaries, neighbors.junction_fragmentlist, neighbors.fragment_junctionlist);

% Let's display them
figure(2); imshow(img);
displayBoundariesProb(figure(2), boundaries(indStrongBnd), boundaryProbabilities, 3);
title('Boundary probability (for strong boundaries only)');

%% Run the CRF

% compute segment features
spFeatures = computeShadowSegmentFeatures(img, fseg, 'RGBHist', 1);
spFeats = spFeatures.RGBHist.mean;

withStr = {'without', 'with'};
myfprintf(verbose, 'Applying CRF %s geometric context...\n', withStr{useGroundProb+1});
boundaryLabels = applyBoundaryGrouping(lambda, beta, boundaries, neighbors.junction_fragmentlist, ...
    'UseShadowProbability', 1, 'ShadowProb', boundaryProbabilities, 'ShadowProbInd', indStrongBnd, ...
    'UseGroundProbability', useGroundProb, 'GroundMask', groundProb, ...
    'UseSegFeatures', 1, 'SegFeatures', spFeats, 'BndToSegId', neighbors.fragment_segments);

% Let's display the CRF labels
figure(3); imshow(img);
displayBoundaries(figure(3), boundaries(boundaryLabels==0), 'r', 3);
groundStr = {'Shadows', 'Ground shadows'};
title(sprintf('%s detected', groundStr{useGroundProb+1}));
