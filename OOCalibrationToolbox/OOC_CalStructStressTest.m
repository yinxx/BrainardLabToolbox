function OOC_CalStructStressTest
    Test2;
end

function Test1
% 
%%  Load a calibration file.
    clc;
    clear all;
    [cal, ~] = GetCalibrationStructure('Enter calibration filename','ViewSonicProbe',[]);
    clc
    DescribeMonCal(cal);
    whos
    
%%  Instantiate a @CalStruct object for controlled & unified access to old- and new-style cal structs.
    % Minimum verbosity
    calStruct = CalStruct(cal, 'verbosity', 0);
    whos
    
%%  Instantiate a @CalStruct object for controlled & unified access to old- and new-style cal structs.
    % Medium verbosity
    calStruct = CalStruct(cal, 'verbosity', 1);

%%  Instantiate a @CalStruct object for controlled & unified access to old- and new-style cal structs.
    % Max verbosity
    calStruct = CalStruct(cal, 'verbosity', 2);
    clear cal
    whos
    
%%  Get a field with a typo, say, 's'
    s = calStruct.get('s')
    
%%  Get the S_Device
    sDev = calStruct.get('S_device')
 
%%  Set a new S_Device (just for testing)
%   sDev = [sDev(1) 2 201];
%   calStruct.set('S_device', sDev);
    
%%  Get the S      
    S = calStruct.get('S')

%%  Get back an old-style cal struct
    oldStyleCal = calStruct.cal;
end

function Test2
%%  Test 5. Read a new-style cal and call old PsyCal routines on it
    clc;
    clear all;
    calFile = 'ViewSonicProbe';
   % calFile = 'PTB3TestCal';
    [cal, ~] = GetCalibrationStructure('Enter calibration filename', calFile,[]);
    clc
    
    DescribeMonCal(cal);
end




function OLD_OOC_CalStructStressTest
    clear; close all
    clc;
    
    % Load a calibration file
    [cal, calFilename] = GetCalibrationStructure('Enter calibration filename','ViewSonicProbe',[]);
    clc;
      
    % Instantiate a calStruct object to manage controlled and unified 
    % access to fields of both old-style and new-style cal files.
    calStruct = CalStruct(cal, 'verbosity', 1);

    meterSerialNo = calStruct.get('meterSerialNumber')
    pause;
    
    calStruct.get('bgmeas.bgSettings')
    S = [380 4 101];
    calStruct.get(S)
    calStruct.set('bgmeas.bgSettings', ones(2,3));
    calStruct.set('bgmeas.bgSettings2', ones(2,3));
    pause;
    cal.describe
    cal.describe.gamma

    exponents = calStruct.get('gamma.exponents')
    pause
    
    reconstructedCal = calStruct.cal
    reconstructedCal.describe
    reconstructedCal.describe.svnInfo
    reconstructedCal.describe.gamma
    reconstructedCal.rawdata
    reconstructedCal.rawdata.monIndex
    reconstructedCal.basicmeas
    reconstructedCal.bgmeas

    reconstructedCal.S_device
    size(reconstructedCal.P_device)
    size(reconstructedCal.T_device)
    
    reconstructedCal.S_ambient
    size(reconstructedCal.P_ambient)
    size(reconstructedCal.T_ambient)
    
    
    testNo = 1;
    fprintf('\n\nStress testing.\n');
    fprintf('%d. Requesting the ''s'' field (typo). Hit enter to continue.\n', testNo);
    pause;
    S = calStruct.get('s')
    
    
    disp('All done');
    pause;
    return
    
    
    
    
    %pause;
    % Test for incorrect fieldname
    testNo = 1;
    fprintf('\n\nStress testing.\n');
    fprintf('%d. Requesting the ''s'' field (typo). Hit enter to continue.\n', testNo);
    pause;
    S = calStruct.get('s')

    
    % Test for 'S' request. Check if S_device, S_ambient exist and are equal to S
    testNo = testNo + 1;
    fprintf('%d. Requesting the ''S'' field. Hit enter to continue.\n', testNo);
    pause;
    S = calStruct.get('S')
    
    
    % Test for 'S_device' request
    testNo = testNo + 1;
    fprintf('%d. Requesting the ''S_device'' field. Hit enter to continue.\n', testNo);
    pause;
    S = calStruct.get('S_device')
    
    
    % Test for 'S_ambient' request
    testNo = testNo + 1;
    fprintf('%d. Requesting the ''S_ambient'' field. Hit enter to continue.\n', testNo);
    pause;
    S = calStruct.get('S_ambient')
    
    
    % Test a new-style cal file
    testNo = testNo + 1;
    calFilename = 'ViewSonicProbe';
    fprintf('%d. Calling DescribeMonCal(''%s''). Hit enter to continue.\n', testNo, calFilename);
    pause;
    % Load  calibration file
    [cal, calFilename] = GetCalibrationStructure('Enter calibration filename',calFilename,[]);
    DescribeMonCal(cal);
    
    
    % Test an old-style cal file, generated by translating a new-style cal file
    testNo = testNo + 1;
    calFilename = 'ViewSonicProbe_OldFormat';
    fprintf('%d. Calling DescribeMonCal(''%s''). Hit enter to continue.\n', testNo, calFilename);
    pause;
    % Load  calibration file
    [cal, calFilename] = GetCalibrationStructure('Enter calibration filename',calFilename,[]);
    DescribeMonCal(cal);
    
    
    
    % Test an old-style cal file
    testNo = testNo + 1;
    calFilename = 'StereoLCDLeft';
    fprintf('%d. Calling DescribeMonCal(''%s''). Hit enter to continue.\n', testNo, calFilename);
    pause;
    % Load  calibration file
    [cal, calFilename] = GetCalibrationStructure('Enter calibration filename',calFilename,[]);
    DescribeMonCal(cal);
    
    
    % Test another old-style cal file
    testNo = testNo + 1;
    calFilename = 'PTB3TestCal';
    fprintf('%d. Calling DescribeMonCal(''%s''). Hit enter to continue.\n', testNo, calFilename);
    pause;
    % Load calibration file
    [cal, calFilename] = GetCalibrationStructure('Enter calibration filename',calFilename,[]);
    DescribeMonCal(cal);
    
    
