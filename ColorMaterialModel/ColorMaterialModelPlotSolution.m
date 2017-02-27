function ColorMaterialModelPlotSolution(allDataProbs,allPredictedProbs,colorMaterialDataProb, colorMaterialPredictedProbs, ...
    modelParams, params, subjectName, conditionCode, figDir, saveFig, weibullplots, ...
    colIndex, matIndex, actualProbs, resizedColorMatActualProbabilities)
% ColorMaterialModelPlotSolution(theDataProb, predictedProbabilitiesBasedOnSolution, modelParams, params,  figDir, saveFig, weibullplots, actualProbs)
%
% Make a nice plot of the data and MLDS-based model fit.
%
% Inputs:
%   theDataProb - the data probabilities measured in the experiment
%   predictedProbabilitiesBasedOnSolution - predictions based on solutions
%   modelParams - set of model parameters
%   params - exp. specifications
%   subjectName - which subject to plot 
%   conditionCode - which condition to plot
%   figDir -  specify figure directory
%   saveFig - save figure or not
%   weibullplots - flag indicating whether to save weibullplots or not
%   actualProbs -  probabilities for actual parameters (ground truth) which
%                  we know when we do the simulation

% Unpack passed params. Set tolerance for recovered target position. 
[returnedMaterialMatchColorCoords,returnedColorMatchMaterialCoords,returnedW,returnedSigma]  = ColorMaterialModelXToParams(modelParams, params); 

%% parameters for plots
close all; 
thisFontSize = 6; 
thisMarkerSize = 6; 
thisLineWidth = 1; 

%% Figure 1. Plot measured vs. predicted probabilities
figure; hold on
tmp1 = [allDataProbs(colIndex), allDataProbs(matIndex)]; 
tmp2 = [allPredictedProbs(colIndex), allPredictedProbs(matIndex)]; 
plot(allDataProbs(colIndex), allPredictedProbs(colIndex),'ro','MarkerSize',thisMarkerSize-2,'MarkerFaceColor','r');
plot(allDataProbs(matIndex), allPredictedProbs(matIndex),'bo','MarkerSize',thisMarkerSize-2,'MarkerFaceColor','b');

rmseWithin = ComputeRealRMSE(tmp1,tmp2);
text(0.07, 0.87, sprintf('RFit = %.4f', rmseWithin), 'FontSize', thisFontSize);
if nargin == 15
    plot(allDataProbs(colIndex),actualProbs(colIndex),'rx','MarkerSize',thisMarkerSize-2);
    plot(allDataProbs(matIndex),actualProbs(matIndex),'bx','MarkerSize',thisMarkerSize-2);
    tmp11 = [actualProbs(colIndex), actualProbs(matIndex)];
    rmseComp = ComputeRealRMSE(tmp1,tmp11); clear tmp1 tmp2 tmp11
    text(0.07, 0.82, sprintf('RActual-ALL = %.4f', rmseComp), 'FontSize', thisFontSize);
    legend('Fit Parameters', 'Actual Parameters', 'Location', 'NorthWest')
    legend boxoff
else
    legend('Fit Parameters', 'Location', 'NorthWest')
    legend boxoff
end
line([0, 1], [0,1], 'color', 'k');
axis('square')
axis([0 1 0 1]);
set(gca,  'FontSize', thisFontSize);
xlabel('Measured p');
ylabel('Predicted p');
set(gca, 'xTick', [0, 0.5, 1]);
set(gca, 'yTick', [0, 0.5, 1]);
ax(1)=gca;

figure; hold on
plot(colorMaterialDataProb, colorMaterialPredictedProbs,'ro','MarkerSize',thisMarkerSize-2,'MarkerFaceColor','r');
rmseAcross = ComputeRealRMSE(colorMaterialDataProb(~isnan(colorMaterialDataProb(:))),colorMaterialPredictedProbs(~isnan(colorMaterialPredictedProbs(:))));
text(0.07, 0.87, sprintf('RFit = %.4f', rmseAcross), 'FontSize', thisFontSize);
if nargin == 15
    plot(allDataProbs,actualProbs,'bx','MarkerSize',thisMarkerSize-2)
    rmseComp = ComputeRealRMSE(colorMaterialDataProb(:),resizedColorMatActualProbabilities(:));
    text(0.07, 0.82, sprintf('RActual = %.4f', rmseComp), 'FontSize', thisFontSize);
    legend('Fit Parameters', 'Actual Parameters', 'Location', 'NorthWest')
    legend boxoff
