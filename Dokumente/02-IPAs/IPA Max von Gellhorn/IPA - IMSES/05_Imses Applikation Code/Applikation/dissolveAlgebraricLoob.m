function [ xml ] = dissolveAlgebraricLoob(xml, h,XMLFileName)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   (C) Copyright by Siemens Schweiz AG, Building Technologies Group,
%       HVAC Products, 2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Project                     : IMSES
%   Target Hardware             : PC 
%   Target Operating System     : WinXP / Win7 Console
%   Language/Compiler           : Matlab 2010 and higher 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Workfile                    : dissolveAlgebraricLoob.m
%   Author                      : Maximilian von Gellhorn
%   Version                     : v0.1
%   Date (yyyy-mm-dd)           : 2013-04-09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Matlab Informations
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:
%   This is a Function that dissolves algebraic loop. This is the main
%   Function that calls the other Functions. (deleteUnrelatedLinks.m,
%   sortStructList.m, insertMemoryModule) The Function retourns a updated
%   xml Struct with has a new parameter "MemoryModule" insert by the
%   <Link>. That shows that there has to come an 1/z  block.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Necessary Files:
%
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function/Interface:
%
% Declaration:
%   
%
% Inputs:
%   xml          - xml Structure (Created from xml2Struct)
%
% Outputs:x
%   xml           - xml Structure
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Revision History
%   2013-04-09 09:45
%   Document Created
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% selecting the status box Handle
h.status = h.edit_1_2;

% Creates a xml struct with only the Links from the xml Chart File
try
xmllink = xml.AutomatedBuild.Chart.Link;
xmllink = deleteUnrelatedLinks (xmllink, h);
if length(xmllink) >= 2;
    xmllink = sortStructList(xmllink, xml, h);
    xml = insertMemoryModule(xmllink, xml, h);
    Send2GUI([' === Algebraic loops successfully dissolved in : ' XMLFileName ' ==='],h.status);
else
    Send2GUI([' === No algebraic loops in : ' XMLFileName ' ==='],h.status);
end%if
catch ME
    Send2GUI([' === Error ===' ],h.status);
    Send2GUI(['Error Massage : ' (ME.message)],h.status);
    return;          %statement for exit the function
end % catch
end

