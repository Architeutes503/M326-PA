function [Errors,DeviceId,MdlFilePath] = ImportBA_XML(xmlFile,h,FirmwareLib)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   (C) Copyright by Siemens Schweiz AG, Building Technologies Group,
%       HVAC Products, 2012
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Project                     : IMSES
%   Target Hardware             : PC
%   Target Operating System     : WinXP Console
%   Language/Compiler           : Matlab 2010 and higher
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Workfile                    : ImportBA_XML.m
%   Author                      : Thomas Rohr
%   Version                     : v1.0
%   Date                        : 20-Feb-2012
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Matlab Informations
%   There is a Problem with XpathFactory in Matlab 2010 and maybe higher
%   Versions. You have to disable a static java path. Open the File:
%   ..\MATLAB\R2010bSP1\toolbox\local\classpath.txt
%   and set the following line in comment, like shown below.
%   ## $matlabroot/java/jarext/saxon9-xpath.jar
%
%   The BACNet Importer uses the new Matlab option of
%   (OOP) Object Oriented Programming in Matlab which is available since
%   Matlab 2008 it will not work with previous Versions.
%
% Helpfull Matlab functions:
%       javaclasspath
%       methodsview(xDoc)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:
%   ImportBA_XML Converts "Step7"-BacNet Objects into Simulink
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function/Interface:
%
% Declaration:
%    [CntOfInputs, CntOfOutputs, Errors] = ImportXML(xmlFile, system, BaObjRef)
%
% Inputs:
%    xmlFile      - Step7 XML import file
%    h            - handle for GUI communication
%    FirmwareLib  - Name of the Firmware Library
%
% Outputs:
%    Errors	 	  - true in case of error
%	 DeviceId     - returning the DeviceId for use in
%                   the further 'ImportXML' function
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Revision History
% 	(Put meaningful comments in SourceSafe for log below!)
% 	(Please remove blank lines and very old comments!)
%
%   2014-08-06 14:15 Stefan Boetschi
%   Extension for importing (multiple) RSegm(s) subordinate to top area (e.g. RSegm below R)
%
%   2014-07-21 11:40 Stefan Boetschi
%   Import multiple charts also from MP1.2 exports
%
%   2014-07-16 08:50 Stefan Boetschi
%   Adapted messages sent to the GUI
%
% 	2012-03-20 14:00 Thomas Rohr
%	Header comment was attached
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% selecting the status box Handle
h.status = 0; %DOZ
%% Firmware Library
[pathstr, name, ext] = fileparts(FirmwareLib);
FirmwareLib=name;
%% BA-File
[pathstr, name, ext] = fileparts(xmlFile);
BAFileName=[name ext];
MdlFilePath = pathstr;
%% loading the Firmware Library
try
    load_system(FirmwareLib)
catch
    Send2GUI(...
        {'    ERROR : FirmwareLib could not be located.';...
        '    * Check if Clear Case is working';...
        '    * Check if the Matlab Path to the Matlab Library is existing (Matlab->File->Set Path...)';...
        '      (.\SysOne_App_Platform\ABT Function Blocks Simulation\MatlabLibrary)';...
        '    * Check if the defined Firmeware Library is available'}...
        ,h.status);
    Errors=1;
    DeviceId=0;
    return
end
%% creating a document object model node of the XML File
xDoc = xmlread(xmlFile);
xRoot = xDoc.getDocumentElement;
%% Main
import javax.xml.xpath.*
factory = XPathFactory.newInstance;
xpath = factory.newXPath;

% check version
expr=xpath.compile('.//DocumentHeader/@SchemaVersion');
result=expr.evaluate(xDoc, XPathConstants.STRING);

% initial part
if (strcmp(result , '1.2') == 1)
    Version = ['MP' result];
    
    expr=xpath.compile('.//Property[@Name="Object_Name"]/@Value');
    AF=expr.evaluate(xDoc, XPathConstants.STRING);
    
    expr=xpath.compile('.//Property[@Name="Object_Type"]/@Value');
    ObjType =expr.evaluate(xDoc, XPathConstants.STRING);
    
    ActualModel= [AF '.mdl'];
