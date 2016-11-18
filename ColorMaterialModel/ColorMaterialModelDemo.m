% ColorMaterialModelDemo.m
%
% Demonstrates color material MLDS model itting procedure for a data set.
% Initially used as a test bed for testing and improving search algorithm.
%
% The work is done by other routines in this folder. 
%
% Requires optimization toolbox.
%
% 11/18/16  ar  Wrote from selection model version

%% Initialize and parameter set
clear ; close all;
DEMO = true;
saveFig = 0;

%% We can use simulated data (DEMO == true) or some real data (DEMO == false)
if (DEMO)
    % Make a stimulus list and set underlying parameters.
    targetM = 0; 
    targetC = 0; 
    stimuliC = [];
    stimuliM = [];
    cDistances = [-3, -2, -1, 0, 1, 2, 3];
    mDistances = [-3, -2, -1, 0, 1, 2, 3];
    sigma = 1;
    w = 0.5; 
    
    % These are the material matches that vary in color.
    for i = 1:length(cDistances)   
        stimuliC = [stimuliC, {[cDistances(i), targetM]}];
    end
    
    % These are the color matches that vary in material
    for i = 1:length(mDistances)
        stimuliM = [stimuliM, {[targetC, mDistances(i)]}];
    end
    
    % Simulate the data
    %
    % Initialize the response structure
    cIndex = 1;
    mIndex = 2;
    nBlocks = 24;
    response  = zeros(length(cDistances),length(mDistances));
    pairIndices = []; 
    pairSpecs = []; 
    
    % Loop over blocks and stimulus pairs and simulate responses
    %
    % We pair each color stimulus with each material stimulus
    for b = 1:nBlocks
        for whichColor = 1:length(cDistances)
            for whichMaterial = 1:length(mDistances)
                clear pair
                pair = {stimuliM{whichMaterial},stimuliC{whichColor}};
                
                % Set up matrices of indices that will allow us to relate the
                % stimuli and the reponse matrix.
                % We only need to do this on the first block,
                % since it is the same on each block in this simulation.
                if b == 1
                    pairColorMatrix(whichColor,whichMaterial) = whichColor;
                    pairMaterialMatrix(whichColor,whichMaterial) = whichMaterial;
                end
                
                % Simulate out what the response is for this pair in this
                % block.
                %
                % Note that the first competitor passed is always a color
                % match that differs in material. so the response1 == 1
                % means that the color match was chosen
                response1(whichColor,whichMaterial) = ColorMaterialModelSimulateResponse(targetC, targetM, pair{1}(cIndex), pair{2}(cIndex), pair{1}(mIndex), pair{2}(mIndex), sigma, w);
            end
        end
        
        % Track cummulative response over blocks
        response = response+response1;
        clear response1
    end
    
    % String the response matrix as well as the pairMatrices out as vectors. 
    theResponses = response(:);
    pairIndices(:,1) = pairColorMatrix(:);
    pairIndices(:,2) = pairMaterialMatrix(:);
    
    % Total number of trials run for every row of competitorIndices.
    % Number of columns here should match the number of columns in
    % someData.
    nTrials = nBlocks*ones(size(theResponses)); 
    
% Here you could enter some real data and work on figuring out why a model
% fit was going awry.
else
    
    pairIndices = [
        ];
    
    theResponses = [
        ];

    nTrials = [
        ];
end

% Need to unpack this here!
[returnParams, logLikelyFit, predictedResponses] = ColorMaterialModelMain(pairIndices,theResponses,nTrials); %#ok<SAGROW>


