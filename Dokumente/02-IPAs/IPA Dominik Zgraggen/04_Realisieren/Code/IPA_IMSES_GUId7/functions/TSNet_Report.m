function [ErrState]=TSNet_Report(TSNetTestStruct)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TSNet_Report  
%      TSNet_Report creates a Report of the Results of a TSNet test for
%      further analyzation. 
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

%% Create Name of Excel Sheet
testcase_name=strrep(TSNetTestStruct.SheetName,' ','_');
xlsSheetName = ['R_',testcase_name];
XLSName = [TSNetTestStruct.XLSName(1:end-4),'.xls'];

%% fill TSNetTestStruct.XLSOut

% Grid
TSNetTestStruct.XLSOut=cell(10+length(TSNetTestStruct.TestStepDesc),3+3*length(TSNetTestStruct.OutputObj));

% Overview
TSNetTestStruct.XLSOut(1:10,1:3)={'TSNet Test in Simulink',NaN,NaN;NaN,NaN,NaN;'Source XLS:',NaN,NaN;'Testcase:',NaN,NaN;'Simulation Model:',NaN,NaN;'Testfolder:',NaN,NaN;NaN,NaN,NaN;'Results:',NaN,NaN;NaN,NaN,NaN;'Stepnumber','Waitingtime','Stepdescription';};

% Test Information
TSNetTestStruct.XLSOut(3,2)={TSNetTestStruct.XLSName};
TSNetTestStruct.XLSOut(4,2)={TSNetTestStruct.SheetName};
TSNetTestStruct.XLSOut(5,2)={TSNetTestStruct.MdlName};
TSNetTestStruct.XLSOut(6,2)={TSNetTestStruct.TestFolder};

endcolumn=10+length(TSNetTestStruct.TestStepDesc);
% Fill teststeps
for i=1:(endcolumn-10)
    
    TSNetTestStruct.XLSOut(10+i,1)={i};
    TSNetTestStruct.XLSOut(10+i,2)={TSNetTestStruct.RWTime(i+1)-TSNetTestStruct.RWTime(i)};
    TSNetTestStruct.XLSOut(10+i,3)=TSNetTestStruct.TestStepDesc(i);
end

% Fill with values, Passed/Failed indicator
for i=1:length(TSNetTestStruct.OutputObj)
    
    for j = 1:length(TSNetTestStruct.TestStepDesc)
        
        if TSNetTestStruct.OutputObj(i).Passed(:,j)
            textPassed{j}='Passed';
        else
            textPassed{j}='FAILED';
        end
        
        ExpectedValue{j}=[];
        ResultVal{j}=[];
       
        % loop over Dimension for vector handling
        for k=1:TSNetTestStruct.OutputObj(i).Dimension
                        
            % Abort and write nothing if no expected value is specified in
            % test
            if TSNetTestStruct.OutputObj(i).LowerValue(k,j) == -1
                % write NaN
                ExpectedValue{j}=NaN;
                ResultVal{j}= NaN;
                break;
            end
            
            % Temporare storage of Result
            tmpR{k}= num2str(TSNetTestStruct.OutputObj(i).ReadValue(k,j));

            % Expected Value: Add intervalls again
            if TSNetTestStruct.OutputObj(i).LowerValue(k,j) == TSNetTestStruct.OutputObj(i).UpperValue(k,j)
                tmpE{k} = num2str(TSNetTestStruct.OutputObj(i).LowerValue(k,j));
            else
                tmpE{k} = [num2str(TSNetTestStruct.OutputObj(i).LowerValue(k,j)),'...',num2str(TSNetTestStruct.OutputObj(i).UpperValue(k,j))];
            end
            
            % Store temporary values in cell arrays
            
            if k == 1
                ExpectedValue{j} = [tmpE{k}];
                ResultVal{j}     = [tmpR{k}];
            else
                ExpectedValue{j} = [ExpectedValue{j},'/',tmpE{k}];
                ResultVal{j}     = [ResultVal{j},'/',tmpR{k}];
            end
        end
            
        
                
    end

    
    % Indicator if all Values of Test have passed
    if TSNetTestStruct.OutputObj(i).Passed
        textPassedTot = 'All Passed!';
    else
        textPassedTot = 'FAILED';
    end
    
    % Fill Expected Values
    TSNetTestStruct.XLSOut(8:9,4+(i-1)*4) = [{'ObjectID:'};{'Property-ID'}];
    TSNetTestStruct.XLSOut(8:endcolumn,5+(i-1)*4)=[{TSNetTestStruct.OutputObj(i).ObjID}; {TSNetTestStruct.OutputObj(i).PropID} ; {'Expected Value'} ; ExpectedValue'];
    % Fill Measured Values
    TSNetTestStruct.XLSOut(10:endcolumn,6+(i-1)*4)=[{'Result Test'} ; ResultVal'];
    % Fill Pass/Fail indicators
    TSNetTestStruct.XLSOut(10:endcolumn,7+(i-1)*4)=[textPassedTot; textPassed'];

end

% Save to folder
save('TSNetTestStruct.mat','TSNetTestStruct');


try
    %Write to XLS of test
    xlswrite(XLSName,TSNetTestStruct.XLSOut,xlsSheetName);
    ErrState = 0;
catch
    ErrState = GuiConstants.Report_WriteErr;
    return
end

end

