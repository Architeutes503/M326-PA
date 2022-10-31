function [CntOfInputs, CntOfOutputs, Errors] = ImportXML (xmlFile, mdlFile, BaObjRef, h, FirmwareLib)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   (C) Copyright by Siemens Schweiz AG, Building Technologies Group,
%       HVAC Products, 2012
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Project                     : IMSES
%   Target Hardware             : PC 
%   Target Operating System     : WinXP Console
%   Language/Compiler           : Matlab 2010 and higher 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Workfile                    : ImportXML.m
%   Author                      : Thomas Weiss, 
%                                 Thomas Rohr, 
%                                 Maximilian von Gellhorn
%   Version                     : v1.5
%   Date                        : 2012-03-20
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Matlab Informations
%   Ensure you have successfully downloaded the "XMl2STRUCT" function 
%   from MATLAB File Exchange:
%   http://www.mathworks.com/matlabcentral/fileexchange/28518-xml2struct
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:
%   ImportXML Converts "Step7"-chart into Simulink subsystem
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function/Interface:
%
% Declaration:
%   [CntOfInputs, CntOfOutputs, Errors] = 
%                   ImportXML(xmlFile, system, BaObjRef)
%
% Inputs:
%   xmlFile         - Step7 XML import file
%   mdlFile         - System in which the Charts will be placed
%   BaObjRef        - structure with the field "DeviceID"
%   h               - handle for GUI communication 
%
% Outputs:
%   CntOfInputs     - number of inputs (InterChartConnection).
%   CntOfOutputs	- number of outputs (InterChartConnection).
%   Errors	 	    - true in case of error
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Revision History 
% 	(Put meaningful comments in SourceSafe for log below!)
% 	(Please remove blank lines and very old comments!)
%
%   2014-08-05 16:10 Stefan Boetschi
%   Several bugfixes regarding the MP1.2 import
%
%   2014-07-21 12:00 Stefan Boetschi
%   Updated messages sent to the GUI
%
%   2014-07-15 16:00 Stefan Boetschi
%   dissolveAlgebraicLoops() also for nested charts (MP1.2)
%
%   2014-06-24 16:00 Stefan Boetschi
%   Adapted chart import to MP1.2 (nested charts)
% 	
% 	2012-03-20 14:00 Thomas Rohr
%	Header comment was attached
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% selecting the status box Handle
h.status = 0; %h.edit_1_2;  DOZ
%% Firmware Library
[pathstr, name, ext] = fileparts(FirmwareLib);
FirmwareLib=name;
%% xml-File
[pathstr, name, ext] = fileparts(xmlFile);
XMLFileName=[name ext];
%
Send2GUI([' === Start importing chart file : ' XMLFileName ' ==='],h.status);
Send2GUI([' === (<' xmlFile '>) ==='],h.status);
Errors = false;
%
% Import XML-File
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% http://www.mathworks.com/matlabcentral/fileexchange/28518-xml2struct
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xml = xml2struct(xmlFile);

topChartAddress = xml.AutomatedBuild.Chart.Attributes.Name;

ChartAddress  = regexp(topChartAddress,...
    '(.*)''(.*)@(.*)','tokens');
% Example: R_1''Rad01@HCSta01
%ChartAddress{1}(1,1)  --> R_1
%ChartAddress{1}(1,2)  --> Rad01
%ChartAddress{1}(1,3)  --> HCSta01
%
system = ChartAddress{1}(1,1);
subsystem = [char(ChartAddress{1}(1,1)) '/' ...
    char(ChartAddress{1}(1,2))];

FullChartAddress = [char(ChartAddress{1}(1,1)) '/' ...
    char(ChartAddress{1}(1,2)) '/' ...
    char(ChartAddress{1}(1,3))];

tempChartAddress  = regexp(topChartAddress,'(.*)@(.*)','tokens');
if (isempty(tempChartAddress))
    ObjName = strcat(system, '/', topChartAddress);
else
    ObjName = [system, '/', tempChartAddress{1}(1,2)];
end

Send2GUI(['     > Starting system import [' FullChartAddress ']'],h.status);

if get(h.cheackbox_1_1,'Value')==1
    nestChartFlag = false;
    if isfield(xml.AutomatedBuild.Chart,'Link')
        xml = dissolveAlgebraicLoop(xml, h, xml.AutomatedBuild.Chart.Attributes.Name, nestChartFlag,...
            topChartAddress, ObjName);
    else
        stepin = '     >';
        Send2GUI([stepin ' === The chart ' xml.AutomatedBuild.Chart.Attributes.Name ' does not contain any links. ==='],h.status);
    end
end %if

