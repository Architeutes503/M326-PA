function [ xmllink ] = deleteUnrelatedLinks( xmllink, h, ObjName )
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
%   This function deletes from a XML Chart struct every link with has not
%   a connection line to the "InPin" or to the "OutPin". If after this
%   functions, there are links in the struct, there is a algebric loop.
%   If there aren't any links left, there is no algebric loop in 
%   this xml Chart file.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function/Interface:
%
% Declaration:
%   
%
% Inputs:
%   xmllink           - xmllink Structure of the Links from the Chart file
%   h                 - h (GUI Handle)
%   ObjName           - chart address needed for correct tabbing of GUI
%                       messages
% Outputs:
%   xmllink           - xmllink Structure with only the Links that has a
%                       InPut or a Output
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Revision History 
% 	(Put meaningful comments in SourceSafe for log below!)
% 	(Please remove blank lines and very old comments!)
%
%   2014-07-16 08:30 Stefan Boetschi
%   Adapted messages sent to the GUI (correct tabbing)
% 	
%   2013-04-09 09:45
%   Document Created
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% selecting the status box Handle
h.status = h.edit_1_2;
bolExitLoop = false;% boolaen for exit the main Loop, wenn all the 
                    % remaining links have a InPut Connoction.
                    
AnzahlElemente = length(xmllink); % Number of Elements in the Array Struct

%loop for deleteing the Links that has no InPut Connections 
try
while (bolExitLoop ~= true)
    idx = 1;
    bolExitLoop = true;    
    while idx <= AnzahlElemente % loop through all Elements.
        link2Compare = xmllink{idx}.Attributes.FromFBName;        
        bolDeleted = true;
        for idx2=1 : length(xmllink);% Loop for compare each FromFBName
            % element with all ToFBName elements            % 
            if strcmp(xmllink{idx2}.Attributes.ToFBName,link2Compare);
                %loop through all ToFBName Elements
                bolDeleted = false;
                break 
            end%if    
        end%for
        if bolDeleted % IF the Element has no InPut Connection -> Delete it
            xmllink(:,idx) = [];
            bolExitLoop = false;
            bolDeleted = true;
            AnzahlElemente = AnzahlElemente-1;%Decrease amount of Elements
            %*prevents overflow  of the loop
        else
            idx = idx + 1;
        end%if
    end%while2    
end%while2

bolExitLoop=false;
%loop for deleteing the Links that has no OutPut Connections 
while (bolExitLoop ~= true)
    idx = 1;
    bolExitLoop = true;
    
    while idx <= AnzahlElemente % loop through all Elements.
        link2Compare = xmllink{idx}.Attributes.ToFBName;        
        bolDeleted = true;
        for idx2=1 : length(xmllink);% Loop for compare each FromFBName
            % element with all ToFBName elements            % 
            if strcmp(xmllink{idx2}.Attributes.FromFBName,link2Compare);
                %loop through all ToFBName Elements
                bolDeleted = false;
                break 
            end%if    
        end%for
        if bolDeleted % IF the Element has no InPut Connection -> Delete it
            xmllink(:,idx) = [];
            bolExitLoop = false;
            bolDeleted = true;
            AnzahlElemente = AnzahlElemente-1;%Decrease amount of Elements
            %*prevents overflow  of the loop
        else
            idx = idx + 1;
        end%if
    end%while2    
end%while2
catch ME
    stepin = ['     ' char (45 * ones (1, (length (strfind (ObjName, '/')) - 2) * 2 )) '> '];
    Send2GUI([stepin ' === ERROR in dissolving algebraic loops => [' ME.message '] ===' ],h.status);
    return;          %statement for exit the function
end % catch
end %function


















