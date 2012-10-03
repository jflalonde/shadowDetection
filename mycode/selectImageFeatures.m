%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function featVec = selectImageFeatures(featStruct, varargin)
%  Selects subset from a set of pre-computed features. 
% 
% Input parameters:
%  - featStruct: structure of features computed on an image
%
% Output parameters:
%  - featVec: concatenated features   
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function featVec = selectImageFeatures(featStruct, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2010 Jean-Francois Lalonde
% Carnegie Mellon University
% Consult the LICENSE.txt file for licensing information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Parse arguments
defaultArgs = struct('RGBContrastACM', 0, 'RGBContrastKe', 0);
args = parseargs(defaultArgs, varargin{:});

featVec = [];

%% Create feature vector
columnInd = {[], 1};

% RGB contrast
featVec = cat(2, featVec, featStruct.RGBContrast.acm(columnInd{args.RGBContrastACM+1}));
featVec = cat(2, featVec, featStruct.RGBContrast.ke(columnInd{args.RGBContrastKe+1}));
