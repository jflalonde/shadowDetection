%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% featVec = selectBoundaryFeatures(featStruct, boundaryInd, varargin)
%  Selects subset from a set of pre-computed features. 
% 
% Input parameters:
%  - featStruct: structure of features computed on an image
%  - boundaryInd: indices of boundaries to select
%
% Output parameters:
%  - featVec: concatenated features   
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function featVec = selectBoundaryFeatures(featStruct, boundaryInd, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2010 Jean-Francois Lalonde
% Carnegie Mellon University
% Consult the LICENSE.txt file for licensing information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Parse arguments
defaultArgs = struct(...
    ... Sp-based features
    'IntMin', 0, 'IntMinNorm', 0, ...
    'RGBMin', 0, 'RGBMax', 0, 'RGBRatio', 0, 'RGBDiff', 0, ...
    'RGBMinNorm', 0, 'RGBMaxNorm', 0, 'RGBRatioNorm', 0, 'RGBDiffNorm', 0, ...
    'LABMin', 0, 'LABMax', 0, 'LABRatio', 0, 'LABDiff', 0, ...
    'LABMinNorm', 0, 'LABMaxNorm', 0, 'LABRatioNorm', 0, 'LABDiffNorm', 0, ...
    'ILLMin', 0, 'ILLMax', 0, 'ILLRatio', 0, 'ILLDiff', 0, ...
    'ILLMinNorm', 0, 'ILLMaxNorm', 0, 'ILLRatioNorm', 0, 'ILLDiffNorm', 0, ...
    ...
    ... Filter-based features
    'RGBFiltersMinInt', 0, 'RGBFiltersMin', 0, 'RGBFiltersMax', 0, 'RGBFiltersRatio', 0, 'RGBFiltersDiff', 0, ...
    'RGBFiltersMinIntNorm', 0, 'RGBFiltersMinNorm', 0, 'RGBFiltersMaxNorm', 0, 'RGBFiltersRatioNorm', 0, 'RGBFiltersDiffNorm', 0, ...
    'RGBFiltersBndOrientMin', 0, 'RGBFiltersBndOrientMax', 0, 'RGBFiltersBndOrientRatio', 0, 'RGBFiltersBndOrientDiff', 0, ...
    'RGBFiltersBndOrientMinNorm', 0, 'RGBFiltersBndOrientMaxNorm', 0, 'RGBFiltersBndOrientRatioNorm', 0, 'RGBFiltersBndOrientDiffNorm', 0, ...
    'LABFiltersMin', 0, 'LABFiltersMax', 0, 'LABFiltersRatio', 0, 'LABFiltersDiff', 0, ...
    'LABFiltersMinNorm', 0, 'LABFiltersMaxNorm', 0, 'LABFiltersRatioNorm', 0, 'LABFiltersDiffNorm', 0, ...
    'LABFiltersBndOrientMin', 0, 'LABFiltersBndOrientMax', 0, 'LABFiltersBndOrientRatio', 0, 'LABFiltersBndOrientDiff', 0, ...
    'LABFiltersBndOrientMinNorm', 0, 'LABFiltersBndOrientMaxNorm', 0, 'LABFiltersBndOrientRatioNorm', 0, 'LABFiltersBndOrientDiffNorm', 0, ...
    'ILLFiltersMin', 0, 'ILLFiltersMax', 0, 'ILLFiltersRatio', 0, 'ILLFiltersDiff', 0, ...
    'ILLFiltersMinNorm', 0, 'ILLFiltersMaxNorm', 0, 'ILLFiltersRatioNorm', 0, 'ILLFiltersDiffNorm', 0, ...
    'ILLFiltersBndOrientMin', 0, 'ILLFiltersBndOrientMax', 0, 'ILLFiltersBndOrientRatio', 0, 'ILLFiltersBndOrientDiff', 0, ...
    'ILLFiltersBndOrientMinNorm', 0, 'ILLFiltersBndOrientMaxNorm', 0, 'ILLFiltersBndOrientRatioNorm', 0, 'ILLFiltersBndOrientDiffNorm', 0, ...
    'LogRGBFiltersMin', 0, 'LogRGBFiltersMax', 0, 'LogRGBFiltersRatio', 0, 'LogRGBFiltersDiff', 0, ...
    'LogRGBFiltersMinNorm', 0, 'LogRGBFiltersMaxNorm', 0, 'LogRGBFiltersRatioNorm', 0, 'LogRGBFiltersDiffNorm', 0, ...
    'LogRGBFiltersBndOrientMin', 0, 'LogRGBFiltersBndOrientMax', 0, 'LogRGBFiltersBndOrientRatio', 0, 'LogRGBFiltersBndOrientDiff', 0, ...
    'LogRGBFiltersBndOrientMinNorm', 0, 'LogRGBFiltersBndOrientMaxNorm', 0, 'LogRGBFiltersBndOrientRatioNorm', 0, 'LogRGBFiltersBndOrientDiffNorm', 0, ...
    'RGBOrderMin', 0, 'RGBOrderMax', 0, 'RGBOrderDiff', 0, ...
    ... Texton-based features
    'TextonHist', 0, 'IntSkewness', 0, ...
    'NbScales', 1, ...
    'FinlaysonDiffMag', 0);
args = parseargs(defaultArgs, varargin{:});

featVec = [];

% if isempty(boundaryInd)
%     boundaryInd = (1:size(featStruct.RGBFilters.minInt, 1))';
% end

%% Create feature vector
columnIndScales = {[], 1:args.NbScales*3};
columnIndScalesInt = {[], 1:args.NbScales};
columnIndNoScales = {[], 1:3};
columnIndScalesIntensity = 1:3:(args.NbScales*3);

%% Filter-based features
% Intensity (convert from RGB)
if args.RGBFiltersMinInt
    featVec = cat(2, featVec, featStruct.RGBFilters.minInt(boundaryInd,columnIndScalesIntensity).*0.2989 + ...
        featStruct.RGBFilters.minInt(boundaryInd,columnIndScalesIntensity+1).*0.5870 + ...
        featStruct.RGBFilters.minInt(boundaryInd,columnIndScalesIntensity+2).*0.1140);
end

if args.RGBFiltersMinIntNorm
    featVec = cat(2, featVec, featStruct.RGBFilters.minIntNorm(boundaryInd,columnIndScalesIntensity).*0.2989 + ...
        featStruct.RGBFilters.minIntNorm(boundaryInd,columnIndScalesIntensity+1).*0.5870 + ...
        featStruct.RGBFilters.minIntNorm(boundaryInd,columnIndScalesIntensity+2).*0.1140);
end

% Colorspace features
featVec = selectFeatures(featVec, 'RGBFilters', featStruct, args);
featVec = selectFeatures(featVec, 'LABFilters', featStruct, args);
featVec = selectFeatures(featVec, 'ILLFilters', featStruct, args);

% RGBOrder
if isfield(featStruct, 'RGBOrder')
    featVec = cat(2, featVec, featStruct.RGBOrder.minInt(boundaryInd, columnIndNoScales{args.RGBOrderMin+1}));
    featVec = cat(2, featVec, featStruct.RGBOrder.maxInt(boundaryInd, columnIndNoScales{args.RGBOrderMax+1}));
    featVec = cat(2, featVec, featStruct.RGBOrder.diff(boundaryInd, columnIndNoScales{args.RGBOrderDiff+1}));
end

% Textons
if isfield(featStruct, 'Textons')
    featVec = cat(2, featVec, featStruct.Textons.histDist(boundaryInd, columnIndScalesInt{args.TextonHist+1}));
    featVec = cat(2, featVec, featStruct.Textons.skewDist(boundaryInd, columnIndScalesInt{args.IntSkewness+1}));
    featVec(isnan(featVec)) = 0;
end

%% Superpixel features

% minimum intensity
if args.IntMin
    featVec = cat(2, featVec, featStruct.RGB.minInt(boundaryInd,columnIndScalesIntensity).*0.2989 + ...
        featStruct.RGB.minInt(boundaryInd,columnIndScalesIntensity+1).*0.5870 + ...
        featStruct.RGB.minInt(boundaryInd,columnIndScalesIntensity+2).*0.1140);
end

% colorspace features
featVec = selectFeatures(featVec, 'RGB', featStruct, args);
featVec = selectFeatures(featVec, 'LAB', featStruct, args);
featVec = selectFeatures(featVec, 'ILL', featStruct, args);

    % Useful function: select features from a set of filters
    function featVec = selectFeatures(featVec, featName, featStruct, args)
        
        % RGBFilters
        if isfield(featStruct, featName)
            featVec = cat(2, featVec, featStruct.(featName).minInt(boundaryInd, columnIndScales{args.(sprintf('%sMin', featName))+1}));
            featVec = cat(2, featVec, featStruct.(featName).maxInt(boundaryInd, columnIndScales{args.(sprintf('%sMax', featName))+1}));
            featVec = cat(2, featVec, featStruct.(featName).minInt(boundaryInd, columnIndScales{args.(sprintf('%sRatio', featName))+1})./featStruct.(featName).maxInt(boundaryInd, columnIndScales{args.(sprintf('%sRatio', featName))+1}));
            featVec = cat(2, featVec, featStruct.(featName).maxInt(boundaryInd, columnIndScales{args.(sprintf('%sDiff', featName))+1})-featStruct.(featName).minInt(boundaryInd, columnIndScales{args.(sprintf('%sDiff', featName))+1}));
        end
    end
end