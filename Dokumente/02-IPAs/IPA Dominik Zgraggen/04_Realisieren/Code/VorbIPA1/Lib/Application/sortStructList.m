function [ xmllink ] = sortStructList( xmllink, xml, h, nestChartFlag )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   (C) Copyright by Siemens Schweiz AG, Building Technologies Group,
%       HVAC Products, 2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Project                     : IMSES
%   Target Hardware             : PC 
%   Target Operating System     : WinXP / Win7 Console
%   Language/Compiler           : Matlab 2010 and higher 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Workfile                    : sortStructList.m
%   Author                      : Maximilian von Gellhorn
%   Version                     : v0.1
%   Date (yyyy-mm-dd)           : 2013-04-09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Matlab Informations
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:
%   This function sorts the Links in a cell array after their
%   Function Block Type. The rule to sort is. first the CMD Function Blocks
%   then the PID Function Blocks and after that all the other Block typs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function/Interface:
%
% Declaration:
%   
%
% Inputs:
%   xmllink           - xmllink Structure of the Links from the Chart file
%   xml               - xml structure of a File
%   h                 - h (GUI Handle)
%   nestChartFlag     - TRUE if the current xml struct describes a nested
%                       chart (MP1.2)
% Outputs:
%   xmllink           - sorted xmllink Structure 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Revision History 
%
%   2014-07-15 09:10 Stefan Boetschi
%   Adapted function interface and GUI messages due to nested charts
% 	
%   2013-04-10 08:50
%   Document Created
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% selecting the status box Handle
h.status = h.edit_1_2;
% select all FB from the xml Chart
try
if (nestChartFlag == true)
    xmlFB = xml.FB;
else
    xmlFB = xml.AutomatedBuild.Chart.FB;
end
% creates array with all FB BlockName
xmllinkname = cellfun(@(x) x.Attributes.FromFBName, xmllink, 'UniformOutput',0);
% creates array with all FB Name
xmlFBBlockName = cellfun(@(x) x.Attributes.Name, xmlFB, 'UniformOutput',0);
% creates array with all FB Typ's. Typ and BlockName from xmlFB
xmlFBtyp = cellfun(@(x) x.Attributes.Typ, xmlFB, 'UniformOutput',0);
%xmlFB = [xmlFBname;xmlFBtyp]
%FoundFBTyp indicates whether the FBName has been found. 1 = yes / 0 = no
%FBTypPos indicates which position in the FBName xmlFBTyp is.
[FoundFBTyp, FBTypPos] = ismember(xmllinkname,xmlFBBlockName);
catch ME
    Send2GUI([' === Error ===' ],h.status);
    Send2GUI(['Error Massage : ' (ME.message)],h.status);
    return;          %statement for exit the function
end % catch
try
if all(FoundFBTyp(:))%if all FB Typs where found
    xmlFBNameTyp = [xmlFBBlockName ; xmlFBtyp];
    
    % Loop through all xml Links to get their Typ.
    for idx = 1 : length(xmllink);     
         xmllinkname{2,idx} =  xmlFBtyp{FBTypPos(idx)};
    end% for    
    
    tmp = cell(1,length(xmllink) );
    pos = 1;
   sortorder = cell(1, 3);
   sortorder= {'CMD'  'PID' '*'};
    for idx = 1 : 3;     
         for idx2 = 1 : length(xmllinkname);     
             if  strfind (xmllinkname{2,idx2},sortorder{idx})
                 tmp{pos} = xmllink{idx2};
                 xmllinkname{2,idx2} = '';
                 pos = pos +1;
             elseif sortorder{idx} == '*'
                 if cellfun(@isempty,xmllinkname(2,idx2)) == 0
                     tmp{pos} = xmllink{idx2};
                    xmllinkname{2,idx2} = '';
                    pos = pos +1;
                 end %if
             end%if
        end% for        
    end% for     
    xmllink = tmp;  
    
else    
   Send2GUI([' === Algebraic loop dissolver: function sortStrucList() failed ==='],h.status);
end% if
catch ME
    Send2GUI([' === Error ===' ],h.status);
    Send2GUI(['Error message : ' (ME.message)],h.status);
    return;          %statement for exit the function
end % catch
end %function

