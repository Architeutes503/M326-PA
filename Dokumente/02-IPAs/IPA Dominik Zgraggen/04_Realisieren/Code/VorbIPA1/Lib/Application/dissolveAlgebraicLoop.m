function [ xml ] = dissolveAlgebraicLoop(xml, h, chartName, nestChartFlag,...
    topChartAddress, ObjName)
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
%   xml Struct with has a new parameter "MemoryModule" insert by the xml
%   Note <Link>. That shows that there has to come an 1/z  block.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Necessary Files:
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function/Interface:
%
% Declaration:
%
%
% Inputs:
%   xml               - xml Structure (Created from xml2Struct)
%   h                 - h (GUI Handle)
%   XMLFileName       - Name of the xml File for the Error Massage
%   nestChartFlag     - TRUE if the current xml struct describes a nested
%                       chart (MP1.2)
%   topChartAddress   - address of the top chart
%   ObjName           - chart address needed for correct tabbing of GUI
%                       messages
% Outputs:x
%   xml               - xml Structure
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Revision History
%
%   2014-07-21 12:00 Stefan Boetschi
%   Adapted messages sent to the GUI (correct tabbing)
%
%   2014-07-15 09:10 Stefan Boetschi
%   Adapted function for used with the MP1.2 export (incl. nested charts)
%
%   2013-04-09 09:45
%   Document Created
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% selecting the status box Handle
h.status = h.edit_1_2;

% Creates a xml struct with only the Links from the xml Chart File
try
    if (nestChartFlag == true)
        stepin = ['     ' char (45 * ones (1, (length (strfind (ObjName, '/')) - 2) * 2 )) '> '];
        xmllink = xml.Link;
        xmlinterface = xml.Interface;
        curChartAddress = xml.Attributes.Name;
    else
        stepin = '     >';
        xmllink = xml.AutomatedBuild.Chart.Link;
        curChartAddress = xml.AutomatedBuild.Chart.Attributes.Name;
        xmlinterface = xml.AutomatedBuild.Chart.Interface;
    end
    % 2014-07-15, Stefan Boetschi: Preprocess the attributes FromFBName and
    % ToFBName in order to identify the actual block names
    xmllink = extractBlockNames(xmllink,curChartAddress,topChartAddress);
    % 2014-07-15, Stefan Boetschi: Interchart links are NOT taken into
    % account when dissolving algebraic loops
    xmllink = removeInterChartLinks(xmllink,xmlinterface);
    % Remove unrelated links
    xmllink = deleteUnrelatedLinks (xmllink, h, ObjName);
    if length(xmllink) >= 2;
        % xmllink = sortStructList(xmllink, xml, h, nestChartFlag);
        xml = insertMemoryBlock(xmllink, xml, h, nestChartFlag,...
            topChartAddress, curChartAddress);
        Send2GUI([stepin ' === Algebraic loops successfully dissolved in the chart ' chartName ' ==='],h.status);
    else
        Send2GUI([stepin ' === No algebraic loops enfolding multiple blocks in the chart ' chartName ' ==='],h.status);
    end%if
catch ME
    Send2GUI([stepin ' === ERROR in dissolving algebraic loops => [' ME.message '] ===' ],h.status);
    return;          %statement for exit the function
end % catch

end %function

