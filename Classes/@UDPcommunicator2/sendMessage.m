function transmissionStatus = sendMessage(obj, msgLabel, msgData, varargin)
    p = inputParser;
    
    % the msgLabel is required
    addRequired(p,'msgLabel',@ischar);
    
    % the msgData is required
    addRequired(p, 'msgData');
    
    % the timeOutSecs is optional, with a default value: 5
    addOptional(p,'timeOutSecs', 5, @isnumeric);
    p.addOptional('timeOutAction', obj.NOTIFY_CALLER, @(x)((ischar(x)) && ismember(x, {obj.NOTIFY_CALLER, obj.THROW_ERROR}))); 
    addOptional(p,'maxAttemptsNum',1, @isnumeric);
    
    % parse the input
    parse(p, msgLabel, msgData, varargin{:});

    messageLabel = p.Results.msgLabel;
    messageData  = p.Results.msgData;
    timeOutSecs  = p.Results.timeOutSecs;
    timeOutAction = p.Results.timeOutAction;
    maxAttemptsNum = p.Results.maxAttemptsNum;
    
    % Send the leading message label
    matlabUDP('send', messageLabel);
    
    % Serialize data
    byteStream = getByteStreamFromArray(messageData);
     
    % Send number of bytes to read
    matlabUDP('send', sprintf('%d', numel(byteStream)));
        
    % Send each byte separately
    for k = 1:numel(byteStream)
       matlabUDP('send',sprintf('%03d', byteStream(k)))
    end
    
    % Send the trailing message label
    matlabUDP('send', messageLabel);
       
    % Wait for acknowledgment that the message was received OK
    timedOutFlag = obj.waitForMessageOrTimeout(timeOutSecs);
    if (timedOutFlag)
        executeTimeOut(obj, 'while waiting to receive acknowledgment for message sent', timeOutAction);
        transmissionStatus = obj.NO_ACKNOWLDGMENT_WITHIN_TIMEOUT_PERIOD;
        return;
    else
        transmissionStatus = matlabUDP('receive');
    end
end

