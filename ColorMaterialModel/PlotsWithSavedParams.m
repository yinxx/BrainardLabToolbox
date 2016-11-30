
clear; close all; 
load('returnedParamsTemp.mat')
plotWeibullFitsToData = 1; 

%% Plot measured vs. predicted probabilities
theDataProb = theResponsesFromSimulatedData./nTrials;
figure; hold on
plot(theDataProb,predictedProbabilitiesBasedOnSolution,'ro','MarkerSize',12,'MarkerFaceColor','r');
plot(theDataProb,probabilitiesComputedForSimulatedData,'bo','MarkerSize',12,'MarkerFaceColor','b');
legend('predicted', 'computed', 'Location', 'NorthWest')
plot([0 1],[0 1],'k');
axis('square')
axis([0 1 0 1]);
set(gca,  'FontSize', 18);
xlabel('Measured p');
ylabel('Predicted p');
set(gca, 'xTick', [0, 0.5, 1]);
set(gca, 'yTick', [0, 0.5, 1]);

%% Fit cubic spline to the data
% We do this separately for color and material dimension
ppColor = spline(materialMatchColorCoords, returnedMaterialMatchColorCoords);
ppMaterial = spline(colorMatchMaterialCoords, returnedColorMatchMaterialCoords);
xMinTemp = floor(min([returnedMaterialMatchColorCoords, returnedColorMatchMaterialCoords]))-0.5; 
xMaxTemp = ceil(max([returnedMaterialMatchColorCoords, returnedColorMatchMaterialCoords]))+0.5;
xTemp = max(abs([xMinTemp xMaxTemp]));
xMin = -xTemp;
xMax = xTemp;
yMin = xMin; 
yMax = xMax;
splineOverX = linspace(xMin,xMax,1000);
inferredPositionsColor = ppval(splineOverX,ppColor); 
inferredPositionsMaterial  = ppval(splineOverX,ppMaterial); 

%% Plot found vs predicted positions. 
figure; 
subplot(1,2,1); hold on % plot of material positions
plot(materialMatchColorCoords,returnedMaterialMatchColorCoords,'ro',splineOverX, inferredPositionsColor, 'r');
plot([xMin xMax],[yMin yMax],'--', 'LineWidth', 1, 'color', [0.5 0.5 0.5]);
title('Color dimension')
axis([xMin, xMax,yMin, yMax])
axis('square')
xlabel('"True" position');
ylabel('Inferred position');
set(gca, 'xTick', [xMin, 0, xMax],'FontSize', 18);
set(gca, 'yTick', [yMin, 0, yMax],'FontSize', 18);

% Set large range of values for fittings
subplot(1,2,2); hold on % plot of material positions
title('Material dimension')
plot(colorMatchMaterialCoords,returnedColorMatchMaterialCoords,'bo',splineOverX,inferredPositionsMaterial, 'b');
plot([xMin xMax],[yMin yMax],'--', 'LineWidth', 1, 'color', [0.5 0.5 0.5]);
axis([xMin, xMax,yMin, yMax])
axis('square')
xlabel('"True" position');
ylabel('Inferred position');
set(gca, 'xTick', [xMin, 0, xMax],'FontSize', 18);
set(gca, 'yTick', [yMin, 0, yMax],'FontSize', 18);

%% Another way to plot the data
figure; hold on; 
plot(returnedMaterialMatchColorCoords, zeros(size(returnedMaterialMatchColorCoords)),'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 12); 
line([xMin, xMax], [0,0],'color', 'k'); 
plot(zeros(size(returnedColorMatchMaterialCoords)), returnedColorMatchMaterialCoords, 'bo','MarkerFaceColor', 'b', 'MarkerSize', 12); 
axis([xMin, xMax,yMin, yMax])
line([0,0],[yMin, yMax],  'color', 'k'); 
axis('square')
xlabel('color positions', 'FontSize', 18);
ylabel('material positions','FontSize', 18);

%% Plot Weibull fits to the data
if plotWeibullFitsToData
    for i = 1:size(responseFromSimulatedData,2);
        if i == 4
            fixPoint = 1;
        else
            fixPoint = 0;
        end
        [theSmoothPreds(:,i), theSmoothVals(:,i)] = ColorMaterialModelGetValuesFromFits(simulatedProbabilities(:,i)',colorMatchMaterialCoords, fixPoint);
    end
    ColorMaterialModelPlotFits(theSmoothVals, theSmoothPreds, materialMatchColorCoords, simulatedProbabilities);
end

%% Plot model predictions 
% First check the positions of color (material) match on color (material) axis.  
% Signal if there is an error. 
returnedMaterialMatchMaterialCoord = ppval(targetMaterialCoord, ppMaterial);
returnedColorMatchColorCoord =  ppval(targetColorCoord, ppColor);
if ~(returnedMaterialMatchMaterialCoord == 0)
    error('Target material coordinate did not map to zero.')
end
if ~(returnedColorMatchColorCoord == 0)
    error('Target color coordinates did not map to zero.')
end

% Find the predicted probabilities for a range of possible color coordinates 
%rangeOfColorCoordinates = linspace(xMin, xMax, 100)';
rangeOfMaterialMatchColorCoordinates = materialMatchColorCoords';

% Loop over each material coordinate of the color match, to get a predicted
% curve for each one.
for whichMaterialCoordinate = 1:length(colorMatchMaterialCoords)
    % Get the inferred material position for this color match
    returnedColorMatchMaterialCoord(whichMaterialCoordinate) = ppval(colorMatchMaterialCoords(whichMaterialCoordinate), ppMaterial);
    
    % Get the inferred color position for a range of material matches
    for whichColorCoordinate = 1:length(rangeOfMaterialMatchColorCoordinates)
        % Get the position of the material match
        returnedMaterialMatchColorCoord(whichColorCoordinate) = ppval(rangeOfMaterialMatchColorCoordinates(whichColorCoordinate), ppColor);
                
        % Compute the model predictions
        modelPredictions(whichColorCoordinate, whichMaterialCoordinate) = ColorMaterialModelComputeProb(targetColorCoord,targetMaterialCoord, ...
            returnedColorMatchColorCoord,returnedMaterialMatchColorCoord(whichColorCoordinate),...
            returnedColorMatchMaterialCoord(whichMaterialCoordinate), returnedMaterialMatchMaterialCoord, returnedW, returnedSigma);
    end
end

rangeOfMaterialMatchColorCoordinates = repmat(rangeOfMaterialMatchColorCoordinates,[1, length(materialMatchColorCoords)]);
ColorMaterialModelPlotFits(rangeOfMaterialMatchColorCoordinates, modelPredictions, materialMatchColorCoords, simulatedProbabilities, xMin, xMax);
