function varargout = optimized_GUI(varargin)
    % OPTIMIZED_GUI MATLAB code for optimized_GUI.fig
    %      OPTIMIZED_GUI, by itself, creates a new OPTIMIZED_GUI or raises the existing
    %      singleton*.
    %
    %      H = OPTIMIZED_GUI returns the handle to a new OPTIMIZED_GUI or the handle to
    %      the existing singleton*.
    %
    %      OPTIMIZED_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in OPTIMIZED_GUI.M with the given input arguments.
    %
    %      OPTIMIZED_GUI('Property','Value',...) creates a new OPTIMIZED_GUI or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before optimized_GUI_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to optimized_GUI_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help optimized_GUI

    % Last Modified by GUIDE v2.5 24-Mar-2015 09:38:52

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @optimized_GUI_OpeningFcn, ...
                       'gui_OutputFcn',  @optimized_GUI_OutputFcn, ...
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
end
% End initialization code - DO NOT EDIT

% --- Executes just before optimized_GUI is made visible.
function optimized_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to optimized_GUI (see VARARGIN)
    
    % Choose default command line output for optimized_GUI
    handles.output = hObject;

    % prepare enable property of elements
    set(findall(handles.uipan_ModSel, '-property', 'enable'), 'enable', 'off') % disable other panel 
    set(handles.txt_ZipSel,'enable','inactive')

    % UIWAIT makes optimized_GUI wait for user response (see UIRESUME)
    % uiwait(handles.figure1);
    
    % USEFUL
    % Path of Matlab-File is BasePath
    
    handles.GuiProperties           = struct('BasePath',         '',...
                                          'ProjectPath',         '',...
                                          'ProjectName',         '',...
                                          'Zip_File',            '',...
                                          'Mdl_File',            '',...
                                          'selectedSheet',       '',...
                                          'TsNet_File',          '');
                                      
    [pathstr] = fileparts(which('optimized_GUI.m'));
    handles.GuiProperties.BasePath = pathstr;
   
    % check if Projectsfolder exists
    if isdir([handles.GuiProperties.BasePath '\' GuiConstants.ProDir]) ~= 1
        mkdir([handles.GuiProperties.BasePath '\' GuiConstants.ProDir])  % dir does not exist, create it
    end    
    guidata(hObject, handles);
end

% --- Outputs from this function are returned to the command line.
function varargout = optimized_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
    varargout{1} = handles.output;
end

% --- Executes on button press in rad_Mod_Exist.
function rad_Mod_Exist_Callback(hObject, eventdata, handles)
% hObject    handle to rad_Mod_Exist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    set(handles.rad_Mod_Exist,'Value',1)       % set pressed Radiobutton
    if get(handles.rad_Import_Gen,'Value') ~= 0
        set(handles.rad_Import_Gen,'Value',0)       % unset other Radiobutton
        set(findall(handles.uipan_Import_Gen, '-property', 'enable'), 'enable', 'off') % disable other panel
        set(findall(handles.uipan_ModSel, '-property', 'enable'), 'enable', 'on') % enable this panel 
        set(handles.txt_ModSel,'enable','inactive')
    end   
end

% --- Executes on button press in rad_Import_Gen.
function rad_Import_Gen_Callback(hObject, eventdata, handles)
% hObject    handle to rad_Import_Gen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    set(handles.rad_Import_Gen,'Value',1)% set pressed Radiobutton
    if get(handles.rad_Mod_Exist,'Value') ~= 0
        set(handles.rad_Mod_Exist,'Value',0)       % unset other Radiobutton
        set(findall(handles.uipan_ModSel, '-property', 'enable'), 'enable', 'off') % disable other panel 
        set(findall(handles.uipan_Import_Gen, '-property', 'enable'), 'enable', 'on') % enable this panel 
        set(handles.txt_ZipSel,'enable','inactive')
    end   
end

% --- Executes on button press in btn_ModSel.
function btn_ModSel_Callback(hObject, eventdata, handles)
% hObject    handle to btn_ModSel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    SelMod (hObject, eventdata, handles);
    guidata(hObject, handles);
end

function txt_ModSel_Callback(hObject, eventdata, handles)
end

function txt_ModSel_CreateFcn(hObject, eventdata, handles)
end

function txt_ModSel_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to txt_ZipSel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
    SelMod (hObject, eventdata, handles);
    guidata(hObject, handles);
end

function btn_Import_Callback(hObject, eventdata, handles)
% Copied Code
%%%%%%%%%%%%%
% init Code in Import_init.m
FirmwareLib =  'C:\Users\z003019m\ABT Function Blocks Simulation\MatlabLibrary\ApplFwS1v1_LIB.mdl'
Import_init
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
    % set a default value for BaObjRef.DeviceId
    BaObjRef.DeviceId = 0;
    % Load the handle structure (h) 
    h = guidata(hObject);
    % Get the selected file 
    File_Selected=get(h.txt_ZipSel,'String');
    % Split the String
    File_Selected=regexp(File_Selected,';','split');
%% classification of the import case
    % initialisation
    BACounter = 0;
    Errors = 0;
    %detect if its one or more files
    if length(File_Selected)==1
        % single File
        MulitFile = false;
        % Get the file extension
        File_Selected=File_Selected{1};
        [pathstr, name, ext] = fileparts(File_Selected);
    end  
%% select import case
%%% Full Import (*.zip)
    if strcmp(ext,'.zip') && (MulitFile == false )
        if exist([pathstr '\_TEMP_UNZIP_FOLDER']) == 7
        % delete directory if it already exists
        % (when the GUI executes with error the Folder can not be deleted, so it needs to be proofed here)
        rmdir([pathstr '\_TEMP_UNZIP_FOLDER'],'s')
        end
        unzip(File_Selected,[pathstr '\_TEMP_UNZIP_FOLDER']);
        BA_FILE = dir([pathstr '\_TEMP_UNZIP_FOLDER\*.ba']);
        
        %--------------------------------------------------------------------------------------------------------------------------
        %Import MP1.20
        %--------------------------------------------------------------------------------------------------------------------------
        if numel(BA_FILE) == 0
            % 2014-06-03, Stefan Boetschi: Removed subfolder
            % \Implementation\ and replaced with generic subfolder name
            % identified using dir() command
            subDirs = dir([pathstr '\_TEMP_UNZIP_FOLDER\']);
            for k=1:numel(subDirs)
               curName = subDirs(k).name;
               if (~strcmp(curName,'.') && ~strcmp(curName,'..'))
                   mp120pathstr = [pathstr '\_TEMP_UNZIP_FOLDER\' curName];
                   break;
               end
            end
            
            if exist('mp120pathstr','var')
                BA_FILE = dir([mp120pathstr '\*.xml']);
            else
               error(['No import data could be located in the .zip file. Please make sure that the .zip file contains ',...
                   'a single directory which in turn contains all the ABT export data.']); 
            end
            
            if (numel(BA_FILE) > 0)
                % Import der BA-MODEL Files 
                for i=1:numel(BA_FILE)
                    [Errors,BaObjRef.DeviceId,MdlFilePath]=ImportBA_XML([mp120pathstr '\' BA_FILE(i).name],h,FirmwareLib);                    
                end
            else
                error(['No import data could be located in the .zip file. Please make sure that the .zip file contains ',...
                   'a single directory which in turn contains all the ABT export data.']);
            end
            
        else    
            %--------------------------------------------------------------------------------------------------------------------------
            % Import MP1.16
            %--------------------------------------------------------------------------------------------------------------------------
            if numel (BA_FILE) == 1
                % Import des .ba Files
                [Errors,BaObjRef.DeviceId,MdlFilePath]=ImportBA_XML([pathstr '\_TEMP_UNZIP_FOLDER\' BA_FILE(1).name],h,FirmwareLib);
                % Wiederholen des Aufrufs wenn  Errormeldung = 2 (Überschreiben) 
                if Errors == 2
                    [Errors,BaObjRef.DeviceId,MdlFilePath]=ImportBA_XML([pathstr '\_TEMP_UNZIP_FOLDER\' BA_FILE(1).name],h,FirmwareLib);
                end
            end
            CHART_FILES = dir([pathstr '\_TEMP_UNZIP_FOLDER\*.xml']);
            if (numel(CHART_FILES) > 0) && (Errors == 0)
            % Import der Chart Files 
                for i=1:numel(CHART_FILES)
                    [in out err] = ImportXML([pathstr '\_TEMP_UNZIP_FOLDER\' CHART_FILES(i).name],MdlFilePath,BaObjRef,h,FirmwareLib);
                end
            end
        end
        rmdir([pathstr '\_TEMP_UNZIP_FOLDER'],'s')
    end   
%%% BA-Chart Import (*.ba)
    if strcmp(ext,'.ba') 
        if (MulitFile == true )
            BAFile = [MultiFilePath '\' BAFile];
            % change the extension for the following chart import
            ext = '.xml';
        elseif (MulitFile == false )
            BAFile = File_Selected;
        end
        [Errors,BaObjRef.DeviceId,MdlFilePath]=ImportBA_XML(BAFile,h,FirmwareLib);
        % Wiederholen des Aufrufs wenn  Errormeldung = 2 (Überschreiben) 
        if Errors == 2
          [Errors,BaObjRef.DeviceId,MdlFilePath]=ImportBA_XML(BAFile,h,FirmwareLib);
        end  
    end   
%%% Chart Import (*.xml)
    if strcmp(ext,'.xml')
        % if no BACNet File is existing
        if (BACounter == 0)

         FileConsistentHint=msgbox(...
         {'The *.xml File you want to Import needs to fit to the selected *.mdl File.';...
          'Example: The File "Chart_R_1''CcgRad01@RTPrt01.xml" belongs to an R_1.mdl File'},...
        'File Consistent','warn');       
        % Open the file selection pop up
        [~,ModelFilePath,FilterIndex] = uigetfile( ...
                    {'*.mdl','Simulink Model (*.mdl)'; ...
                    '*.*',  'All Files (*.*)'}, ... % Filterdefinition
                    'Select Mdl-File',...  % Headline
                    h.ImportChartPathName); % PathName of the previous invocation
        if FilterIndex == 0
            return % Cancel if no Path was selected
        end
        try
            % close the message box again
            close(FileConsistentHint);
        catch
        end
        % save the Path in guidata for the next invoke of uigetfile
        h.ImportChartPathName = ModelFilePath; 
        % if BACNet File is existing 
        elseif (BACounter == 1)
            ModelFilePath = MdlFilePath;
        end
        if (MulitFile == false )
            [FilePath, name, ~] = fileparts(File_Selected);
            CHART_FILES{1}= name;
        elseif (MulitFile == true )
            FilePath = MultiFilePath;
            CHART_FILES = File_Selected;
        end
        
        if (numel(CHART_FILES) > 0) && (Errors == 0)
        % Import der Chart Files 
            for i=1:numel(CHART_FILES)
               [in out err] = ImportXML([FilePath '\' CHART_FILES{i}],ModelFilePath,BaObjRef,h,FirmwareLib);
            end
        end
    end
%%% Error Message   
    if ~(strcmp(ext,'.zip') || strcmp(ext,'.ba')  || strcmp(ext,'.xml'))
        msgbox('Permitted File Extensions: (*.zip ; *.ba ; *.xml)',...
                    'Error: Wrong File Extension','error');
    end
    % Update the handle structure (h)
    guidata(hObject,h);
end


function txt_ZipSel_Callback(hObject, eventdata, handles)
end

function txt_ZipSel_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

function txt_ZipSel_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to txt_ZipSel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
    SelZip (hObject, eventdata, handles);
    guidata(hObject, handles);
end

function btn_ZipSel_Callback(hObject, eventdata, handles)
% hObject    handle to btn_ZipSel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    SelZip (hObject, eventdata, handles);
    guidata(hObject, handles);
end

function btn_OpenMod_Callback(hObject, eventdata, handles)
% hObject    handle to btn_OpenMod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    try  
        open_system(get(handles.txt_ModSel, 'String'));
    catch
        % error by opening Model
    end
end

function btn_TsNet_Callback(hObject, eventdata, handles)
% hObject    handle to btn_TsNet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    SelTsnet(hObject, eventdata, handles);
    guidata(hObject, handles);
end

function txt_Tsnet_Callback(hObject, eventdata, handles)
end

function txt_Tsnet_ButtonDownFcn(hObject, eventdata, handles)
    SelTsnet(hObject, eventdata, handles);
    guidata(hObject, handles);
end

function txt_Tsnet_CreateFcn(hObject, eventdata, handles)

end

% --- Executes on button press in btn_CreatePro.
function btn_CreatePro_Callback(hObject, eventdata, handles)
% hObject    handle to btn_CreatePro (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.GuiProperties.ProjectName = get(handles.txt_ProPath, 'String');
    handles.GuiProperties.ProjectPath = [handles.GuiProperties.BasePath '\' GuiConstants.ProDir '\' handles.GuiProperties.ProjectName];
    if isdir(handles.GuiProperties.ProjectPath) ~= 1
        mkdir(handles.GuiProperties.ProjectPath)  % dir does not exist, create it
        % create sub-project-folders
    else
        % Project exists, warning
        set(handles.txt_ProPath, 'BackgroundColor', 'red')
    end
    guidata(hObject, handles);
end


%%%%%%%%%%%%%%%%%%%%
% CUSTOM FUNCTIONS %
%%%%%%%%%%%%%%%%%%%%

function SelMod (hObject, eventdata, handles)
    if get(handles.rad_Mod_Exist,'Value') ~= 0    
        [filename,pathname]=uigetfile('*.mdl','Bitte Modell auswählen, welches verwendet werden soll (*.mdl)', handles.GuiProperties.BasePath);
        if(filename ~= 0)
            handles.GuiProperties.Mdl_File=[pathname filename];
            set(handles.txt_ModSel,'String', [pathname filename]);
            %check if valid file
        else
        end
    end 
end 

function SelZip (hObject, eventdata, handles)
    if get(handles.rad_Import_Gen,'Value') ~= 0    
        [filename,pathname]=uigetfile('*.zip','Bitte Applikation auswählen, welche importiert werden soll (*.zip)',  handles.GuiProperties.BasePath);
        if(filename ~= 0)
            handles.GuiProperties.Zip_File=[pathname filename];
            set(handles.txt_ZipSel,'String', [pathname filename]);
            %check if valid file
        else
        end
    end 
end

function SelTsnet (hObject, eventdata, handles) 
    [filename,pathname, sheets]=uigetfile('*.xls;*xlsx','Bitte TsNet-Excel-Sheet auswählen', handles.BasePath);
    if(filename ~= 0)
        handles.GuiProperties.TsNet_File=[pathname filename];
        set(handles.txt_Tsnet,'String', [pathname filename]);
        %check if valid file
        % load lbox for SheetSel
        [status,sheets]=xlsfinfo(filename);
        set(handles.lbox_SheetSel,'String',sort(sheets));
    else
    end
end
  
% --- Executes on button press in btn_StartSim.
function btn_StartSim_Callback(hObject, eventdata, handles)
% hObject    handle to btn_StartSim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    ready = 111;
    if isempty(get(handles.txt_Tsnet,'String'))
        ready = ready - 1;
    elseif isempty(get(handles.txt_ModSel,'String'))
            ready = ready - 100;
    end    
    try 
        if isempty(handles.GuiProperties.selectedSheet)
            ready = ready - 10;
        end 
    catch
         ready = ready - 10;
    end
    if ready == 111
        TSNet_Test(get(handles.txt_Tsnet,'String'),char(handles.GuiProperties.selectedSheet),get(handles.txt_ModSel,'String'), handles);
    end 
    guidata(hObject, handles);
end
    
function lbox_SheetSel_Callback(hObject, eventdata, handles)
    handles.selectedSheetIndex=get(handles.lbox_SheetSel,'Value');
    handles.SheetList=get(handles.lbox_SheetSel,'String');
    handles.GuiProperties.selectedSheet=handles.SheetList(handles.selectedSheetIndex);
    guidata(hObject, handles);
end


% --- Executes on button press in btn_ProSel.
function btn_ProSel_Callback(hObject, eventdata, handles)
% hObject    handle to btn_ProSel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    path = uigetdir([handles.GuiProperties.BasePath '\' GuiConstants.ProDir], 'Ordner des Test-Projekts anwählen');
    if path ~= 0
        noPro = 0;
        % is Projectfolder? 
        if isdir([path '\' GuiConstants.ApplDir]) ~= 1 
            noPro = 1;
        elseif isdir([path '\' GuiConstants.CtrMdlDir]) ~= 1
            noPro = 1;
        elseif isdir([path '\' GuiConstants.TsNetDir]) ~= 1
            noPro = 1;
        elseif isdir([path '\' GuiConstants.AddDir]) ~= 1
            noPro = 1;
        end

        if noPro == 0       % Project is valid
            set(handles.txt_ProPath, 'String', path);
            handles.GuiProperties.ProjectPath = path;

            files = dir([path '\' GuiConstants.CtrMdlDir '\*.mdl']);
            if length(files) == 1
                handles.GuiProperties.Mdl_File = [path '\' GuiConstants.CtrMdlDir '\' files(1).name];
                set(handles.txt_ModSel, 'String', handles.GuiProperties.Mdl_File)
            else
                % no file to load
            end
               filesXLS = dir([path '\' GuiConstants.TsNetDir '\*.xls']);
               filesXLSX = dir([path '\' GuiConstants.TsNetDir '\*.xlsx']);
               files = [filesXLS, filesXLSX];
            if length(files) == 1
                handles.GuiProperties.TsNet_File = [path '\' GuiConstants.TsNetDir '\' files(1).name];
                set(handles.txt_Tsnet, 'String', handles.GuiProperties.TsNet_File)

                % load Sheets
                [status,sheets]=xlsfinfo(handles.GuiProperties.TsNet_File);
                set(handles.lbox_SheetSel,'String',sort(sheets));

            else
                % no file to load
            end        
        else
            % is no Project
        end
    end
    guidata(hObject, handles);
end



function txt_SimState_Callback(hObject, eventdata, handles)
% hObject    handle to txt_SimState (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_SimState as text
%        str2double(get(hObject,'String')) returns contents of txt_SimState as a double
end

% --- Executes during object creation, after setting all properties.
function txt_SimState_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_SimState (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end