% setappdata(0,'xml',xml)
% xml = getappdata(0,'xml');
%
% Create a subsystem within the target system for importing the chart
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Check if the system already exists             
if ~(exist([mdlFile '\' char(system) '.mdl']) == 2)
    new_system(system);
    save_system(system,[mdlFile system{1} '.mdl'])
    Send2GUI(['     > Added a new system (' system{1} '.mdl)'],h.status)
    
else
    Send2GUI(['     > System ' system{1} '.mdl already exists'],h.status)
end% if
% open target system
open_system([mdlFile system{1} '.mdl'])
% proof if Application Function and Chart exist already
SysList = find_system(ChartAddress{1}(1,1),'BlockType','SubSystem');
AF_exist = 0; Chart_exist = 0;
for i=1:length(SysList)
    AF_exist = AF_exist + strcmp([char(ChartAddress{1}(1,1)) '/' char(ChartAddress{1}(1,2))], SysList(i));
    Chart_exist = Chart_exist + strcmp(FullChartAddress, SysList(i));
end% for

if AF_exist == 0
    % add Application Function if block not exists    
    ObjName = [char(ChartAddress{1}(1,1)) '/' char(ChartAddress{1}(1,2))];
    add_block('built-in/SubSystem',ObjName, 'Position',getPos(ObjName));
    
    %% configure Chart subsystem
    set_param (ObjName,...
        'MaskDisplay', sprintf('disp (''Chart'');'),...
        'Mask','on',...
        'BackgroundColor','lightblue',...
        'MaskIconOpaque', 'on',...
        'MaskIconUnits','Autoscale',...
        'MaskIconRotate','off');    
    
    Send2GUI(['     > Added subsystem (' [char(ChartAddress{1}(1,1)) '/' char(ChartAddress{1}(1,2))] ')'],h.status)    
end% if (AF_exist == 0)
% proof if Chart exists already
if Chart_exist == 0 

SubName  = char(ChartAddress{1}(1,3));
%adding the Subsystem that Contains the imported Chart
SubBlock = add_block('built-in/SubSystem',FullChartAddress, ...
   'Mask','On', ...
   'MaskIconOpaque','off', ...
   'MaskIconUnits','normalized', ...
   'MaskDisplay',sprintf('plot([0.5,0.5],[0.05,0.9]);text(0.5, 0.95,''%s'', ''HorizontalAlignment'',''center'',''VerticalAlignment'',''middle'')',SubName), ...
   'ShowName','off');
set(SubBlock,'Position',[100 700 200 800]);
system   = FullChartAddress;


%
% load and determine all block names from the Simulink TRA Library
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
libTRA = find_system(FirmwareLib,'BlockType','SubSystem');
BaObjRef.ObjectId = xml.AutomatedBuild.Chart.Attributes.ObjectId;

ImportChart (xml.AutomatedBuild.Chart, FullChartAddress, libTRA, h, BaObjRef, topChartAddress);
Send2GUI(['     > Finished system import [' FullChartAddress ']'],h.status);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2014-06-24, Stefan Boetschi: Parse the interface of the chart and add the 
% constants which are connected to the inputs of nested charts
system = FullChartAddress;
xml = xml.AutomatedBuild.Chart;
if isfield(xml,'NestedCharts')
    % Iterate over all nested charts
    for nNestChart = 1 : numel(xml.NestedCharts)
        % Check if only one NestedChart is existing
        % Thomas Weiss 14-04-15
        if numel(xml.NestedCharts) == 1
            % only one NestedChart --> no Array
            NestChart = xml.NestedCharts;
        else
            % more than one NestedChart --> Array
            NestChart = xml.NestedCharts{nNestChart};
        end
        % Assemble the chart address
        ChartAddress  = regexp(NestChart.Attributes.Name,'(.*)@(.*)','tokens');
        if (isempty(ChartAddress))
            subsystem = strcat ([system, '/'], NestChart.Attributes.Name);
        else
            subsystem = char(strcat ([system, '/'], ChartAddress{1}(1,2)));
        end
        % Function call: generateNestedChartInterface
        generateNestedChartInterface(NestChart,subsystem,system);
    end % END FOR: nestedCharts
end % END IF: isfield nestedCharts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Position Subsystems
% (12-02-07 - Thomas Rohr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get the number of Inputs and Outputs
CntOfInputs  = numel(find_system(system,'BlockType','Inport'));
CntOfOutputs = numel(find_system(system,'BlockType','Outport'));
% calculate the Blocksize due to number of inputs and outputs
if max(CntOfOutputs,CntOfInputs) == 0
    yBlockSize=50+15;
end
if max(CntOfOutputs,CntOfInputs) > 0
    yBlockSize=50+max(CntOfOutputs,CntOfInputs)*15;
end
% get the SubBlock Address
SubBlock=[get(SubBlock,'Path') '/' get(SubBlock,'Name')];
% get the SubBlock Position
BlockPos=getPos(SubBlock);
% change the SubBlock Y-BlockSize due to the number of In- and Outputs
BlockPos(4) = BlockPos(2)+yBlockSize;
% set the Blockposition 
set_param(SubBlock,'Position',BlockPos);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2014-06-24, Stefan Boetschi: Do no longer need this function
% % Link InterChartConnection
% % Start a for loop over all links that should be created
% % (12-01-31 - Thomas Rohr)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Error=InterChartConnection(subsystem);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
else    

CntOfInputs  = numel(find_system(system,'BlockType','Inport'));
CntOfOutputs = numel(find_system(system,'BlockType','Outport'));
Send2GUI({...
    ['     HINT : The chart ' FullChartAddress ' already exists'];...
    ['          in the model ' mdlFile]} ,h.status)
Send2GUI(' ^^^ -> Import aborted. ^^^',h.status)
end% if (Chart_exist == 0)