end






function Stuff
% Load
% Load a calibration file. You can make this with CalibrateMonSpd if
% you have a supported radiometer.
defaultFileName = 'PTB3TestCal';
thePrompt = sprintf('Enter calibration filename [%s]: ',defaultFileName);
newFileName = input(thePrompt,'s');
if (isempty(newFileName))
    newFileName = defaultFileName;
end
fprintf(1,'\nLoading from %s.mat\n',newFileName);
cal = LoadCalFile(newFileName);
fprintf('Calibration file %s read\n\n',newFileName);

% Plot what is in the calibration file
% Print a description of the calibration to the command window.
DescribeMonCal(cal);

% Plot underlying spectral data of the three device primaries
% Retrieve necessary data from calStruct
S        = CalStructGet(cal,'S');
P_device = CalStructGet(cal,'P_device');
figure; clf; hold on
wls      = SToWls(S);
plot(wls,P_device(:,1),'r');
plot(wls,P_device(:,2),'g');
plot(wls,P_device(:,3),'b');
xlabel('Wavelength (nm)');
ylabel('Power');
title('Device Primary Spectra');

% Plot gamma functions together with raw gamma data.  The smooth fit is
% performed at calibration time, but can be redone with RefitCalGamma.
% Retrieve necessary data from calStruct
gammaInput      = CalStructGet(cal,'gammaInput');
gammaTable      = CalStructGet(cal,'gammaTable');
rawGammaInput   = CalStructGet(cal,'rawGammaInput');
rawGammaTable   = CalStructGet(cal,'rawGammaTable');
figure; clf;
subplot(1,3,1); hold on
plot(gammaInput,gammaTable(:,1),'r');
plot(rawGammaInput,rawGammaTable(:,1),'ro','MarkerFaceColor','r','MarkerSize',3);
axis([0 1 0 1]); axis('square');
xlabel('Input value');
ylabel('Linear output');
title('Device Gamma');
subplot(1,3,2); hold on
plot(gammaInput,gammaTable(:,2),'g');
plot(rawGammaInput,rawGammaTable(:,2),'go','MarkerFaceColor','g','MarkerSize',3);
axis([0 1 0 1]); axis('square');
xlabel('Input value');
ylabel('Linear output');
title('Device Gamma');
subplot(1,3,3); hold on
plot(gammaInput,gammaTable(:,3),'b');
plot(rawGammaInput,rawGammaTable(:,3),'bo','MarkerFaceColor','b','MarkerSize',3);
axis([0 1 0 1]); axis('square');
xlabel('Input value');
ylabel('Linear output');
title('Device Gamma');

