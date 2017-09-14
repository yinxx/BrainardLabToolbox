function demoUDPcommunicator

    %% Define the host names, IPs, and roles
    % In this demo we have IPs for manta.psych.upenn.edu and ionean.psych.upenn.edu
    hostNames = {'manta',        'ionean'};
    hostIPs   = {'128.91.12.90', '128.91.12.144'};
    hostRoles = {'slave',        'master'};
    
    %% Make a protocol of communication
    protocolA = makeProtocolA(hostNames);
    
    %% Run the protocol
    messageList = runProtocol(hostNames, hostIPs, hostRoles, protocolA)
    
    disp('Hit enter to run the next protocol');
    pause;
    
    %% Reverse the host roles in protocolA
    hostRoles = {'master', 'slave'};
    messageList = runProtocol(hostNames, hostIPs, hostRoles, protocolA)
    
end

    

function messageList = runProtocol(hostNames, hostIPs, hostRoles, commProtocol)

    %% Clear the command window
    clc
      
    %% Instantiate a UDPcommunicator object according to computer name
    systemInfo = GetComputerInfo();
    UDPobj = instantiateUDPcomObject(systemInfo.networkName, hostNames, hostIPs, 'beVerbose', false);
    
    %% Initiate the communication protocol
    initiateCommunication(UDPobj, systemInfo.networkName, hostRoles,  hostNames);

    %% Run the communication protocol
    for commStep = 1:numel(commProtocol)
         messageList{commStep} = communicate(UDPobj, systemInfo.networkName, commStep, commProtocol{commStep}, 'beVerbose', false);
    end
        
    %% Shutdown the UDPobj
    fprintf('\nAll done\n');
    UDPobj.shutDown();
end


function commProtocol = makeProtocolA(hostNames)
    % Define the communication  protocol
    commProtocol = {};
    commProtocol{numel(commProtocol)+1} = makePacket(hostNames,...
        'manta -> ionean', struct('label', 'test1', 'value', 1));

    commProtocol{numel(commProtocol)+1} = makePacket(hostNames,...
        'manta <- ionean', struct('label', 'test2', 'value', -2.34));
    
    commProtocol{numel(commProtocol)+1} = makePacket(hostNames,...
        'ionean <- manta', struct('label', 'test3', 'value', true));
    
    commProtocol{numel(commProtocol)+1} = makePacket(hostNames,...
        'ionean -> manta', struct('label', 'test4', 'value', false));
    
    commProtocol{numel(commProtocol)+1} = makePacket(hostNames,...
         'ionean -> manta', struct('label', 'test5', 'value', 'bye now'));
    
    commProtocol{numel(commProtocol)+1} = makePacket(hostNames,...
        'ionean -> manta', struct('label', 'test6', 'value', 1));

    commProtocol{numel(commProtocol)+1} = makePacket(hostNames,...
        'ionean -> manta', struct('label', 'test7', 'value', 1));
    
end

function UDPobj = instantiateUDPcomObject(localHostName, hostNames, hostIPs, varargin)

    % Parse optinal input parameters.
    p = inputParser;
    p.addParameter('beVerbose', false, @islogical);
    p.parse(varargin{:});
    beVerbose = p.Results.beVerbose;
    
    if (beVerbose)
        verbosity = 'max';
    else
        verbosity = 'min';
    end
    
    if (strfind(localHostName, hostNames{1}))
        UDPobj = UDPcommunicator( ...
            'localIP',   hostIPs{1}, ...        % REQUIRED: the IP of manta.psych.upenn.edu (local host)
            'remoteIP',  hostIPs{2}, ...        % REQUIRED: the IP of ionean.psych.upenn.edu (remote host)
            'verbosity', verbosity, ...          % OPTIONAL, with default value: 'normal', and possible values: {'min', 'normal', 'max'},
            'useNativeUDP', false ...           % OPTIONAL, with default value: false (i.e., using the brainard lab matlabUDP mexfile)
        );
    elseif (strfind(localHostName, hostNames{2}))
        UDPobj = UDPcommunicator( ...
        'localIP',   hostIPs{2}, ...            % REQUIRED: the IP of ionean.psych.upenn.edu (local host)
        'remoteIP',  hostIPs{1}, ...            % REQUIRED: the IP of manta.psych.upenn.edu (remote host)
        'verbosity', verbosity, ...              % OPTIONAL, with default value: 'normal', and possible values: {'min', 'normal', 'max'},
        'useNativeUDP', false ...               % OPTIONAL, with default value: false (i.e., using the brainard lab matlabUDP mexfile)
        );
    else
        error('No configuration for computer named ''%s''.', systemInfo.networkName);
    end
end

