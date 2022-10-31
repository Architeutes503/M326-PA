classdef BA_GROUPMASTER < BA_OBJ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   (C) Copyright by Siemens Schweiz AG, Building Technologies Group,
%       R&D Zug, Comfort Systems, System Applications, 2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Project                     : IMSES
%   Target Hardware             : PC 
%   Target Operating System     : WinXP Console
%   Language/Compiler           : Matlab 2010 and higher 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Workfile                    : BA_GROUPMASTER.m
%   Author                      : Stefan Boetschi
%   Version                     : v1.0
%   Date                        : 11.10.2013
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
%   2013-10-31 14:45 Stefan Boetschi
%   Write 0 instead of NaN if no Group-Category/Group-Number
%
%   2013-10-25 15:20 Stefan Boetschi
%   Added property CollectDataDelay to generate() method   
%
%   2013-10-24 14:00 Stefan Boetschi
%   Completed generate() method
% 	
%   2013-10-11 08:45 Stefan Boetschi
%   Output to ObjectList.txt adapted
%
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
       GroupCategoryText
       GroupCategory
       GroupNumber
       OutOfService
       AcknowledgeTimeout
       CommandRetryCount
       CollectDataDelay
       HeartbeatInterval
    end
    methods
        function generate(obj, ObjList)
            %% Write block information to file ObjectList.txt
            tabs = char (9 * ones (1, (length (strfind (obj.ObjectName, '/')) - 1)));
            name = obj.ObjectName(find(obj.ObjectName=='/',1,'last')+1 : length(obj.ObjectName));
            
            % Check if Group number and group category are defined for the
            % current Group-Master-Object
            if ~isempty(obj.GroupNumber)
                GroupNumStr = obj.GroupNumber;
                GroupNum = GroupNumStr;
            else
                GroupNumStr = '<no GroupNumber>';
                GroupNum = '0';
            end
            if ~isempty(obj.GroupCategory)
                GroupCat = obj.GroupCategory;
                GroupCatStr = GroupCat;
            else
                GroupCat = '<no GroupCategory>';
                GroupCatStr = '0';
            end
            fwrite (ObjList, sprintf('%s%s\t%s\t%s\t%s\t%s\t%s\t%s\n', tabs, name, obj.ObjIDRef, obj.DevIDRef, obj.ObjectType,...
                obj.GroupCategoryText, GroupCatStr, GroupNumStr));
            
            %% Try to add block (copy from the Firmware Library)
            try
                add_block([obj.FWLib '/BA_OBJECT/BA_G_MSTR_'],obj.ObjectName,'Position',getPos(obj.ObjectName));
            catch
                Send2GUI(['    ERROR : The Block ' obj.ObjectType ' does not exist in the Simulink Firmware Library.'],obj.h);
            end
            
            %% Configure block
            % Object identifier, Device identifier
            set_param(obj.ObjectName,'DeviceId',obj.DevIDRef,'ObjectId',obj.ObjIDRef);
            % Group category, Group number
            set_param(obj.ObjectName,'GroupCat',GroupCat,'GroupNum',GroupNum); 
            % Default value for out of service flag (need to get the value
            % as string!)
            if strcmp(obj.OutOfService,'true')
                DefOutOfService = '1';
            elseif strcmp(obj.OutOfService,'false')
                DefOutOfService = '0';   
            else
                % -> Default value: OutOfService = false
                DefOutOfService = '0';   
            end
            set_param(obj.ObjectName,'DefOutOfService',DefOutOfService);
            % Collect-Data-Delay
            set_param(obj.ObjectName,'CollectDataDelay',obj.CollectDataDelay);

        end
    end
end