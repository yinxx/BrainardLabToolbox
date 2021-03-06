% BrainardLabToolboxLocalHookTemplate
%
% Template for setting preferences and other configuration things, for the
% BrainardLabToolbox.

% 06/14/17  dhb, ar   Wrote it.
% 10/15/17  dhb       Only try to stick PTB java stuff on path if we can find the PTB.
% 10/9/17   npc       Added ptbBaseDir field and case for Nicolas' iMac
% 11/11/17  dhb       Add 'CalDataFolder' preference.

%% Define project
toolboxName = 'BrainardLabToolbox';

%% Clear out old preferences
if (ispref(toolboxName))
    rmpref(toolboxName);
end

%% Clear out prefs named 'ColorMaterialModel', if they exist
% 
% We used to have these, but decided not to anymore
if (ispref('ColorMaterialModel'))
    rmpref('ColorMaterialModel');
end

%% Specify project location
ptbBaseDir = tbLocateToolbox('BrainardLabToolbox');

% Figure out where baseDir for other kinds of data files is.
sysInfo = GetComputerInfo();
switch (sysInfo.localHostName)
    case 'eagleray'
        % DHB's desktop
        baseDir = fullfile(filesep,'Volumes','Users1','Dropbox (Aguirre-Brainard Lab)');
 
    case {'Manta', 'Manta-2'}
        % Nicolas's iMac
        baseDir = fullfile(filesep,'Volumes','DropBoxDisk/Dropbox','Dropbox (Aguirre-Brainard Lab)');
        
    otherwise
        % Some unspecified machine, try user specific customization
        switch(sysInfo.userShortName)
            % Could put user specific things in, but at the moment generic
            % is good enough.
            otherwise
                baseDir = ['/Users/' sysInfo.userShortName '/Dropbox (Aguirre-Brainard Lab)'];
        end
end

%% ColorMaterialModel preferences
%
% These preferences have to do with the ColorMaterialModel section of the
% BrainardLabToolbox
setpref(toolboxName,'cmmCodeDir',fullfile(ptbBaseDir,'ColorMaterialModel'));
setpref(toolboxName,'cmmDemoDataDir', fullfile(ptbBaseDir,'ColorMaterialModel','DemoData'));

%% RadiometerChecks preferences
%
% These preferences have to do with the RadiometerChecks section of the
% BrainardLabToolbox
setpref(toolboxName,'RadiometerChecksDir',fullfile(baseDir,'MELA_admin','RadiometerChecks'));

% Add PTB PsychJava to the path, if we can find the Psychtoolbox.
%% Find the toolbox location, the TbTb way.
ptbBaseDir = tbLocateToolbox('Psychtoolbox-3');
if (~isempty(ptbBaseDir))
    thePath = fullfile(ptbBaseDir,'Psychtoolbox','PsychJava');
    theMsg = 'Psychtoolbox/PsychJava';
    JavaAddToPath(thePath,theMsg);
end

% RadiometerChecks need access to GetWithDefault, which is a PTB function
setpref(toolboxName, 'ptbBaseDir', ptbBaseDir);

%% Calibration prefs
% 
% If there is a PsychCalLocalData folder that tbLocate can find, 
% we point at that. Otherwise this is set to empty.
%
% Specific projects can override this to have the calibration files
% written to a project specific location.
psychCalLocalData = tbLocateToolbox('PsychCalLocalData');
setpref(toolboxName,'CalDataFolder',psychCalLocalData);