% Gamma correction without worrying about color
% Show how to linearize a gamma table.  If there were no
% quantization in the DAC, these values would linearize perfectly.
% Actually linearization will be affected by the precision of the DACs.

% Set inversion method.  See SetGammaMethod for information on available
% methods.
defaultGammaMethod = 0;
gammaMethod = input(sprintf('Enter gamma method [%d]:',defaultGammaMethod));
if (isempty(gammaMethod))
    gammaMethod = defaultGammaMethod;
end
disp('beforeset gamma mathod');
cal = SetGammaMethod(cal,gammaMethod);
disp('after set gamma mathod');
pause;

% Make the desired linear output, then convert.
linearValues = ones(3,1)*linspace(0,1,256);
clutValues = PrimaryToSettings(cal,linearValues);
predValues = SettingsToPrimary(cal,clutValues);

% Make a plot of the inverse lookup table.
figure; clf;
subplot(1,3,1); hold on
plot(linearValues,clutValues(1,:)','r');
axis([0 1 0 1]); axis('square');
xlabel('Linear output');
ylabel('Input value');
title('Inverse Gamma');
subplot(1,3,2); hold on
plot(linearValues,clutValues(2,:)','g');
axis([0 1 0 1]); axis('square');
xlabel('Linear output');
ylabel('Input value');
title('Inverse Gamma');
subplot(1,3,3); hold on
plot(linearValues,clutValues(3,:)','b');
axis([0 1 0 1]); axis('square');
xlabel('Linear output');
ylabel('Input value');
title('Inverse Gamma');

% Make a plot of the obtained linear values.
figure; clf;
subplot(1,3,1); hold on
plot(linearValues,predValues(1,:)','r');
axis([0 1 0 1]); axis('square');
xlabel('Desired value');
ylabel('Predicted value');
title('Gamma Correction');
subplot(1,3,2); hold on
plot(linearValues,predValues(2,:)','g');
axis([0 1 0 1]); axis('square');
xlabel('Desired value');
ylabel('Predicted value');
title('Gamma Correction');
subplot(1,3,3); hold on
plot(linearValues,predValues(3,:)','b');
axis([0 1 0 1]); axis('square');
xlabel('Desired value');
ylabel('Predicted value');
title('Gamma Correction');

% Color space conversions  - CIE 1931
% Let's see how to do some standard color conversions

% Choose color matching functions.  Here CIE 1931, with a unit
% constant so that luminance is in cd/m2.
load T_xyz1931
T_xyz = 683*T_xyz1931;
calXYZ = SetSensorColorSpace(cal,T_xyz,S_xyz1931);

% Dump out min, mid, and max XYZ settings.  In general
% the calibration structure records the ambient light so
% that the min output is not necessarily zero light.
minXYZ = PrimaryToSensor(calXYZ,[0 0 0]'); minxyY = XYZToxyY(minXYZ);
midXYZ = PrimaryToSensor(calXYZ,[0.5 0.5 0.5]'); midxyY = XYZToxyY(midXYZ);
maxXYZ = PrimaryToSensor(calXYZ,[1 1 1]'); maxxyY = XYZToxyY(maxXYZ);
fprintf('Device properties in XYZ\n');
fprintf('\tMin xyY = %0.3g, %0.3g, %0.2f\n',minxyY(1),minxyY(2),minxyY(3));
fprintf('\tMid xyY = %0.3g, %0.3g, %0.2f\n',midxyY(1),midxyY(2),midxyY(3));
fprintf('\tMax xyY = %0.3g, %0.3g, %0.2f\n',maxxyY(1),maxxyY(2),maxxyY(3));

% Find actual settings to produce a desired colorimetric response.   Note
% that there are two ways to think about this.
%   a) If you've linearized the display using the lookup table, then pass
%   to the framebuffer the desiredPrimary triplet computed below.  This is
%   then mapped via the clut to produce the desired effect.
%   b) If you're maninpulating the clut directly, then you care what goes
%   into the clut entry corresponding to the region you're displaying.  In
%   that case, use the desiredSettings triplet computed below and stick it
%   into the clut.
% If you don't understand the distinction between a frame buffer and a
% lookup table, you might want to read Brainard, D. H., Pelli, D.G., and
% Robson, T. (2002). Display characterization. In the Encylopedia of Imaging
% Science and Technology. J. Hornak (ed.), Wiley. 172-188.  You can
% download a PDF from http://color.psych.upenn.edu/brainard/characterize.pdf.
desiredxyY = [0.4 0.3 40]';
desiredXYZ = xyYToXYZ(desiredxyY);
desiredPrimary = SensorToPrimary(calXYZ,desiredXYZ);
desiredSettings = SensorToSettings(calXYZ,desiredXYZ);
fprintf('To get xyY = %0.3g, %0.3g, %0.2f\n',desiredxyY(1),desiredxyY(2),desiredxyY(3))
fprintf('\tLinear weights on primaries should be %0.2g, %0.2g, %0.2g\n',desiredPrimary(1),desiredPrimary(2),desiredPrimary(3));
fprintf('\tActual settings values passed to driver (via clut) should be %0.2g, %0.2g, %0.2g\n',desiredSettings(1),desiredSettings(2),desiredSettings(3));

% Color space conversions - Cone space and isoluminance
% Now let's do some examples in cone space.  See DKLDemo for more
% colorimetric stuff.

% Load cone spectral sensitivities
load T_cones_ss2
T_cones = T_cones_ss2;
calLMS = SetSensorColorSpace(cal,T_cones,S_cones_ss2);

% Choose monitor white point as a background around which to modulate
bgPrimary = [0.55 0.45 0.5]';
bgLMS = PrimaryToSensor(calLMS,bgPrimary);

% Choose a modulation direction. [0 1 0] isolates the M cones.
directionLMS = [0 1 0]';

% Figure out maximum within gamut modulation in this direction.  This
% is best done in primary color space.  The calculation as executed below
% works even with non-zero ambient light and when the background is not
% in the middle of the device space.
%
% The resulting modulation +/- gamutScalar*directionLMS is symmetric around
% the background and takes us from the background exactly to the edge of the gamut.  
targetLMS = bgLMS+directionLMS;             
targetPrimary = SensorToPrimary(calLMS,targetLMS);
directionPrimary = targetPrimary-bgPrimary;
gamutScalar = MaximizeGamutContrast(directionPrimary,bgPrimary);
minLMS = bgLMS-gamutScalar*directionLMS;
maxLMS = bgLMS+gamutScalar*directionLMS;
minPrimary = SensorToPrimary(calLMS,minLMS);
maxPrimary = SensorToPrimary(calLMS,maxLMS);
minSettings = SensorToSettings(calLMS,minLMS);
maxSettings = SensorToSettings(calLMS,maxLMS);
contrastLMS1 = (maxLMS-bgLMS)./bgLMS;
contrastLMS2 = (maxLMS-minLMS)./(maxLMS+minLMS);
fprintf('Primary values at low edge of moduluation: %0.2f %0.2f %0.2f\n',minPrimary(1),minPrimary(2),minPrimary(3));
fprintf('Primary values at high edge of moduluation: %0.2f %0.2f %0.2f\n',maxPrimary(1),maxPrimary(2),maxPrimary(3));
fprintf('Cone contrast of modulation: %0.2f, %0.2f %0.2f\n',contrastLMS1(1),contrastLMS1(2),contrastLMS1(3));
if (max(abs(contrastLMS1-contrastLMS2)) > 1e-12)
    fprintf('Uh-oh, two ways of computing contrast don''t agree.\n');
end

end

