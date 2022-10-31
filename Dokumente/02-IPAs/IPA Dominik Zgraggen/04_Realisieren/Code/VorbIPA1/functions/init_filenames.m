%% Init_GuiNamen
    
%% GUI Filenamen

% % GUI-Versionen definieren
    % % Name der verschiedenen GUIs definieren
    initparam.filenameGUI_Start='GUITSNet_Start_final';
    initparam.filenameGUI_Simulation='GUITSNet_Simulation_final';
    initparam.filenameGUI_Evaluation='GUITSNet_Evaluation_final';
    
% % Übergeordneter Workpath, in welchem alle benötigten Ordner für das
% % Arbeiten sind
    initparam.workpath = 'C:\Users\z003019m\ABT Function Blocks Simulation\TSNetExperimente\';
    

% % Pfad in welchem die Inputfiles sind (Modelle, Excel-Files
    initparam.input =  'C:\Users\z003019m\ABT Function Blocks Simulation\TSNetExperimente\input\';
% % Pfad in welchem die bearbeiteteten Daten sind    
    initparam.output = 'C:\Users\z003019m\ABT Function Blocks Simulation\TSNetExperimente\output\';
% % Pfad in welchem die Daten gespeichert werden sollen = Pfad der Reports
    initparam.results = 'C:\Users\z003019m\ABT Function Blocks Simulation\TSNetExperimente\results\';
% % Pfad, in welchem die die TSNET-Templates liegen
    initparam.templates = 'C:\Users\z003019m\ABT Function Blocks Simulation\TSNetExperimente\templates';
        
     initparam.savename = 'emtpy';
%     initparam.function.createmdl = 'newTSNetCtrlMdl(inputString,outputString)';
%     
    % % Für Testzwecke
%     inputString={'Rm_1_Test_PltOpMod_PrVal_value';'Rm_1_Test_PltOpMod_PrVal_prio';};
%     outputString={'Rm_1_Test_HclDevMod_PrVal';'Rm_1_Test_HclDevMod_PrPrio';'Rm_1_Test_DmpDevModSu_PrVal';'Rm_1_Test_DmpDevModSu_PrPrio';'Rm_1_Test_DmpDevModEx_PrVal';'Rm_1_Test_DmpDevModEx_PrPrio';};
%     
%     
    % % Format des szenariospezifischen File
    try
    cd(initparam.workpath);
    catch
       edit init_filenames.m
        helpdlg('Es scheint, als ob der eingestellte Arbeitspfad nicht gefunden wird, bitte geben Sie den korrekten Pfad an und führen Sie das Skript erneut aus bevor Sie mit dem GUI arbeiten','Arbeitspfad nicht gefunden') 
      
    end
    
    
    
    
    
    
    
    
    