function runModulationTrialSequencePupillometryNulled

    experimentMode = false;
    
    [rootDir, ~] = fileparts(fullfile(which(mfilename)));
    cd(rootDir); addpath('../Common');
    
    clc
    fprintf('\nStarting ''%s''\n', mfilename);
    fprintf('Hit enter when the windowsClient is up and running.\n');
    pause;
    
    % Instantiate a UDPcommunictor object
    udpParams = getUDPparams('NicolasOffice');
    UDPobj = UDPcommunicator( ...
          'localIP', udpParams.macHostIP, ...
         'remoteIP', udpParams.winHostIP, ...
          'udpPort', udpParams.udpPort, ...      % optional with default 2007
        'verbosity', 'min' ...             % optional with possible values {'min', 'normal', 'max'}, and default 'normal'
        );
    
    params.protocolName = 'ModulationTrialSequencePupillometryNulled';
    [communicationError] = OLVSGSendProtocolName(UDPobj, params.protocolName);
    assert(isempty(communicationError), 'Exit due to communication error.\n');

    
            
end

function [communicationError] = OLVSGSendProtocolName(UDPobj, protocolName)
    % Reset return args
    communicationError = [];
    
    % Message label we are sending
    messageLabel = 'Protocol Name2';
    
    % Get this function's name
    dbs = dbstack;
    if length(dbs)>1
        functionName = dbs(1).name;
    end
    
    status = UDPobj.sendMessage(messageLabel, 'withValue', protocolName, 'timeOutSecs', 2, 'maxAttemptsNum', 3, 'callingFunctionName', functionName);
    % check status for errors
    if (~strcmp(status, UDPobj.TRANSMITTED_MESSAGE_MATCHES_EXPECTED)) 
        communicationError = sprintf('Transmitted and expected (by the other end) messages do not match! sendMessage() returned with this message: ''%s''\n', status);
    end
end
