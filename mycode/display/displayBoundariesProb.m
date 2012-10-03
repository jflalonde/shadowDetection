%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function displayBoundariesProb(figHandle, boundaries, color, lineWidth)
%  
% 
% Input parameters:
%
% Output parameters:
%   
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function displayBoundariesProb(figHandle, boundaries, probabilities, lineWidth)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2010 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(figHandle); 
hold on;

% quantize probabilities
nbColors = 32;
cmap = colormap(jet(nbColors));

[h,probQuant] = histc(probabilities, linspace(0,1+eps,nbColors));

% plot each boundaries
for c=1:nbColors
    cellfun(@(b) plot(b(:,1), b(:,2), 'Color', cmap(c,:), 'LineWidth', lineWidth), boundaries(probQuant==c));
end

% for j=1:length(indBoundary)
%     [r,c] = ind2sub(sizeImg, boundaryInd(cat(2,sg{j})));
%     plot(c, r, 'Color', color, 'LineWidth', lineWidth, 'Marker', '.', 'MarkerSize', lineWidth*5);
% end