else
    expr=xpath.compile('.//EOTypeRef[@Prototype="44"]');
    result=expr.evaluate(xDoc, XPathConstants.NODE);
    result=result.getParentNode.getParentNode;
    expr=xpath.compile('.//ShortDescription/@Value');
    AF=expr.evaluate(result, XPathConstants.STRING);
    ActualModel= [AF '.mdl'];
    Version = char(xRoot.getAttribute('Description'));
    ObjType = '';
end

if exist(ActualModel) == 4
    Send2GUI(['     HINT : The file ' ActualModel ' already exists'],h.status);
    % Construct a questdlg
    choice = questdlg({['The file ' ActualModel ' already exists'];' ';'Do you want to replace it?'}, ...
        'Message', ...
        'Yes','No','Delete','No');
    % Handle response
    switch choice
        case 'Yes'
            bdclose('all');
            delete(ActualModel);
            Errors=2; % overwrite
        case 'Delete'
            bdclose('all');
            delete(ActualModel);
            Errors=1;
        case 'No'
            Errors=1;
    end
    DeviceId=0;
else
    Send2GUI([' === Start importing BA objects : ' BAFileName '  to  ' ActualModel ' ==='],h.status);
    Send2GUI([' === <' xmlFile '> ==='],h.status);
    % This Number is a significant number to detect with which Schema
    % the Application Function was bulid
    Send2GUI([' === <SBTDocument =" ' Version ' "> ==='],h.status);
    % defining the instance AreaView from the BA_AREA class
    AreaView=BA_AREA;
    % passing the DocNode
    AreaView.DocNode=xDoc;
    % passing the handle structure
    AreaView.h=h.status;
    % passing the FirmwareLib
    AreaView.FWLib=FirmwareLib;
    % passing the FilePath
    AreaView.FilePath=MdlFilePath;
    AreaView.FileName=BAFileName;
    AreaView.ObjectTypeNr = ObjType;
    % passing the Version
    AreaView.Version=Version;
    % Setting the sub- and superordinate area information
    AreaView.isSubordinateArea = false;
    AreaView.superordinateAreaName = '';
    % subroutine parse
    AreaView.parse;
    % subroutine generate
    AreaView.generate;
    Errors=0;
    
    % 2014-08-06, Stefan Boetschi: Check if there is a RSegm subordinate to
    % the top area (=AreaView)
    fileCollection = dir([pathstr '\' strtok(AreaView.FileName, '.') '\*.xml']);
    haveRSegm = false;
    subListTooShort = false;
    RSegmFileNames = cell(1);
    RSegmCounter = 0;
    for l=1:length(fileCollection)
        curFileName = fileCollection(l).name;
        if ~isempty(strfind(curFileName,'RSegm')) && ~isempty(strfind(curFileName,'29_'))
            RSegmCounter = RSegmCounter + 1; % Increment room segment counter
            haveRSegm = true; % Have found a room segment below the top area!
            RSegmFileNames{RSegmCounter} = curFileName;
        end
    end
    % Parse the Subordinate_List of the top area and count its entries
    import javax.xml.xpath.*
    factory = XPathFactory.newInstance;
    xpath = factory.newXPath;
    expr=xpath.compile('.//Property[@Name="Subordinate_List"]/@Value');
    Subordinate_List = expr.evaluate(AreaView.DocNode, XPathConstants.STRING);
    Subordinate_List = regexp(Subordinate_List,')|(','split');
    for l=1:numel(Subordinate_List)
        if strcmp(Subordinate_List{l},'[') || strcmp(Subordinate_List{l},'|') || strcmp(Subordinate_List{l},']')
            Subordinate_List{l} = '';
        end
    end
    Subordinate_List = Subordinate_List(~cellfun('isempty',Subordinate_List));
    if (numel(Subordinate_List) < length(fileCollection))
        subListTooShort = true;
    end
    % Have a RSegm below the top area? If yes, import its BA objects!
    if (haveRSegm && subListTooShort)
        % Message to GUI
        Send2GUI([' === Have found ' num2str(RSegmCounter) ' RSegm(s) below the top area which are missing in the Subordinate_List of this top area. ==='],h.status);
        Send2GUI([' === Starting to import BA objects of this/these RSegm(s). ==='],h.status);
        for k=1:RSegmCounter
            % Full file path to the current RSegm area
            RSegmFilePath = [pathstr '\' strtok(AreaView.FileName, '.') '\' RSegmFileNames{k}];
            % Parse the XML file
            xDocRSegm = xmlread(RSegmFilePath);
            import javax.xml.xpath.*
            factory = XPathFactory.newInstance;
            xpath = factory.newXPath;
            % Get AF name
            expr = xpath.compile('.//Property[@Name="Object_Name"]/@Value');
            AF = expr.evaluate(xDocRSegm, XPathConstants.STRING);
            % Get ObjType
            expr=xpath.compile('.//Property[@Name="Object_Type"]/@Value');
            ObjType =expr.evaluate(xDocRSegm, XPathConstants.STRING);
            % Prepare the Simulink model
            RSegmModel= [AF '.mdl'];
            Send2GUI([' === Start importing BA objects : ' RSegmFileNames{k} '  to  ' RSegmModel ' ==='],h.status);
            Send2GUI([' === <' RSegmFilePath '> ==='],h.status);
            % This Number is a significant number to detect with which Schema
            % the Application Function was bulid
            Send2GUI([' === <SBTDocument =" ' Version ' "> ==='],h.status);
            % defining the instance AreaView from the BA_AREA class
            RSegmView=BA_AREA;
            % passing the DocNode
            RSegmView.DocNode=xDocRSegm;
            % passing the handle structure
            RSegmView.h=h.status;
            % passing the FirmwareLib
            RSegmView.FWLib=FirmwareLib;
            % passing the FilePath
            RSegmView.FilePath = [MdlFilePath '\' strtok(AreaView.FileName, '.')];
            RSegmView.FileName = RSegmFileNames{k};
            RSegmView.ObjectTypeNr = ObjType;
            % passing the Version
            RSegmView.Version=Version;
            % Setting the sub- and superordinate area information
            RSegmView.isSubordinateArea = true;
            RSegmView.superordinateAreaName = AreaView.ObjectName(1:find(AreaView.ObjectName=='/',1,'last')-1);
            % subroutine parse
            RSegmView.parse;
            % subroutine generate
            RSegmView.generate;
            Errors=0;
        end
    else
        % Have not found a RSegm
        Send2GUI([' === Have not found any RSegm which is missing in the Subordinate_List of the top area. ==='],h.status);
    end
    
    % returning the DeviceId for use in the further 'ImportXML' function
    DeviceId=AreaView.ObjectList{1}.DevIDRef;
    % returning the MdlFilePath for use in the further 'ImportXML' function
    MdlFilePath = AreaView.FilePath;
    
    Send2GUI({[' ^^^ Import of BA objects done. ^^^'];' ';' '},h.status);
    
    % In Version MP1.2 wird der Chart nach dem BA importiert.
    if (strcmp(Version , 'MP1.2') == 1)
        BaObjRef.DeviceId = DeviceId;
        % 2014-07-21, Stefan Boetschi: Import multiple charts
        Chart = dir([pathstr '\CFCCharts\*@' AF '.xml']);
        if (numel(Chart) > 0)
            chartName = Chart.name;
            chartFilePath = [pathstr '\CFCCharts\' chartName];
            [in out err] = ImportXML(chartFilePath,MdlFilePath,BaObjRef,h,FirmwareLib);
        else
            charts = dir([pathstr '\CFCCharts\*.xml']);
            if (numel(charts) == 1)
                chartName = charts(1).name;
                chartFilePath = [pathstr '\CFCCharts\' chartName];
                [in out err] = ImportXML(chartFilePath,MdlFilePath,BaObjRef,h,FirmwareLib);
            else
                for nCh = 1:numel(charts)
                    chartName = charts(nCh).name;
                    chartFilePath = [pathstr '\CFCCharts\' chartName];
                    [in out err] = ImportXML(chartFilePath,MdlFilePath,BaObjRef,h,FirmwareLib);
                    Send2GUI({' ';' ';' '},h.status);
                end % FOR
            end
        end
        Send2GUI({[' ^^^ Chart import done. ^^^'];' ';' '},h.status);
    end
end
end
