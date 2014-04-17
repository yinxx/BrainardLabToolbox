function MLDSColorSelectionPlot(thePairs,theResponses,nTrialsPerPair,targetCompetitorFit,predictedResponses, saveFig)
% function MLDSColorSelectionPlot(thePairs,theResponses,nTrialsPerPair,targetCompetitorFit,predictedResponses)
%
% Plots the inferred position of the target and all the competitors. 
% If the theoretical probabilities are passed, they are plotted against the actual probabilities
% computed from the data. 
%
%
% 5/3/12  dhb  Optional scatterplot of theory against measurements.
% 6/12/13 ar   Changed function names and added comments. 
% 4/07/14 ar  Option to save the figures. 

% Plot theoretical vs. actual probabilities? 
if (nargin < 5 || isempty(predictedResponses))
    SCATTERPLOT = 0;
else
    SCATTERPLOT = 1;
end

% Display data and the fits. 
theData = [thePairs theResponses./nTrialsPerPair];
fprintf('\n Target data set\n');
disp(theData); 
fprintf('\n Target fits\n');
disp(targetCompetitorFit);  

% Plot the inferred position of the target and the competitors. 
f = figure; clf;
if (SCATTERPLOT)
    subplot(1,2,1);  hold on
end
set(gca,  'FontSize', 16);
axis([0 6 0 1]);
plot(1:length(targetCompetitorFit(2:end)),targetCompetitorFit(2:end),'ro','MarkerSize',6,'MarkerFaceColor','r');
plot(1:length(targetCompetitorFit(2:end)),targetCompetitorFit(1)*ones(size(targetCompetitorFit(2:end))),'k','LineWidth',2);
title(sprintf('Target'));
axis('square');

% Compute the probabilities from the data.  
% Plot them vs. predicted probabilites from the fit.  
if (SCATTERPLOT)
    subplot(1,2,2); hold on
    theDataProb = theResponses./ nTrialsPerPair;
    plot(theDataProb,predictedResponses,'ro','MarkerSize',8,'MarkerFaceColor','r');
    plot([0 1],[0 1],'k');
    axis('square')
    axis([0 1 0 1]);
    set(gca,  'FontSize', 16);
    
    xlabel('Measured probabilities');
    ylabel('Predicted probabilities');
end
if savefig
    savefig('MLDSOutput', f, 'pdf');
end
end