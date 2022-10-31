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
% 	2012-03-20 14:00 Thomas Rohr
%	Header comment was attached
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% selecting the status box Handle
    h.status = h.edit_1_2;
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
	% initial part
    expr=xpath.compile('.//EOTypeRef[@Prototype="44"]');
    result=expr.evaluate(xDoc, XPathConstants.NODE);
    result=result.getParentNode.getParentNode;
    expr=xpath.compile('.//ShortDescription/@Value');
    result=expr.evaluate(result, XPathConstants.STRING);
    ActualModel= [result '.mdl'];
    if exist(ActualModel) == 4
        Send2GUI(['     HINT : The File ' ActualModel ' exists already'],h.status);
        % Construct a questdlg
        choice = questdlg({['The File ' ActualModel ' exists already'];' ';'Do you want to overwrite it ?'}, ...
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
        Send2GUI([' === Start import BA-file : ' BAFileName '  to  ' ActualModel ' ==='],h.status);
        Send2GUI([' === <' xmlFile '> ==='],h.status);
        % This Number is a significant number to detect with which Schema
        % the Application Function was bulid
        Send2GUI([' === <SBTDocument ... SiBXSchemaVersion=" ' char(xRoot.getAttribute('SiBXSchemaVersion')) ' "> ==='],h.status);
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
		% subroutine parse
        AreaView.parse;
        % subroutine generate
        AreaView.generate;
        Errors=0;
		% returning the DeviceId for use in the further 'ImportXML' function
        DeviceId=AreaView.ObjectList{1}.DevIDRef;
        % returning the MdlFilePath for use in the further 'ImportXML' function
        MdlFilePath = AreaView.FilePath;
        Send2GUI([' ^^^ <' xmlFile '> ^^^'],h.status);
        Send2GUI({[' ^^^ BA-Import done... ^^^'];' ';' '},h.status);
    end    
end
 