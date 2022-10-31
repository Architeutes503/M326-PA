classdef BA_MULTI < BA_OBJ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   (C) Copyright by Siemens Schweiz AG, Building Technologies Group,
%       HVAC Products, 2012
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Project                     : IMSES
%   Target Hardware             : PC 
%   Target Operating System     : WinXP Console
%   Language/Compiler           : Matlab 2010 and higher 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Workfile                    : BA_MULTI.m
%   Author                      : Thomas Rohr
%   Version                     : v1.0
%   Date                        : 20-Feb-2012
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Matlab Informations
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:
%      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function/Interface:
%	  
%
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
    properties
        NumOfStates
        DefValue
		Value
    end    
    methods 
        function generate(obj, ObjList)
            try
                %% add block
                add_block([obj.FWLib '/BA_OBJECT/' obj.ObjectType '_'],obj.ObjectName,'Position', getPos(obj.ObjectName));
                %% configure block
                set_param(obj.ObjectName,'DeviceId',obj.DevIDRef,'ObjectId',obj.ObjIDRef);
                if not(isempty(obj.NumOfStates))
                    set_param(obj.ObjectName,'NumOfStates',obj.NumOfStates);
                end
                if not(isempty(obj.DefValue))
                    set_param(obj.ObjectName,'DefValue',obj.DefValue);
                end
            catch
                Send2GUI(['    ERROR : The Block' obj.ObjectType 'is not existing in the Simulink Firmware Library'],obj.h);
            end
            ObjName = obj.ObjectName(find(obj.ObjectName=='/',1,'last')+1 : length(obj.ObjectName));
            tabs = char (9 * ones (1, (length (strfind (obj.ObjectName, '/'))-1)));
            fwrite (ObjList, sprintf('%s%s\t%s\t%s\t%s\n', tabs, ObjName, obj.ObjIDRef, obj.DevIDRef, obj.ObjectType));

        end  
    end
end