function initiateCommunication(UDPobj, localHostName, hostRoles, hostNames)

    beVerbose = true;
    triggerMessage = struct(...
        'label', 'GO !', ...
        'value', 'now' ...
        );
    
    if (strcmp(hostRoles{1}, 'master'))
        masterHostName = hostNames{1};
    elseif (strcmp(hostRoles{2}, 'master'))
        masterHostName = hostNames{2};
    else
        error('There is no master role in hostRoles');
    end
    
    if (strcmp(hostRoles{1}, 'slave'))
        slaveHostName = hostNames{1};
    elseif (strcmp(hostRoles{2}, 'slave'))
        slaveHostName = hostNames{2};
    else
        error('There is no slave role in hostRoles');
    end
    
    assert(ismember(masterHostName, hostNames), sprintf('master host (''%s'') is not a valid host name.\n', masterHostName));
    assert(ismember(slaveHostName, hostNames), sprintf('slave host (''%s'') is not a valid host name.\n', slaveHostName));
    
    if (beVerbose)
        fprintf('<strong>Setting ''%s'' as MASTER and ''%s'' as SLAVE</strong>\n', masterHostName, slaveHostName);
    end
    
    if (strfind(localHostName, slaveHostName))
        % Wait for ever to receive the trigger message from the master
        receive(UDPobj, triggerMessage, Inf);
    elseif (strfind(localHostName, masterHostName))
        fprintf('Is ''%s'' running on the slave (''%s'') computer?. Hit enter if so.\n', mfilename, slaveHostName); pause; clc;
        % Send trigger and wait for up to 4 seconds to receive acknowledgment
        timeoutForAcknowledgment = 4;
        attemptsNo = 3;
        transmit(UDPobj, triggerMessage, timeoutForAcknowledgment, attemptsNo);
    else
        error('Local host name (''%s'') does not match the slave (''%s'') or the master (''%s'') host name.', localHostName, slaveHostName, masterHostName);
    end
end


function packet = makePacket(hostNames, direction, message, varargin) 
    % Parse optinal input parameters.
    p = inputParser;
    p.addParameter('timeoutSecsForAckReceipt',  5, @isnumeric);
    p.addParameter('timeoutSecsForReceivingExpectedPacket',  Inf, @isnumeric);
    p.addParameter('attemptsNo', 1, @isnumeric);
    p.parse(varargin{:});
   
    % validate direction
    assert((contains(direction, '->')) || (contains(direction, '<-')), sprintf('direction field does not contain correct direction information: ''%s''.\n', direction));
    assert(contains(direction, hostNames{1}), sprintf('direction field does not contain correct host name: ''%s''.\n', direction));
    assert(contains(direction, hostNames{2}), sprintf('direction field does not contain correct host name: ''%s''.\n', direction));
    
    packet = struct(...
        'direction', direction, ...
        'message', message, ...
        'attemptsNo', p.Results.attemptsNo, ...                               % How many times to re-transmit if we did not get an ACK within the receiveTimeOut
        'transmitTimeOut', p.Results.timeoutSecsForAckReceipt, ...            % Timeout for receiving an ACK in response to a transmitted message
        'receiveTimeOut', p.Results.timeoutSecsForReceivingExpectedPacket ... % Timeout for waiting to receive a regular message
    );
end

function messageReceived = communicate(UDPobj, computerName, packetNo, communicationPacket, varargin)
    % Set default return argument
    messageReceived = [];
    
    % Parse optinal input parameters.
    p = inputParser;
    p.addParameter('beVerbose', false, @islogical);
    p.parse(varargin{:});
    beVerbose = p.Results.beVerbose;
    
    p = strfind(computerName, '.');
    computerName = computerName(1:p(1)-1);
    hostEntry = strfind(communicationPacket.direction, computerName);
    rightwardArrowEntry = strfind(communicationPacket.direction, '->');
    
    if (~isempty(rightwardArrowEntry))
        if (hostEntry < rightwardArrowEntry)
            if (beVerbose)
                fprintf('\n%s is sending the %d-th packet\n', computerName, packetNo);
            end
            transmit(UDPobj, communicationPacket.message, communicationPacket.transmitTimeOut, communicationPacket.attemptsNo);
            if (beVerbose)
                fprintf('\n%s sent the %d-th packet\n', computerName, packetNo);
            end
        else
            if (beVerbose)
                fprintf('\n%s is waiting to receive the %d-th packet\n', computerName, packetNo);
            end
            messageReceived = receive(UDPobj, communicationPacket.message, communicationPacket.receiveTimeOut);
            if (beVerbose)
                fprintf('\n%s received the %d-th packet\n', computerName, packetNo);
            end
        end
    else
        leftwardArrowEntry = strfind(communicationPacket.direction, '<-');
        if (isempty(leftwardArrowEntry))
            error('direction field does not contain correct direction information: ''%s''.\n', communicationPacket.direction);
        end
        if (hostEntry < leftwardArrowEntry)
            if (beVerbose)
                fprintf('\n%s is waiting to recieve the %d-th packet\n', computerName, packetNo);
            end
            messageReceived = receive(UDPobj, communicationPacket.message, communicationPacket.receiveTimeOut);
            if (beVerbose)
                fprintf('\n%s received the %d-th packet\n', computerName, packetNo);
            end
        else
            if (beVerbose)
                fprintf('\n%s is sending the %d-th packet\n', computerName, packetNo);
            end
            transmit(UDPobj, communicationPacket.message, communicationPacket.transmitTimeOut, communicationPacket.attemptsNo);
            if (beVerbose)
                fprintf('\n%s sent the %d-th packet\n', computerName, packetNo);
            end
        end
    end
end

% Method that waits to receive a message
function messageReceived = receive(UDPobj, expectedMessage, receiverTimeOutSecs)  
    % Start listening
    messageReceived = UDPobj.waitForMessage(expectedMessage.label, ...
        'timeOutSecs', receiverTimeOutSecs...
        );
end

% Method that transmits a message and waits for an ACK
function transmit(UDPobj, messageToTransmit, acknowledgmentTimeOutSecs, attemptsNo)
    % Send the message
    status = UDPobj.sendMessage(messageToTransmit.label, messageToTransmit.value, ...
        'timeOutSecs', acknowledgmentTimeOutSecs, ...
        'maxAttemptsNum', attemptsNo ...
    );
    assert(~strcmp(status,'TIMED_OUT_WAITING_FOR_ACKNOWLEDGMENT'), 'Timed out waiting for acknowledgment');
end

