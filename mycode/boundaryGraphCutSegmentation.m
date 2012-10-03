%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function labels = shadowGraphCutSegmentation(nbNodes, edgePot, lambda, varargin)
%  Runs graph-cut inference.
%
% Input parameters:
%  - nbNodes: number of nodes in the graph
%  - edgePot: pairwise (edge) potentials
%  - lambda: see paper.
%
% Output parameters:
%  - labels: output labels after inference
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function labels = boundaryGraphCutSegmentation(nbNodes, edgePot, lambda, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2010 Jean-Francois Lalonde
% Carnegie Mellon University
% Consult the LICENSE.txt file for licensing information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Parse arguments
defaultArgs = struct('UseShadowProbability', 0, 'ShadowProb', [], 'ShadowProbInd', [], ...
    'UseGroundProbability', 0, 'BndGroundProb', [], ...
    'UseOcclusionProbability', 0, 'OcclusionProb', [], ...
    'StrongSeeds', 0);
args = parseargs(defaultArgs, varargin{:});

maxWeight = max(sum(edgePot, 2)) + 1;

unaryPot = zeros(nbNodes, 2);
defaultProb = 0.2;

if ~args.UseGroundProbability
    allGroundProb = [];
    shadowGroundProb = [];
else
    allGroundProb = args.BndGroundProb;
    shadowGroundProb = args.BndGroundProb(args.ShadowProbInd);
end

% build potentials for all boundaries
[shadowPenalty, nonShadowPenalty] = combineGroundOcclusionAndShadowProb(defaultProb, maxWeight, ...
    'GroundProb', allGroundProb);
unaryPot(:,1) = shadowPenalty;
unaryPot(:,2) = nonShadowPenalty;

% build potentials for strong boundaries
[shadowPenalty, nonShadowPenalty] = combineGroundOcclusionAndShadowProb(args.ShadowProb, maxWeight, ...
    'GroundProb', shadowGroundProb', 'OcclusionProb', args.OcclusionProb');

unaryPot(args.ShadowProbInd,1) = shadowPenalty;
unaryPot(args.ShadowProbInd,2) = nonShadowPenalty;

%% Set strong weights to seeds
if args.StrongSeeds
    unaryPot(args.ShadowProbInd,2) = maxWeight; unaryPot(args.ShadowProbInd,1) = 0;
    unaryPot(nonShadowInd,1) = maxWeight; unaryPot(nonShadowInd,2) = 0;
end

%% Apply graph cuts
classSmoothness = [0 1; 1 0]; % assign penalty only if they're different
gch = GraphCut('open', lambda.*unaryPot', classSmoothness, edgePot);

[gch labels] = GraphCut('expand', gch);

% Compute confidence for each label
if 0
    [gch, optEnergy] = GraphCut('energy', gch);
    labelSwitchEnergy = zeros(size(labels));
    for l=1:length(labels)
        % invert a single label
        newLabels = labels;
        newLabels(l) = ~newLabels(l);
        gch = GraphCut('set', gch, newLabels);
        
        [gch labelSwitchEnergy(l)] = GraphCut('energy', gch);
    end
    
    labelsConf = 1-exp(-((labelSwitchEnergy-optEnergy)./max(labelSwitchEnergy-optEnergy)).^2./0.25);
end

% we're done
GraphCut('close', gch);

%% Useful function: fit GMM with a decrasing number of gaussians
    function mix = fitGMMIter(feats, maxNbGaussians)
        nbGaussians = fliplr(1:maxNbGaussians);
        
        for n=nbGaussians
            mix = gmm(3, n, 'diag');
            
            opts(3) = 1e-1; % termination in log-likelihood
            mix = gmminit(mix, feats, opts);
            
            opts(3) = 1e-2; % termination in log-likelihood
            opts(14) = 500; % 500 em iterations
            mix = gmmem(mix, feats, opts);
            
            if all(~isnan(mix.centres))
                break;
            end
        end
    end
end
