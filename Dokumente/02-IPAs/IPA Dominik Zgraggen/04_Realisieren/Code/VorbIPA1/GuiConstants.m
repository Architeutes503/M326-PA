classdef GuiConstants
    properties (Constant)
        
        % Foldernames of Projects
        ProDir = 'Projects';
        ApplDir = 'Application';
        CtrMdlDir = 'Control_Model';
        TsNetDir = 'TsNet';
        AddDir = 'Additional';
        
        % Simulation Error handling
        NoError = 0; 
        TsNet_ReadErr = 1;       % TsNet_Import
        TsNet_Keywords = 2;      % TsNet_Import
        CtrMdl_LoadErr = 3;      % TsNet_Sim
        SimRunErr = 4;           % TsNet_Sim
        Report_WriteErr = 5;     % TsNet_Report
    end
end