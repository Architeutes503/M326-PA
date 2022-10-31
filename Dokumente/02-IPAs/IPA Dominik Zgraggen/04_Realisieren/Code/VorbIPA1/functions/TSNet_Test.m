function TSNet_Test(XLSName,SheetName,MdlName,handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TSNet_Test  
%      TSNET_TEST is the managing code for running an automated TSNet
%      test with Matlab.
%
%      INPUTS
%      XLSName              Name of the excel file with the TSnet test
%      SheetName            Name of the excel sheet with the testcase
%      MdlName              Name of the TSNET Model for the testcase
%
%      OUTPUTS:
%      [none]
%
%      This function is called by "GUITSNet_Simulation_final.m" when called
%      through the TSNet Gui.
%
% CHANGES:
% 14-01-2015 // Created by Wolfgang Schneider (rework of tsnet_test_v1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initiate TSNet Struct

TSNetTestStruct           = struct(       'RWTime',        0,...
                                          'InputObj',      'empty',...
                                          'OutputObj',     'empty',...
                                          'SimIn',         'empty',...
                                          'SimOut',        'empty',...
                                          'TestStepDesc',  'empty',...
                                          'MdlName',       'empty',...
                                          'XLSName',       'empty',...
                                          'SheetName',     'empty',...
                                          'TestFolder',    'empty');

TSNetTestStruct.InputObj  = struct(       'Name',          'empty',...
                                          'ObjTypeNr',     0,...
                                          'ObjID',         0,...
                                          'PropID',        0,...
                                          'Value',         0,...
                                          'Prio',          0,...
                                          'EnableT',       0);
                              
TSNetTestStruct.OutputObj = struct(       'Name',          'empty',...
                                          'ObjTypeNr',     0,...
                                          'ObjID',         0,...
                                          'PropID',        0,...
                                          'LowerValue',    0,...
                                          'UpperValue',    0,...
                                          'EnableT',       0,...
                                          'ReadValue',     0,...
                                          'Passed',        0,...
                                          'Dimension',     0);

% Save testpath
TSNetTestStruct.XLSName   = XLSName;
TSNetTestStruct.SheetName = SheetName;
TSNetTestStruct.MdlName   = MdlName;

%% Initiate TestFolder

try
    if isdir([handles.GuiProperties.ProjectPath '\' GuiConstants.ReportDir])
        TSNetTestStruct.TestFolder = [handles.GuiProperties.ProjectPath '\' GuiConstants.ReportDir];        % path exists
    end
catch
        TSNetTestStruct.TestFolder=cd;
end
addpath(TSNetTestStruct.TestFolder);

%% Create a waitbar object to report the progress
hwaitbar = waitbar(0,'Running TSNet Test..');

%% Error State init
ErrState = 0;

%% Import Data

[TSNetTestStruct, ErrState]=TSNet_Import(TSNetTestStruct); 
checkErr(ErrState, handles, hwaitbar)
   
%% Run Simulation

% run simulation
[TSNetTestStruct, ErrState]=TSNet_Sim(TSNetTestStruct);
checkErr(ErrState, handles, hwaitbar)

% update waitbar
waitbar(1/4,hwaitbar,'Running TSNet Test..');

%% Evaluation of Results

% update waitbar
waitbar(2/4,hwaitbar,'Evaluate Results...')
[TSNetTestStruct]=TSNet_Evaluation(TSNetTestStruct);


%% Create Report

% update waitbar
waitbar(3/4,hwaitbar,'Creating Report..');

%% Finish Test

% update waitbar
waitbar(4/4,hwaitbar,'Report created, TSNet test finished..');
[ErrState] = TSNet_Report(TSNetTestStruct);
checkErr(ErrState, handles, hwaitbar)

if ErrState == 0 
    set(handles.txt_SimState, 'String', 'Simulation Successfully');
end
% Delete the waitbar object
delete(hwaitbar);

end % FUNCTION