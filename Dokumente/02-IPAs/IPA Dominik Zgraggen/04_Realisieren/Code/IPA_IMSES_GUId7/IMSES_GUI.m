function varargout = IMSES_GUI(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IMSES_GUI 
%   IMSES_GUI MATLAB code for IMSES_GUI.fig. If the Tool should be started,
%   RUN this file in MATLAB. the Subfolders: Projects, functions are
%   needed. Also GuiConstants.m is needed.
%   There are Two Parts: 
%   - Callback-Functions (gets called from btn (=Button) or drp (=Dropdown)
%   - Additional-Functions (Code is used more than once
%      and/or less Code in Callback)
%
%   INPUT: varargin   command line arguments to IMSES_GUI (see VARARGIN)
%
% CHANGES:
% 9-04-2015 // Dominik Zgraggen, 5559 - Creation for IPA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @IMSES_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @IMSES_GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before IMSES_GUI is made visible.
function IMSES_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to IMSES_GUI (see VARARGIN)

% Choose default command line output for IMSES_GUI
    handles.output = hObject;

    % struct contains Data such as Path (collects the Variable)
    handles.GuiProperties = struct( ... 
        'BasePath', '',... % Matlab-File root
        'ProjectPath', '',... % Users ProjectPath
        'ProjectName', '',... % Name of Project (also Foldername)
        'Mdl_File', '',... % Users Control-Model - full filepath
        'SelectedSheet', '',... % name of Excel-Sheet in TsNet-File
        'TsNet_File', '');  % Users TsNet-File - full filepath
    
    % find BasePath - where is this Matlab-File?
    [pathstr] = fileparts(which('IMSES_GUI.m'));
    handles.GuiProperties.BasePath = pathstr;
                                      
    % find all Projects for Drowdown: drp_SelProj
    folders = dir([handles.GuiProperties.BasePath '\Projects']); % find folderlist
    foldernames = {folders.name};   
    i = 0;
        
    while i < length(foldernames)   % remove unexisting Folders
        if strfind(foldernames{i+1}, '.')
            foldernames{i+1} = [];            
        end
        i = i + 1;
    end
        
    foldernames = foldernames(~cellfun('isempty',foldernames));  
    arr = [GuiConstants.DefProjSel foldernames]; % add default
    set(handles.drp_SelProj, 'String', arr); % set Dropdown item
    
    % set Properties, Data stil there? (Matlab not closed)
    handles.GuiProperties.ProjectPath = get(handles.txt_WorkPath, 'String');
    handles.GuiProperties.Mdl_File = get(handles.txt_CtrMdlPath, 'String');
    handles.GuiProperties.TsNet_File = get(handles.txt_TsNetPath, 'String');
    
    % Dropdowns
    handles.GuiProperties.ProjectName = ...
    getDrpSelItem(handles.drp_SelProj, GuiConstants.DefProjSel);

    updateGUI(hObject, eventdata, handles)
    
    % Update handles structure
    guidata(hObject, handles);
end

% --- Outputs from this function are returned to the command line.
function varargout = IMSES_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

end

end % IMSES_GUI needs to be closed here


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% CALLBACK-FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Functionname-convention: Type_Tag_Function()

%% PARAMETER %%
% hObject    handle to txt_CtrMdlPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% global Help shows Workflow-Information 
function btn_help_Callback(hObject, eventdata, handles)
    msgbox(GuiConstants.HelpMes, GuiConstants.HelpMesTitle);
end 

% shows Project specific Information 
function btn_QProj_Callback(hObject, eventdata, handles)

end

% shows Control-Model specific Information 
function btn_QCtrMdl_Callback(hObject, eventdata, handles)

end

% shows TsNet specific Information 
function btn_QTsNet_Callback(hObject, eventdata, handles)

end

% shows Simulation and Report specific Information 
function btn_QSim_Callback(hObject, eventdata, handles)

end

% btn_LoadProj_Callback is called ,when "Load"-Button was pressed
% loads files of the project, which is selected in drp_SelProj 
function btn_LoadProj_Callback(hObject, eventdata, handles)
    %get string of the item 
    items = get(handles.drp_SelProj,'String');
    drp_index = get(handles.drp_SelProj,'Value');
    drp_item = items{drp_index};
    path = [handles.GuiProperties.BasePath '\Projects\' drp_item];
    noPro = 0;
      
  if isdir(path) == 1
      % check if folder has Project structur
      if isdir([path '\' GuiConstants.ApplDir]) ~= 1 
          noPro = 1;
      elseif isdir([path '\' GuiConstants.CtrMdlDir]) ~= 1
          noPro = 1;
      elseif isdir([path '\' GuiConstants.TsNetDir]) ~= 1
          noPro = 1;
      elseif isdir([path '\' GuiConstants.AddDir]) ~= 1
          noPro = 1;
      end
      if (noPro == 0)
        set(handles.txt_WorkPath, 'String', path)
        handles.GuiProperties.ProjectPath = path;
        handles.GuiProperties.ProjectName = drp_item;
        
        %Load files if there are any
        %list mdl files
        files = dir([path '\' GuiConstants.CtrMdlDir '\*.mdl']);
        if length(files) == 1   % load the file if there is exactly one
            handles.GuiProperties.Mdl_File = [path '\' ...
                    GuiConstants.CtrMdlDir '\' files(1).name];
            set(handles.txt_CtrMdlPath, 'String', ...
                    handles.GuiProperties.Mdl_File);
        else
            % not one file to be loaded
            set(handles.txt_CtrMdlPath, 'String', '');
            handles.GuiProperties.Mdl_File = '';           
        end
        filesXLS = dir([path '\' GuiConstants.TsNetDir '\*.xls']);
        filesXLSX = dir([path '\' GuiConstants.TsNetDir '\*.xlsx']);
        files = [filesXLS filesXLSX];
        if length(files) == 1
            handles.GuiProperties.TsNet_File = [path '\' ...
                GuiConstants.TsNetDir '\' files(1).name];
            set(handles.txt_TsNetPath, 'String', ...
                handles.GuiProperties.TsNet_File);

            % load Sheets
            [status,sheets]=xlsfinfo(handles.GuiProperties.TsNet_File);
            sheetsWithDef = [GuiConstants.DefSheetSel sheets];
            set(handles.drp_SelSheet,'String', sheetsWithDef);
        else
            handles.GuiProperties.TsNet_File = '';
            set(handles.txt_TsNetPath, 'String', '');
        end
      else
          % no valid Project structure
         msgbox(GuiConstants.ProjStruc, GuiConstants.ProjStrucTitle);
      end
  end   
    
  updateGUI(hObject, eventdata, handles)
  guidata(hObject, handles);
end 

% btn_CreateProj_Callback force input for Projectname
function btn_CreateProj_Callback(hObject, eventdata, handles)
    ProjectName = inputdlg();   % not Part of IPA
end

% btn_OpnProj_Callback is called, when Folder should be shown in Explorer
function btn_OpnProj_Callback(hObject, eventdata, handles)
    try
        system(['explorer.exe ' get(handles.txt_WorkPath, 'String')])
    catch
        Msgbox([GuiConstants.OpnProj get(handles.txt_WorkPath)], ...
            GuiConstants.OpnProjTitle);
    end
end 

% btn_SelCtrMdl_Callback is called, when a Control-Model should be selected
function btn_SelCtrMdl_Callback(hObject, eventdata, handles)
    if not(isempty(handles.GuiProperties.ProjectName))
        path = [handles.GuiProperties.BasePath '\Projects\' ...
         handles.GuiProperties.ProjectName '\' GuiConstants.CtrMdlDir '\'];
            [filename,pathname]=uigetfile('*.mdl',GuiConstants.CtrMdlSel, path);
       
        
        % if Selected Model is not in Project, copy it there
        if filename ~= 0
            if strfind(filename, '.mdl')
                if not(strcmp(pathname, path))
                    try
                        copyfile([pathname '\' filename], [path filename])
                        handles.GuiProperties.Mdl_File=[path filename];
                        set(handles.txt_CtrMdlPath,'String', ...
                            [path filename]); 
                    catch
                        messagebox(['The File' pathname '\' filename ...
                            ' could not be copied to' path filename]);
                        handles.GuiProperties.Mdl_File='';
                        set(handles.txt_CtrMdlPath,'String', ''); 
                    end
                else
                    %selected Model is already in /Project/Control_Model 
                    handles.GuiProperties.Mdl_File=[path filename];
                    set(handles.txt_CtrMdlPath,'String', [path filename]); 
                end 
            else
                % selected File is not MDL-File
                msgbox(GuiConstants.NoMdl, GuiConstants.NoMdlTitle);
            end
        end
    end
    updateGUI(hObject, eventdata, handles);
    guidata(hObject, handles);
end

% btn_ModiCtrMdl_Callback is called, when Control-Model should be modified
function btn_ModiCtrMdl_Callback(hObject, eventdata, handles)
    try  
        open_system(get(handles.txt_CtrMdlPath, 'String'));
    catch
        Msgbox([GuiConstants.ErrOpnFile get(handles.txt_CtrMdlPath)], ...
            GuiConstants.ErrOpnFileTitle);
    end
end

% btn_ModiTsNet_Callback is called, when a TsNEt-File should be selected
function btn_SelTsNet_Callback(hObject, eventdata, handles)
    if not(isempty(handles.GuiProperties.ProjectName))
        path = [handles.GuiProperties.BasePath '\Projects\' ...
          handles.GuiProperties.ProjectName '\' GuiConstants.TsNetDir '\'];
        [filename,pathname]=uigetfile('*.xls;*xlsx', ... 
                GuiConstants.TsNetSel, path);
        
        % if Selected File is not in Project, copy it there
        if strfind(filename, '.xls')
            if filename ~= 0
                if not(strcmp(pathname, path))
                    try
                        copyfile([pathname '\' filename], [path filename])
                        handles.GuiProperties.TsNet_File=[path filename];
                        set(handles.txt_TsNetPath,'String', ...
                            [path filename]); 
                    catch
                        messagebox(['The File' pathname '\' filename ...
                            ' could not be copied to' path filename]);
                        handles.GuiProperties.TsNet_File='';
                        set(handles.txt_TsNetPath,'String', ''); 
                    end
                else
                    %selected TsNe-File is already in /Project/TsNet
                    handles.GuiProperties.TsNet_File=[path filename];
                    set(handles.txt_TsNetPath,'String', [path filename]); 
                end
                %load the Sheets/values for drp_SelSheet
                if not(isempty(handles.GuiProperties.TsNet_File))
                    [status,sheets]=xlsfinfo...
                        (handles.GuiProperties.TsNet_File);
                    sheetsWithDef = [GuiConstants.DefSheetSel sheets];
                    set(handles.drp_SelSheet,'String', sheetsWithDef);
                end
            end
        else
            % selected File is no Excel-File
            msgbox(GuiConstants.NoXls, GuiConstants.NoXlsTitle);
        end
    end
    updateGUI(hObject, eventdata, handles);
    guidata(hObject, handles);
end

% btn_ModiTsNet_Callback is called, when the TsNet-File should modified
function btn_ModiTsNet_Callback(hObject, eventdata, handles)
    try
        winopen(get(handles.txt_TsNetPath, 'String'));
    catch
        Msgbox([GuiConstants.ErrOpnFile get(handles.txt_TsNetPath)], ...
            GuiConstants.ErrOpnFileTitle);
    end
end

% btn_RUN_Callback is called, when the user want to start the Simulation
function btn_RUN_Callback(hObject, eventdata, handles)
    % is there a Excel and a Model?
    Run_state = 1;  % 0 = don't run, 1 = parameter are ok
    
    if isempty(handles.GuiProperties.SelectedSheet) || ...
      strcmp(handles.GuiProperties.SelectedSheet, GuiConstants.DefSheetSel)
        Run_state = 0;  % 0 = sheet is not set/selected
        messagebox([GuiConstants.FailRun 'Excel-Sheet'], ...
            GuiConstants.FailRunTitle)
    end  
    
    if not(strfind(get(handles.txt_TsNetPath,'String'), '.xls'))
        Run_state = 0;  % 0 = Parameter is no valid Excel-File
        messagebox([GuiConstants.FailRun 'TsNet-File'], ...
            GuiConstants.FailRunTitle)
    end    
    
    if not(strfind(get(handles.txt_CtrMdlPath,'String'), '.mdl'))
        Run_state = 0;  % 0 = Parameter is no valid Model
        messagebox([GuiConstants.FailRun 'Control-Model'], ...
            GuiConstants.FailRunTitle)
    end
    
    if Run_state == 1
        %Starts Simulation (FOREIGN CODE)
        TSNet_Test(get(handles.txt_TsNetPath,'String'),char(...
        handles.GuiProperties.SelectedSheet),get(handles.txt_CtrMdlPath,...
        'String'), handles);
    end
    
    % enable "show REport"-Button    
    if strcmp(get(handles.txt_State, 'String'), GuiConstants.Success)
        set(handles.btn_OpnReport, 'Enable', 'on');
    else
        set(handles.btn_OpnReport, 'Enable', 'off');
    end        
    guidata(hObject, handles);
end

% btn_OpnReport_Callback is called, when the Report-Sheet should be shown
function btn_OpnReport_Callback(hObject, eventdata, handles)
    try
        winopen(get(handles.txt_TsNetPath, 'String'));
    catch
        Msgbox([GuiConstants.ErrOpnFile get(handles.txt_TsNetPath)], ...
            GuiConstants.ErrOpnFileTitle);
    end
end 

% drp_SelProj_Callback is called, when drp_SelProj has been changed
function drp_SelProj_Callback(hObject, eventdata, handles)
    updateGUI(hObject, eventdata, handles)  %enables Load-Button
    guidata(hObject, handles);
end 

% drp_SelSheet_Callback is called, when drp_SelSheet has been changed
% it sets the Property: SelectedSheet and calls updateGUI
function drp_SelSheet_Callback(hObject, eventdata, handles)
    if not(isempty(get(handles.txt_TsNetPath, 'String')))
        items = get(handles.drp_SelSheet,'String');
        drp_index = get(handles.drp_SelSheet,'Value');
        drp_item = items{drp_index};         
        if not(strcmp(drp_item, GuiConstants.DefSheetSel))
            handles.GuiProperties.SelectedSheet = drp_item;
        end
    end

    updateGUI(hObject, eventdata, handles)
    guidata(hObject, handles);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% ADDITIONAL-FUNCTIONS %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% updateGUI is called after every GUI-interaction
% it sets enable property of buttons and dropdowns, InfoBoxes
function updateGUI(hObject, eventdata, handles)    
    TextVal = get(handles.txt_WorkPath,'String');       
    
    %get selected item of drp_SelProj    
    drp_item = getDrpSelItem(handles.drp_SelProj, GuiConstants.DefProjSel);
    
    % is WorkPath not set?
    if isempty(TextVal)
        % Project hasn't been selected -> set InfoBoxes red
        falseInfoBoxes(hObject, eventdata, handles)        
        %disable all buttons, (except Load) -> there's no project
        disableButtons(hObject, eventdata, handles)
        
        if strcmp(drp_item, 'Select existing Test-Project...')
            % Project has NOT been selected in dropdown
            set(handles.btn_LoadProj, 'Enable', 'off')
        else
            %Project has been selected in dropdown -> enable Loadbtn
            set(handles.btn_LoadProj, 'Enable', 'on')
        end        
    else
        % Project Path is set
        % check if Dropdown-Selection is same Project as txt_WorkPath
        if strcmp([handles.GuiProperties.BasePath ...
            '\Projects\' drp_item], TextVal)
            afterPathIsSet(hObject, eventdata, handles);
            
            % disable Load button, cause Project is loaded now
            set(handles.btn_LoadProj, 'Enable', 'off')
            
            % check CtrMdl set?
            if isempty(get(handles.txt_CtrMdlPath, 'String'))
                set(handles.box_CtrMdl, 'BackgroundColor', 'red');
                set(handles.box_CtrMdl, 'String', '');
            else
                set(handles.box_CtrMdl, 'BackgroundColor', 'green');
                set(handles.box_CtrMdl, 'String', 'OK');
                set(handles.btn_ModiCtrMdl, 'Enable', 'on');
            end
            
            % check TsNet-File set?
            if isempty(get(handles.txt_TsNetPath, 'String'));
                set(handles.box_TsNet, 'BackgroundColor', 'red');
                set(handles.box_TsNet, 'String', '');
                set(handles.btn_ModiTsNet, 'Enable', 'off')
                set(handles.drp_SelSheet, 'Enable', 'off') 
            else
                %TsNet-File is set
                set(handles.btn_ModiTsNet, 'Enable', 'on')
                % enable Dropdown SelSheet
                set(handles.drp_SelSheet, 'Enable', 'on') 
                % is dropdown selected?
                if not(isempty(getDrpSelItem(handles.drp_SelSheet, ...
                        GuiConstants.DefSheetSel)))
                    set(handles.box_TsNet, 'BackgroundColor', 'green');
                    set(handles.box_TsNet, 'String', 'OK');
                else
                    set(handles.box_TsNet, 'BackgroundColor', 'red');
                    set(handles.box_TsNet, 'String', '');
                end
            end
            checkRunEnable(hObject, eventdata, handles)
        else
            % Project was set, but selProj-Dropdown has been changed
            % ..block user from doing further actions= not sure which Proj
            falseInfoBoxes(hObject, eventdata, handles)
            disableButtons(hObject, eventdata, handles)
            set(handles.btn_LoadProj, 'Enable', 'on')
        end
    end
    guidata(hObject, handles);
end

% afterPathIsSet enables buttons, gets called when the Project path is set
function afterPathIsSet(hObject, eventdata, handles)
    set(handles.box_Proj, 'BackgroundColor', 'green') 
    set(handles.box_Proj, 'String', 'OK')
    set(handles.btn_OpnProj, 'Enable', 'on')
    set(handles.btn_DelProj, 'Enable', 'on')
    set(handles.btn_SavProjAs, 'Enable', 'on')
    set(handles.btn_SelAppl, 'Enable', 'on')
    set(handles.btn_SelCtrMdl, 'Enable', 'on')
    set(handles.btn_SelTsNet, 'Enable', 'on')
    guidata(hObject, handles);
end


% checkRunEnable checks RUN-Button enable Property
% missing inputs enable = off, all inputs done = on
function checkRunEnable(hObject, eventdata, handles)
    enab = 1;       % 1 means disable RUN-Button
    if not(isempty(get(handles.txt_CtrMdlPath, 'String')))
        if not(isempty(get(handles.txt_TsNetPath, 'String')))
            if not(isempty(getDrpSelItem(handles.drp_SelSheet, ...
                    GuiConstants.DefSheetSel)))
                enab = 0;
            end           
        end
    end
         
     if enab == 0
         %all inputs done, RUN enable        
         set(handles.btn_RUN, 'Enable', 'on')
     else
         set(handles.btn_RUN, 'Enable', 'off')         
     end 
     guidata(hObject, handles);
end


% falseInfoBoxes sets InfoBoxes red and no string
% called if no project is selected ...
% or Dropdown-Selection is not same as txt_WorkPath
function falseInfoBoxes(hObject, eventdata, handles)
    set(handles.box_Proj, 'BackgroundColor', 'red');
    set(handles.box_CtrMdl, 'BackgroundColor', 'red');
    set(handles.box_TsNet, 'BackgroundColor', 'red');
    set(handles.box_Sim, 'BackgroundColor', 'red');
    set(handles.box_Proj, 'String', '');
    set(handles.box_CtrMdl, 'String', '');
    set(handles.box_TsNet, 'String', '');
    set(handles.box_Sim, 'String', '');
    guidata(hObject, handles);
end

% selItem gets the selected item of the parameter dropdown
% returns '' if selection is defVal 
function selItem = getDrpSelItem(dropdown, defVal)
    selItem = '';
    items = get(dropdown,'String');
    drp_index = get(dropdown,'Value');
    drp_item = items{drp_index};
    if not(strcmp(drp_item, defVal))
        selItem = drp_item;
    end
end

%disableButtons, when no project is selected
function disableButtons(hObject, eventdata, handles)
    set(handles.btn_RUN, 'Enable', 'off');
    set(handles.btn_ModiTsNet, 'Enable', 'off');
    set(handles.btn_ModiCtrMdl, 'Enable', 'off');
    set(handles.btn_SelCtrMdl, 'Enable', 'off');
    set(handles.btn_SelAppl, 'Enable', 'off');
    set(handles.btn_SelTsNet, 'Enable', 'off');
    set(handles.btn_DelProj, 'Enable', 'off');
    set(handles.btn_SavProjAs, 'Enable', 'off');
    set(handles.btn_OpnProj, 'Enable', 'off');
    set(handles.drp_SelSheet, 'Enable', 'off');
    guidata(hObject, handles);
end
