function [TSNetTestStruct]=TSNet_Evaluation(TSNetTestStruct)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TSNet_Evaluation  
%      TSNet_Evaluation evaluates a TSNet Test by comparing Output of the
%      simulation and expected output from the TSNet Test Excel file.
%
%      INPUTS
%      TSNetTest            Struct with TSNet Test Information
%
%      OUTPUTS:
%      TSNetTest            Struct with TSNet Test Information
%
%      This function is called by "TSNet_Test" when called
%      through the TSNet Gui.
%
% CHANGES:
% 14-01-2015 // Created by Wolfgang Schneider (rework of tsnet_test_v1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% constants
SIG_LENGTH = 5; % Length of output vector for one BA Object 
                %(is only fully used in special cases)
                
TOL = 10e-4;    % Tolerance for time differences

%% Convert Simulation Output

% Generate ReadTimeVector
% The data for Teststep i should be extracted (WaitingTime(i)-0.2) seconds 
% after the input of Teststep i was written 
ReadTime = TSNetTestStruct.RWTime(2:end)-0.2;

simTime = TSNetTestStruct.SimOut.t;
simValues = TSNetTestStruct.SimOut.y;

% Make ReadValues Matrix, which has only the simValues at the ReadTime
% elements. 
j=1;

for i = 1:length(simTime)
    if abs(ReadTime(j) - simTime(i)) < TOL
        ReadValue(j,:) = simValues(i,:);
        
        if j == length(ReadTime)
            break;
        end
        
        j=j+1;        
        
    end
end

% Value for moving through ReadValue Matrix
ReadInd=1; 

for i = 1:length(TSNetTestStruct.OutputObj)
    

    
    for j = 1:length(ReadTime)
        
        % iterate over dimension of value
        for k = 1:TSNetTestStruct.OutputObj(i).Dimension
            
            % only assign ReadValue, if a ReadOperation should be performed    
            if abs(TSNetTestStruct.OutputObj(i).EnableT(j) - ReadTime(j)) < TOL
                TSNetTestStruct.OutputObj(i).ReadValue(k,j) = ReadValue(j,ReadInd+(k-1));
            else
                TSNetTestStruct.OutputObj(i).ReadValue(k,j) = -1;
            end
            
            % Is value >= lowerbound and <= upper bound?
            
            if (TSNetTestStruct.OutputObj(i).LowerValue(k,j) <= TSNetTestStruct.OutputObj(i).ReadValue(k,j) &&...
                TSNetTestStruct.OutputObj(i).UpperValue(k,j) >= TSNetTestStruct.OutputObj(i).ReadValue(k,j))
            
                TSNetTestStruct.OutputObj(i).Passed(k,j) = 1;
            
            else
                
                TSNetTestStruct.OutputObj(i).Passed(k,j) = 0;
                
            end
            
        end
        
    end
    
    ReadInd=ReadInd+SIG_LENGTH;
    
end
        
        
% Save to folder
save('TSNetTestStruct.mat','TSNetTestStruct');

end