else
    legend('Fit Parameters', 'Location', 'NorthWest')
    legend boxoff
end
line([0, 1], [0,1], 'color', 'k');
axis('square')
axis([0 1 0 1]);
set(gca,  'FontSize', thisFontSize);
xlabel('Measured p');
ylabel('Predicted p');
set(gca, 'xTick', [0, 0.5, 1]);
set(gca, 'yTick', [0, 0.5, 1]);
ax(2)=gca;

% if saveFig
%     cd(figDir)
%     FigureSave([subjectName, conditionCode, 'MeasuredVsPredictedProb'], gcf, 'pdf'); 
% end

%% Prepare for figure 2. Fit cubic spline to the data
% We do this separately for color and material dimension
xMinTemp = floor(min([returnedMaterialMatchColorCoords, returnedColorMatchMaterialCoords]))-0.5; 
xMaxTemp = ceil(max([returnedMaterialMatchColorCoords, returnedColorMatchMaterialCoords]))+0.5;
xTemp = max(abs([xMinTemp xMaxTemp]));
% xMin = -xTemp;
% xMax = xTemp;
% yMin = xMin; 
% yMax = xMax;

yMin = -10; 
yMax = 10; 
xMin = -10; 
xMax = 10; 

splineOverX = linspace(xMin,xMax,1000);
splineOverX(splineOverX>max(params.materialMatchColorCoords))=NaN;
splineOverX(splineOverX<min(params.materialMatchColorCoords))=NaN; 

% Find a linear fit to the data for both color and material. 
FColor = griddedInterpolant(params.materialMatchColorCoords, returnedMaterialMatchColorCoords,'linear');
FMaterial = griddedInterpolant(params.colorMatchMaterialCoords, returnedColorMatchMaterialCoords,'linear');

% We evaluate this function at all values of X we're interested in. 
inferredPositionsColor = FColor(splineOverX); 
inferredPositionsMaterial  = FMaterial(splineOverX); 

%% Figure 2. Plot positions from fit versus actual simulated positions 
fColor = figure; hold on; 
%subplot(1,2,1); hold on % plot of material positions
plot(params.materialMatchColorCoords,returnedMaterialMatchColorCoords,'ro',splineOverX, inferredPositionsColor, 'r', 'MarkerSize', thisMarkerSize);
plot(params.colorMatchMaterialCoords,returnedColorMatchMaterialCoords,'bo',splineOverX,inferredPositionsMaterial, 'b', 'MarkerSize', thisMarkerSize);
plot([xMin xMax],[yMin yMax],'--', 'LineWidth', thisLineWidth, 'color', [0.5 0.5 0.5]);
%title('Color dimension')
axis([xMin, xMax,yMin, yMax])
axis('square')
xlabel('"True" position');
ylabel('Inferred position');
set(gca, 'xTick', [xMin, 0, xMax],'FontSize', thisFontSize);
set(gca, 'yTick', [yMin, 0, yMax],'FontSize', thisFontSize);
ax(3)=gca;

% % Set large range of values for fittings
% fMaterial = figure; hold on; %subplot(1,2,2); hold on % plot of material positions
% %title('Material dimension')
% plot([xMin xMax],[yMin yMax],'--', 'LineWidth', thisLineWidth, 'color', [0.5 0.5 0.5]);
% axis([xMin, xMax,yMin, yMax])
% axis('square')
% xlabel('"True" position');
% ylabel('Inferred position');
% set(gca, 'xTick', [xMin, 0, xMax],'FontSize', thisFontSize);
% set(gca, 'yTick', [yMin, 0, yMax],'FontSize', thisFontSize);
% ax(3)=gca;
if saveFig
    FigureSave([subjectName, conditionCode, 'RecoveredPositionsSpline'], fColor, 'pdf'); 
  %  FigureSave([subjectName, conditionCode, 'RecoveredPositionsSpline'], fMaterial, 'pdf'); 
end

%% Plot the color and material of the stimuli obtained from the fit in the 2D representational space
f2 = figure; hold on; 
plot(returnedMaterialMatchColorCoords, zeros(size(returnedMaterialMatchColorCoords)),'ro', ...
    'MarkerFaceColor', 'r', 'MarkerSize', thisMarkerSize); 
