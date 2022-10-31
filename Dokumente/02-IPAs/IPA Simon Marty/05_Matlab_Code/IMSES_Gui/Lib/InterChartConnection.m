function [ Error ] = InterChartConnection( subsystem )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   (C) Copyright by Siemens Schweiz AG, Building Technologies Group,
%       HVAC Products, 2012
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Project                     : IMSES
%   Target Hardware             : PC 
%   Target Operating System     : WinXP Console
%   Language/Compiler           : Matlab 2010 and higher 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Workfile                    : InterChartConnection.m
%   Author                      : Thomas Rohr
%   Version                     : v1.0
%   Date                        : 2012-03-20
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Matlab Informations
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:
%   "Inter Chart Connections" are connections between the subsystems that 
%   contain the imported Charts. The In- and Output Pins that will be 
%   connected have the same name. With every call the function deletes 
%   all existing "Inter Chart Connections" and connects all connections 
%   again.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function/Interface:
%
% Declaration:
%   [ Error ] = InterChartConnection( subsystem )
%
% Inputs:
%   subsystem       - Address of the actual Subsystem
%
% Outputs:
%   Error           - Errors
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
InportList  = find_system(subsystem,'followLinks','on','LookUnderMasks','on','SearchDepth',2,'BlockType','Inport');
OutportList = find_system(subsystem,'followLinks','on','LookUnderMasks','on','SearchDepth',2,'BlockType','Outport');
for nOutL=1:length(OutportList)
    for nInL=1:length(InportList)
        if strcmpi(get_param(OutportList(nOutL),'Name'),get_param(InportList(nInL),'Name'))
        % Proof if Connection exists
          % Get PortConnectivity of actual Inport Block
	      PortCon=get_param(get_param(InportList(nInL),'Parent'),'PortConnectivity');
		  % Get Port Number of actual Inport Block
          DstPortNum=get_param(InportList(nInL),'Port');
          % Convert Result to Number
          DstPortNum=str2num(DstPortNum{1});
          % Initialise SrcPort
          SrcPort='RandomString';
           % Proof if any Connection is existing
           if PortCon{1}(DstPortNum).SrcBlock ~= -1
                % Get Adress of Source Block
                SrcBlock=[get_param(PortCon{1}(DstPortNum).SrcBlock,'Parent') '/' ... 
                        get_param(PortCon{1}(DstPortNum).SrcBlock,'name')];
              % Get Number of Source Ports
              SrcPortNum=PortCon{1}(DstPortNum).SrcPort + 1;
              %  Get Name of Source Port
              SrcBlockOutPortList=find_system(SrcBlock,'SearchDepth',1,'BlockType','Outport');
              SrcPort=get_param(SrcBlockOutPortList(SrcPortNum),'name');
              % Compare Portnames of Source Port and Destination Port
              % if Portnames are not equal, no connection exists
           end
           if strcmpi(SrcPort,get_param(InportList(nInL),'Name'))
                %delete Connections between Ports with equal name
                % Get Port Number of Inport
                InPortNum  = get_param(InportList(nInL) ,'Port');
                % Get Port Number of Outport  
                OutPortNum = get_param(OutportList(nOutL),'Port');
                % delete the InterChartConnection  
%                 delete_line(subsystem, ...
%                     [char(get_param(get_param(OutportList(nOutL),'Parent'),'name')) '/' OutPortNum{1}], ...  
%                     [char(get_param(get_param(InportList(nInL) ,'Parent'),'name'))  '/' InPortNum{1}]);               
           end
           
          if (~strcmpi(SrcPort,get_param(InportList(nInL),'Name')) || (PortCon{1}(DstPortNum).SrcBlock == -1))
                %Connect the Ports with equal name
                % Get Port Number of Inport
                InPortNum  = get_param(InportList(nInL) ,'Port');
                % Get Port Number of Outport  
                OutPortNum = get_param(OutportList(nOutL),'Port');
                % Add the InterChartConnection  
                add_line(subsystem, ...
                    [char(get_param(get_param(OutportList(nOutL),'Parent'),'name')) '/' OutPortNum{1}], ...  
                    [char(get_param(get_param(InportList(nInL) ,'Parent'),'name'))  '/' InPortNum{1}], ...
                    'autorouting','on');       
          end
        end    
    end
end 

%%
Error =0;
end

