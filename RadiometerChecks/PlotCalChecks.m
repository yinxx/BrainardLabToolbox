function PlotCalChecks(measured1,measured2,...						graphText1,graphText2,axisLabelMeasured1, axisLabelMeasured2,...						timeMeasured1, timeMeasured2,...						bgMeasured1, bgMeasured2,...						distMeasured1, distMeasured2)%% This fuction plots two sets of calibration data, one against each other.% Designed to be called from CompareCalChecksSpd, but perhaps will be more% generically useful.%% 8/29/97 dhb, pbe Wrote it.% 9/2/97  pbe, dhb Clean it up a little. % 12/4/99 dhb      Simplify for more generic use.% Pull data out into separate columnsxMeasured1 = measured1(1,:)'; yMeasured1 = measured1(2,:)'; zMeasured1 = measured1(3,:)'; xMeasured2 = measured2(1,:)'; yMeasured2 = measured2(2,:)'; zMeasured2 = measured2(3,:)';% First plot.% Plot measured values in the two runs one against the other.% This has three subplots (one for each color dimension).figure(1);% Subplot 1subplot(1,3,1);plotRange = ceil(MatMax([xMeasured1 ; xMeasured2]));plot(xMeasured1,xMeasured2','r+');hold ona = plot([0 plotRange]',[0 plotRange]','k');set(a, 'LineWidth',1);hold offaxis('equal');axis([0 plotRange 0 plotRange]);title('CIE X Plot', 'Fontsize', 16, 'Fontname', 'helvetica', 'Fontweight', 'bold');xlabel(axisLabelMeasured1, 'Fontweight', 'bold');ylabel(axisLabelMeasured2, 'Fontweight', 'bold');set(gca,'xtick', [10 20 30 40 50 60 70 80 90 100]);set(gca,'ytick',[10 20 30 40 50 60 70 80 90 100]);drawnow;% Subplot 2subplot(1,3,2);plotRange = ceil(MatMax([yMeasured1 ; yMeasured2]));plot(yMeasured1,yMeasured2','g+');hold ona = plot([0 plotRange]',[0 plotRange]','k');set(a, 'LineWidth',1);hold offaxis('equal');axis([0 plotRange 0 plotRange]);title('CIE Y Plot', 'Fontsize', 16, 'Fontname', 'helvetica', 'Fontweight', 'bold');xlabel(axisLabelMeasured1, 'Fontweight', 'bold');set(gca,'xtick', [10 20 30 40 50 60 70 80 90 100]);set(gca,'ytick',[10 20 30 40 50 60 70 80 90 100]);drawnow;% Subplot 3subplot(1,3,3);plotRange = ceil(MatMax([zMeasured1 ; zMeasured2]) );plot(zMeasured1,zMeasured2','b+');hold ona = plot([0 plotRange]',[0 plotRange]','k');set(a, 'LineWidth',1);hold offaxis('equal');axis([0 plotRange 0 plotRange]);title('CIE Z Plot', 'Fontsize', 16, 'Fontname', 'helvetica', 'Fontweight', 'bold');xlabel(axisLabelMeasured1, 'Fontweight', 'bold');set(gca,'xtick', [20 40 60 80 100 120]);set(gca,'ytick', [20 40 60 80 100 120]);drawnow;% Text annotation on graph.  Positions are% defined with respect to axes in first subplot.subplot(1,3,1);v = axis; 	% this gives the coordinates for the axes (in a row matrix)xMin = v(1);xMax = v(2);yMin = v(3);yMax = v(4);rangeXaxis = xMax-xMin;rangeYaxis = yMax-yMin;text(0,1.6*rangeYaxis, graphText1,'Fontsize', 12,'Fontweight', 'bold','Fontname', 'helvetica');text(0, -.5*rangeYaxis, axisLabelMeasured1, 'Fontsize', 12,'Fontweight', 'bold');text(0, -.65*rangeYaxis, sprintf('Distance: %g meter(s)',distMeasured1));text(0, -.8*rangeYaxis, sprintf('Time: %s',timeMeasured1));text(0, -.95*rangeYaxis, sprintf('Background: [%g,%g,%g]',bgMeasured1(1),bgMeasured1(2),bgMeasured1(3) ));text(2*rangeXaxis, -.5*rangeYaxis, axisLabelMeasured2,'Fontsize', 12,'Fontweight', 'bold');text(2*rangeXaxis, -.65*rangeYaxis, sprintf('Distance: %g meter(s)',distMeasured2));text(2*rangeXaxis, -.8*rangeYaxis, sprintf('Time: %s',timeMeasured2));text(2*rangeXaxis, -.95*rangeYaxis, sprintf('Background: [%g,%g,%g]',bgMeasured2(1),bgMeasured2(2),bgMeasured2(3)));% Compute some regression coefficientsslopeX = measured2(1,:)'\measured1(1,:)';slopeY = measured2(2,:)'\measured1(2,:)';slopeZ = measured2(3,:)'\measured1(3,:)';errorX = ComputeRMSE(measured1(1,:)',slopeX*measured2(1,:)');errorY = ComputeRMSE(measured1(2,:)',slopeX*measured2(2,:)');errorZ = ComputeRMSE(measured1(3,:)',slopeX*measured2(3,:)');fprintf(1,'Slopes of measured 1 vs. 2 are %g, %g, %g\n',slopeX,slopeY,slopeZ);fprintf(1,'RMSE of fit lines:\n\t(%0.2e, %0.2e, %0.2e)\n',errorX,errorY,errorZ);% Compute percent errorpercentErrX = (xMeasured2 - xMeasured1) ./ xMeasured1;percentErrY = (yMeasured2 - yMeasured1) ./ yMeasured1;percentErrZ = (zMeasured2 - zMeasured1) ./ zMeasured1;% Second plot.  This shows residuals rather than raw data.figure(2);% Subplot 1subplot(1,3,1);plot(xMeasured1,percentErrX,'r+');hold on;plot([0 100]',[0 0]','k');hold off;title('X Plot','Fontsize', 14, 'Fontname', 'helvetica', 'Fontweight', 'bold');xlabel(axisLabelMeasured1, 'Fontweight', 'bold');ylabel(axisLabelMeasured2, 'Fontweight', 'bold');axis('square');drawnow;% Subplot 2subplot(1,3,2);plot(yMeasured1,percentErrY,'g+');hold on;plot([0 100]',[0 0]','k');hold off;axis('square');title('Y Plot','Fontsize', 14, 'Fontname', 'helvetica', 'Fontweight', 'bold');xlabel(axisLabelMeasured1, 'Fontweight', 'bold');drawnow;% Subplot 3subplot(1,3,3);plot(zMeasured1,percentErrZ,'b+');hold on;plot([0 100]',[0 0]','k');hold off;axis('square');title('Z Plot','Fontsize', 14, 'Fontname', 'helvetica', 'Fontweight', 'bold');xlabel(axisLabelMeasured1, 'Fontweight', 'bold');drawnow;% Text annotation on graph.  Positions are% defined with respect to axes in first subplot.subplot(1,3,1);v = axis; 	% this gives the coordinates for the axes (in a row matrix)xMin = v(1);xMax = v(2);yMin = v(3);yMax = v(4);rangeXaxis = xMax-xMin;rangeYaxis = yMax-yMin;text(-.3*rangeXaxis,1.8*rangeYaxis+yMin, graphText2,'Fontsize', 12,'Fontweight', 'bold','Fontname', 'helvetica');text(0, -.5*rangeYaxis+yMin, axisLabelMeasured1, 'Fontsize', 12,'Fontweight', 'bold');text(0, -.65*rangeYaxis+yMin, sprintf('Distance: %g meter',distMeasured1));text(0, -.75*rangeYaxis+yMin, sprintf('Time: %s',timeMeasured1));text(0, -.85*rangeYaxis+yMin, sprintf('Background: [%g,%g,%g]',bgMeasured1(1),bgMeasured1(2),bgMeasured1(3) ));text(2*rangeXaxis, -.5*rangeYaxis+yMin, axisLabelMeasured2,'Fontsize', 12,'Fontweight', 'bold');text(2*rangeXaxis, -.65*rangeYaxis+yMin, sprintf('Distance: %g meter',distMeasured2));text(2*rangeXaxis, -.75*rangeYaxis+yMin, sprintf('Time: %s',timeMeasured2));text(2*rangeXaxis, -.85*rangeYaxis+yMin, sprintf('Background: [%g,%g,%g]',bgMeasured2(1),bgMeasured2(2),bgMeasured2(3)));text(0,-1.15*rangeYaxis+yMin,sprintf('Slopes of measured 1 vs. 2 are %g, %g, %g',slopeX,slopeY,slopeZ),'Fontname', 'helvetica');text(0,-1.25*rangeYaxis+yMin,sprintf('RMSE of fit lines: (%0.2e, %0.2e, %0.2e)',errorX,errorY,errorZ),'Fontname', 'helvetica');