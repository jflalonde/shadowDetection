%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function shadowBoundaryFeatures = computeAllShadowBoundaryFilterFeatures(img, boundaries, varargin)
%  Computes all the shadow boundary features. 
%
% Input parameters:
%  - img: input image
%  - boundaries: image boundaries
%
% Output parameters:
%  - shadowBoundaryFeatures: structure containing all features as specified
%    as input (varargin)
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function shadowBoundaryFeatures = computeAllShadowBoundaryFilterFeatures(img, boundaries, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2010 Jean-Francois Lalonde
% Carnegie Mellon University
% Consult the LICENSE.txt file for licensing information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Parse arguments
defaultArgs = struct('Verbose', 0, 'Recompute', 0, 'PrevFeatures', [], ...
    'RGBFilters', 0, 'LABFilters', 0, 'ILLFilters', 0, ...
    'NbScales', 1, ...
    'NormalizeEdges', 0, 'UseBoundaryOrientations', 0, 'BoundaryOrientations', [], ...
    'Textons', 0, 'UnivTextons', [], 'TextonFilterBank', []);
args = parseargs(defaultArgs, varargin{:});

shadowBoundaryFeatures = args.PrevFeatures;
recompute = args.Recompute | isempty(shadowBoundaryFeatures);
tic;

%% Compute texture features
if args.Textons
    if ~recompute && isfield(shadowBoundaryFeatures, 'Textons')
        myfprintf(args.Verbose, 'Texton features already computed...');
    else
        myfprintf(args.Verbose, 'Computing texton features...');
        textonFeatures = computeShadowBoundaryTextonFeatures(img, args.UnivTextons, args.TextonFilterBank, boundaries, ...
            'NbScales', args.NbScales);
        shadowBoundaryFeatures = addFeatures(shadowBoundaryFeatures, textonFeatures);
    end
end

%% Compute edge-based features on the segment boundaries
if args.RGBFilters
    if ~recompute && isfield(shadowBoundaryFeatures, 'RGBFilters')
        myfprintf(args.Verbose, 'RGB features already computed...');
    else
        myfprintf(args.Verbose, 'Computing RGB features...');
        rgbFeatures = computeShadowBoundaryFilterColorFeatures(img, rgb2gray(img), 'RGBFilters', boundaries, ...
            'NbScales', args.NbScales, ...
            'NormalizeEdges', args.NormalizeEdges, ...
            'UseBoundaryOrientations', args.UseBoundaryOrientations, 'BoundaryOrientations', args.BoundaryOrientations);
        shadowBoundaryFeatures = addFeatures(shadowBoundaryFeatures, rgbFeatures);
    end
end

%% LAB features
if args.LABFilters
    if ~recompute && isfield(shadowBoundaryFeatures, 'LABFilters')
        myfprintf(args.Verbose, 'LAB features already computed...');
    else
        myfprintf(args.Verbose, 'Computing LAB features...');
        imgLab = rgb2lab(img);
        
        labFeatures = computeShadowBoundaryFilterColorFeatures(imgLab, imgLab(:,:,1), 'LABFilters', boundaries, ...
            'NbScales', args.NbScales, ...
            'NormalizeEdges', args.NormalizeEdges, ...
            'UseBoundaryOrientations', args.UseBoundaryOrientations, 'BoundaryOrientations', args.BoundaryOrientations);
        
        shadowBoundaryFeatures = addFeatures(shadowBoundaryFeatures, labFeatures);
    end
end

%% ILL features
if args.ILLFilters
    if ~recompute && isfield(shadowBoundaryFeatures, 'ILLFilters')
        myfprintf(args.Verbose, 'ILL features already computed...');
    else
        myfprintf(args.Verbose, 'Computing ILL features...');
        imgIll = rgb2ill(img);
        
        illFeatures = computeShadowBoundaryFilterColorFeatures(imgIll, rgb2gray(img), 'ILLFilters', boundaries, ...
            'NbScales', args.NbScales, ...
            'NormalizeEdges', args.NormalizeEdges, ...
            'UseBoundaryOrientations', args.UseBoundaryOrientations, 'BoundaryOrientations', args.BoundaryOrientations);
        
        shadowBoundaryFeatures = addFeatures(shadowBoundaryFeatures, illFeatures);
    end
end

%% All done!
myfprintf(args.Verbose, 'all done in %.2fs.\n', toc);

    %% Useful function: concatenate features
    function shadowBoundaryFeatures = addFeatures(shadowBoundaryFeatures, newFeats)
        fNames = fieldnames(newFeats);
        for fInd=1:length(fNames)
            shadowBoundaryFeatures.(fNames{fInd}) = newFeats.(fNames{fInd});
        end
    end
end