line([xMin, xMax], [0,0],'color', 'k'); 
plot(zeros(size(returnedColorMatchMaterialCoords)), returnedColorMatchMaterialCoords, 'bo',...
    'MarkerFaceColor', 'b', 'MarkerSize', thisMarkerSize); 
axis([xMin, xMax,yMin, yMax])
line([0,0],[yMin, yMax],  'color', 'k'); 
axis('square')
xlabel('color positions', 'FontSize', thisFontSize);
ylabel('material positions','FontSize', thisFontSize);
ax(4)=gca;
if saveFig
    savefig(f2, [subjectName, conditionCode, 'RecoveredPositions2D.fig'])
    FigureSave([subjectName, conditionCode, 'RecoveredPositions2D'], f2, 'pdf'); 
end
%% Figure 3. Plot descriptive Weibull fits to the data. 
if weibullplots
    for i = 1:size(colorMaterialDataProb,2);
        if i == 4
            fixMidPoint = 1;
        else
            fixMidPoint = 0;
        end
        % here we plot proportion of color match chosen for different color
        % -diffence steps of the material match.
        [theSmoothPreds(:,i), theSmoothVals(:,i)] = FitColorMaterialModelWeibull(colorMaterialDataProb(:,i)',...
            params.materialMatchColorCoords, fixMidPoint);
        
        % this is the reverse fit: we're plotting the proportion of time
        % material match is chosen for different material-difference steps of
        % the color match.
        [theSmoothPredsReverseModel(:,i), theSmoothValsReverseModel(:,i)] = FitColorMaterialModelWeibull(1-colorMaterialDataProb(i,:),...
            params.colorMatchMaterialCoords, fixMidPoint);
    end
    thisFig1 = ColorMaterialModelPlotFit(theSmoothVals, theSmoothPreds, params.colorMatchMaterialCoords, colorMaterialDataProb,...
           'whichMatch', 'colorMatch', 'whichFit', 'weibull', 'fontSize', thisFontSize, 'markerSize', thisMarkerSize, 'lineWidth', thisLineWidth);
    thisFig2 = ColorMaterialModelPlotFit(theSmoothValsReverseModel, theSmoothPredsReverseModel, params.materialMatchColorCoords, 1-colorMaterialDataProb', ...
          'whichMatch', 'materialMatch', 'whichFit', 'weibull', 'fontSize', thisFontSize, 'markerSize', thisMarkerSize, 'lineWidth', thisLineWidth);
    
    if saveFig
        FigureSave([subjectName, conditionCode, 'WeibullFitColorXAxis'], thisFig1, 'pdf');
        FigureSave([subjectName, conditionCode, 'WeibullFitMaterialXAxis'],thisFig2, 'pdf');
    end
end
%% Plot predictions of the model through the actual data
% Version 1: color for the x-axis
% First check the positions of color (material) match on color (material) axis.  
% Signal if there is an error.
returnedColorMatchColorCoord =  FColor(params.targetColorCoord);
returnedMaterialMatchMaterialCoord = FMaterial(params.targetMaterialCoord);

% Find the predicted probabilities for a range of possible color coordinates 
rangeOfMaterialMatchColorCoordinates =  linspace(min(params.materialMatchColorCoords), max(params.materialMatchColorCoords), 100)';
% Find the predicted probabilities for a range of possible material
% coordinates - for the reverse model.

rangeOfColorMatchMaterialCoordinates =  linspace(min(params.colorMatchMaterialCoords), max(params.colorMatchMaterialCoords), 100)';
% Loop over each material coordinate of the color match, to get a predicted
% curve for each one.

