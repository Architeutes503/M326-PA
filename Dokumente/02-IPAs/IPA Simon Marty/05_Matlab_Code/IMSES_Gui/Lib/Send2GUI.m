function  Send2GUI( MsgString,h )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   (C) Copyright by Siemens Schweiz AG, Building Technologies Group,
%       HVAC Products, 2012
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Project                     : IMSES
%   Target Hardware             : PC 
%   Target Operating System     : WinXP Console
%   Language/Compiler           : Matlab 2010 and higher 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Workfile                    : Send2GUI.m
%   Author                      : Thomas Rohr
%   Version                     : v1.0
%   Date                        : 20-Feb-2012
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Matlab Informations     
%
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
%    MsgString    - String that shall be send to the GUI
%    h            - handle for GUI communication 
%
% Outputs:
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
    OldStr=get(h, 'String');
    set(h, 'String', [OldStr;MsgString])
end