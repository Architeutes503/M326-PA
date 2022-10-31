%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GuiConstants
%       
%   This Class contains all Constants needed for IMSES_GUI.m and checkErr.m
%
% CHANGES:
% 9-04-2015 // Dominik Zgraggen, 5559 - Creation for IPA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef GuiConstants
    properties (Constant)
        
        % Foldernames of Projects
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
        
        % Gui Texts
        DefProjSel = 'Select existing Test-Project...';
        DefSheetSel = 'Select the Excel-Sheet...';
        CtrMdlSel = ['Bitte Modell auswählen, welches verwendet'...
            'werden soll (*.mdl)'];
        TsNetSel = 'Bitte TsNet-Excel-Sheet auswählen';
        
        %checkErr.m Strings
        ErrOK = '...';
        ErrRead = 'TsNet: Read Error!';
        ErrKeyW = 'Could not find Keywords in TsNet!';
        ErrLoadCtrMdl = 'Could not Load Control-Model';
        ErrSim = 'Simulation failed!';
        ErrRep = 'Could not write to Report-File';
        ErrUnknown = 'unknown Error!';
        Success = 'Simulation Successfully!';
        
        % Message-Box Strings
        ProjStrucTitle = 'invalid Project';
        ProjStruc = ['This Selection is not a valid Project. It hasn' ...
            '' 't got the Project-Folder-Structure'];
        NoMdlTitle = 'Wrong Filetype: need to be *.mdl';
        NoMdl = 'The selected File needs to be a Simulink-Model-File';
        NoXlsTitle = 'Wrong Filetype: need to be *.xls or *.xlsx';
        NoXls = 'The selected File needs to be a Excel-File';
        ErrOpnFile = 'Could not open File: ';
        ErrOpnFileTitle = 'Error open File';
        OpnProj = 'Could not open Path: '
        OpnProjTitle = 'Error Open Folder ';
        FailRun = 'Input is not as expected: ';
        FailRunTitle = 'Not ready for Simulation';    
        
        % Help-functions
        % HELP-Button
        HelpMes = ['Firstly, you should define where you '...
            'Work. A Test-Project collects your Files for a Test. ' ...
            char(10) 'After that you can select the Control-Model and'...
            ' the TsNet-File with the Sheet that contains the Testcase.'...
            'When RUN is pressed, the simulation will be made and after'...
            ' that you can evaluate the Report-File.'];
        HelpMesTitle = 'General Help';
        
        
    end
end