for whichMaterialCoordinate = 1:length(params.colorMatchMaterialCoords)

    % Get the inferred material position for this color match
    % Note that this is read from cubic spline fit.  
    returnedColorMatchMaterialCoord(whichMaterialCoordinate) = FMaterial(params.colorMatchMaterialCoords(whichMaterialCoordinate));
    
    % Get the inferred color position for a range of material matches
    for whichColorCoordinate = 1:length(rangeOfMaterialMatchColorCoordinates)
        % Get the position of the material match using our FColor function
        returnedMaterialMatchColorCoord(whichColorCoordinate) = FColor(rangeOfMaterialMatchColorCoordinates(whichColorCoordinate));
        
        % Compute the model predictions
        modelPredictions(whichColorCoordinate, whichMaterialCoordinate) = ColorMaterialModelComputeProb(params.targetColorCoord,params.targetMaterialCoord, ...
            returnedColorMatchColorCoord,returnedMaterialMatchColorCoord(whichColorCoordinate),...
            returnedColorMatchMaterialCoord(whichMaterialCoordinate), returnedMaterialMatchMaterialCoord, returnedW, returnedSigma);
        % Compute the model predictions
        
    end
end
rangeOfMaterialMatchColorCoordinates = repmat(rangeOfMaterialMatchColorCoordinates,[1, length(params.materialMatchColorCoords)]);
[thisFig3, thisAxis3] = ColorMaterialModelPlotFit(rangeOfMaterialMatchColorCoordinates, modelPredictions, params.materialMatchColorCoords, colorMaterialDataProb, ...
    'whichMatch', 'colorMatch', 'whichFit', 'MLDS','returnedWeight', returnedW, ...
    'fontSize', thisFontSize, 'markerSize', thisMarkerSize, 'lineWidth', thisLineWidth);
ax(5)=thisAxis3;
% Get values for reverse plotting
for whichColorCoordinate = 1:length(params.materialMatchColorCoords)

    % Get the inferred material position for this color match
    % Note that this is read from cubic spline fit.  
    returnedMaterialMatchColorCoord(whichColorCoordinate) = FColor(params.materialMatchColorCoords(whichColorCoordinate));
    
    % Get the inferred color position for a range of material matches
    for whichMaterialCoordinate = 1:length(rangeOfColorMatchMaterialCoordinates)
        % Get the position of the material match using our FColor function
        returnedColorMatchMaterialCoord(whichMaterialCoordinate) = FMaterial(rangeOfColorMatchMaterialCoordinates(whichMaterialCoordinate));
                
        % Compute the model predictions
        modelPredictions2(whichMaterialCoordinate, whichColorCoordinate) = 1-ColorMaterialModelComputeProb(params.targetColorCoord,params.targetMaterialCoord, ...
            returnedColorMatchColorCoord,returnedMaterialMatchColorCoord(whichColorCoordinate),...
            returnedColorMatchMaterialCoord(whichMaterialCoordinate), returnedMaterialMatchMaterialCoord, ...
            returnedW, returnedSigma);
    end
end
rangeOfColorMatchMaterialCoordinates = repmat(rangeOfColorMatchMaterialCoordinates,[1, length(params.colorMatchMaterialCoords)]);
[thisFig4, thisAxis4] = ColorMaterialModelPlotFit(rangeOfColorMatchMaterialCoordinates, modelPredictions2, params.colorMatchMaterialCoords, 1-colorMaterialDataProb', ...
    'whichMatch', 'materialMatch', 'whichFit', 'MLDS','returnedWeight', returnedW, ...
    'fontSize', thisFontSize, 'markerSize', thisMarkerSize, 'lineWidth', thisLineWidth);
ax(6)=thisAxis4;

if saveFig
    FigureSave([subjectName, conditionCode, 'ModelFitColorXAxis'], thisFig3, 'pdf');
    FigureSave([subjectName, conditionCode, 'ModelFitMaterialXAxis'], thisFig4, 'pdf');
end
nImagesPerRow = 3;
nImages = length(ax);
figure;
for i=1:nImages
    % create and get handle to the subplot axes
    sPlot(i) = subplot(ceil(nImages/nImagesPerRow),nImagesPerRow,i);
     % get handle to all the children in the figure
     aux=get(ax(i),'children');
     for j=1:size(aux)
         tmpFig(i) = aux(j);
         copyobj(tmpFig(i),sPlot(i));
         hold on
     end
     % copy children to new parent axes i.e. the subplot axes
     xlabel(get(get(ax(i),'xlabel'),'string'));
     ylabel(get(get(ax(i),'ylabel'),'string'));
     title(get(get(ax(i),'title'),'string'));
     axis square
     if i > 4
         axis([-3.5 3.5 0 1.05])
     end
end
cd (figDir)
FigureSave([subjectName, conditionCode, 'Main'], gcf, 'pdf');
end