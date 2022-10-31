function Import_init
%% Initialisation
% pwd returns the current matlab folder
% these variables store the path selected by the browse button
h.ImportPathName=pwd;
h.ImportChartPathName=pwd;
h.ExportPathName=pwd;
h.LibFilePathName=pwd;
h.MatlabPathName=pwd;
scl_list = 0;
build_list = 0;
% Initialisation of the Filterindex for the Import Browse Button
h.ImportBrowseFilterIndex=1;
h.ImpBrwsLastSel='*.zip';
h.ImpBrwsLastSelStr=['Full Import (' h.ImpBrwsLastSel ')'];
%% Log File
LogFilePath = getapplicationdatadir('CFC2SL', true, true);
h.LogFileLocal = [LogFilePath '\' 'CFC2SL_LogFile.xml'];
% if not exists CFC2SL_LogFile
if ~(exist([LogFilePath '\' 'CFC2SL_LogFile.xml']) == 2)
    % copy CFC2SL_LogFile to APPDATA Path
    [status,message,messageId]=copyfile(...
        [IMSESPath '\Lib\LogFile\CFC2SL_LogFile.xml'], ...
        [LogFilePath '\' 'CFC2SL_LogFile.xml']);
end
%delete the fileattrib 'w' for write access
if (exist([LogFilePath '\' 'CFC2SL_LogFile.xml']) == 2)
    [status, message, messageid] = fileattrib(...
        [LogFilePath '\' 'CFC2SL_LogFile.xml'],'+w');
end

% creating a document object model node of the XML File
h.xDocLogFile = xmlread(h.LogFileLocal);
% XPath Factory
import javax.xml.xpath.*
factory = XPathFactory.newInstance;
xpath = factory.newXPath;
%% Firmware Library
% finding the FirmwareLib Node
expr=xpath.compile('.//FirmwareLib');
FirmwareLibNode=expr.evaluate(h.xDocLogFile, XPathConstants.NODE);
FirmwareLib=FirmwareLibNode.getAttribute('Value');
FirmwareLib=char(FirmwareLib);
% if the Value of FirmwarLib is empty
if isempty(FirmwareLib)
    ConfigLibWarn=msgbox({'The Library File is not Configured yet.';...
        'Please select the Library File'},...
        'Configure Library File','warn');
    % select the Firmware Library File
    [FileName,PathName,FilterIndex] = uigetfile( ...
                    {'*.mdl','Library-File (*.mdl)'; ...
                    '*.*',  'All Files (*.*)'}, ...
                    'Select Library-File',h.LibFilePathName);
    FirmwareLib = [PathName FileName];  
    if FileName > 0 
        try
        % close the Message Box if not already closed
        close(ConfigLibWarn);
        catch
        end
        % save the Path in guidata for the next invoke of uigetfile 
        h.LibFilePathName = PathName;
        % change the Attribute 
        FirmwareLibNode.setAttribute('Value',FirmwareLib)
        % writing the DOM xDocLogFile to the XML-File LogFileLocal
        %xmlwrite(h.LogFileLocal,result); % This is not working
        % It creates extra whitespace after every call
        % This is a workaround to solve the whitespace problem
        %LogFile as string
        LogFileStr = xmlwrite(h.xDocLogFile);
        %remove extra tabs, spaces and extra lines
        LogFileStr = regexprep(LogFileStr,'\n[ \t\n]*\n','\n'); 
        %Write to file
        LogFilehandle = fopen(h.LogFileLocal,'w');
        fprintf(LogFilehandle,'%s\n',LogFileStr);
        fclose(LogFilehandle);
    else
        msgbox(...
        '    ERROR : No File was selected',...
        'No File was selected','error');
        return
    end
end
% reading the Firmwarelibrary again
expr=xpath.compile('.//FirmwareLib/@Value');
result=expr.evaluate(h.xDocLogFile, XPathConstants.STRING);
FirmwareLib = result;
h.LibFile = FirmwareLib;
[FirmwareLibPath,~,~]=fileparts(FirmwareLib);
if ~exist(FirmwareLibPath)
   msgbox(...
       {'    ERROR : Firmware Library Path could not be located.';...
        '    * Check if Clear Case is working';...
        '    * Check if the defined Firmeware Library is available';...
        '    * The Log File will be deleted'},...
        'Firmware Library Path does not exist','error');
    delete(h.LogFileLocal);
    return
end
addpath(FirmwareLibPath);
% saving the FirmwareLibPath for the set Lib Button
h.LibFilePathName = [FirmwareLibPath '\'];
end