function [ xml ] = insertMemoryBlock(xmllink, xml, h,...
    nestChartFlag, topChartAddress, curChartAddress, ObjName)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   (C) Copyright by Siemens Schweiz AG, Building Technologies Group,
%       HVAC Products, 2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Project                     : IMSES
%   Target Hardware             : PC
%   Target Operating System     : WinXP / Win7 Console
%   Language/Compiler           : Matlab 2010 and higher
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Workfile                    : insertMemoryModule.m
%   Author                      : Maximilian von Gellhorn
%   Version                     : v0.1
%   Date (yyyy-mm-dd)           : 2013-04-10
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Matlab Informations
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:
%   This function insert a new Parameter "MemoryModule" ino the xml Chart
%   structure. The  "MemoryModule" is inserted after a Link that needs a
%   1/z Memory Module to prevent a Algebric Loop.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function/Interface:
%
% Declaration:
%
%
% Inputs:
%   xmllink           - xmllink Structure of the Links from the Chart file.
%   xmlinterface      - xmlinterface structure from the chart file
%   xml               - xml structure of a Chart File.
%   h                 - h (GUI Handle)
%   nestChartFlag     - TRUE if the current xml struct describes a nested
%                       chart (MP1.2)
%   topChartAddress   - Address of the top chart
%   curChartAddress   - Address of current chart
%   ObjName           - chart address needed for correct tabbing of GUI
%                       messages
% Outputs:
%   xml               - xml structure of a Chart with Memory Module
%                       Parameter.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Revision History
% 	(Put meaningful comments in SourceSafe for log below!)
% 	(Please remove blank lines and very old comments!)
%
%   2014-07-16 08:30 Stefan Boetschi
%   Adapted messages sent to the GUI (correct tabbing)   
%
%   2014-07-15 14:20 Stefan Boetschi
%   Adapted for use with nested charts (MP1.2)
%
%   2013-04-10 12:00
%   Document Created
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% selecting the status box Handle
h.status = h.edit_1_2;

if (nestChartFlag == true)
    tmpxmllink  = xml.Link;
else
    tmpxmllink  = xml.AutomatedBuild.Chart.Link;
end
% Keep unaltered block name data as return structure
retxmllink = tmpxmllink;
% Extract actual block names from MP1.2 export data (only needed for
% comparison with the data in the structure xmllink!)
tmpxmllink = extractBlockNames(tmpxmllink,curChartAddress,topChartAddress);
try
    for idx = 1 : length(xmllink);% Loop through all xmllinks
        for idx2 = 1 : length(tmpxmllink) % Loop
            if strcmp(xmllink{idx}.Attributes.FromFBName,tmpxmllink{idx2}.Attributes.FromFBName) && ...
                    strcmp(xmllink{idx}.Attributes.FromPin,tmpxmllink{idx2}.Attributes.FromPin) && ...
                    strcmp(xmllink{idx}.Attributes.ToFBName,tmpxmllink{idx2}.Attributes.ToFBName) && ...
                    strcmp(xmllink{idx}.Attributes.ToPin,tmpxmllink{idx2}.Attributes.ToPin) && ...
                    strcmp(xmllink{idx}.Attributes.Negate,tmpxmllink{idx2}.Attributes.Negate)
                [retxmllink{idx2}.Attributes(:) .MemoryModule]=('true');
                xmllink(:,idx) = [];
                xmllink = deleteUnrelatedLinks (xmllink,h);
                if length(xmllink) == 0; break
                end %if
            end %if
        end %for
        if length(xmllink) <= 1;
            if (nestChartFlag == true)
                xml.Link = retxmllink;
            else
                xml.AutomatedBuild.Chart.Link = retxmllink;
            end
            break
        end%if
    end %for
catch ME
    stepin = ['     ' char (45 * ones (1, (length (strfind (ObjName, '/')) - 2) * 2 )) '> '];
    Send2GUI([stepin ' === ERROR in dissolving algebraic loops => [' ME.message '] ===' ],h.status);
    return;          %statement for exit the function
end % catch

end % function

