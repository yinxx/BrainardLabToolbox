% Method to analyze the loaded calStruct
function obj = analyze(obj, calStruct)

    if (strcmp(calStruct.describe.driver, 'object-oriented calibration'))
        % set the @Calibrator's cal struct. The cal setter method also sets 
        % various other properties of obj
        obj.cal = calStruct;
    else
        % set the @Calibrator's cal struct to empty
        obj.cal = [];
        % and notify user
        calStruct.describe
        fprintf('The selected cal struct was not generated by the object-oriented calibrator.\n');
        fprintf('Use mglAnalyzeMonCalSpd instead.\n');
        return;
    end
    
    obj.refitData();
    obj.plotAllData();
    
    % For old-style routines that expect an old-format calStruct
    % convert calStruct to old-format as below:
    % cal = Calibrator.calStructWithOldFormat(obj, calStruct);
    
    
end