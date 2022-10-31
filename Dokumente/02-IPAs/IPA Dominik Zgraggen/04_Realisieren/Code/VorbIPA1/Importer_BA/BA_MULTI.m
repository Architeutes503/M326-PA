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
    %   2014-05-08 08:30 Stefan Boetschi
    %   Exception handling for object name == chart name
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
            %% Try to add block (copy from the Firmware Library)
            try
                % 2014-08-05, Stefan Boetschi: Handle the exception when
                % the name of the current block has already been used in
                % the current subsystem
                slashInd = strfind(obj.ObjectName,'/');
                firstSlashInd = slashInd(1);
                lastSlashInd = slashInd(end);
                subSysList = find_system(obj.ObjectName(1:lastSlashInd-1));
                subSysList = subSysList(2:end);
                for i = 1:length(subSysList)
                    if strcmp(subSysList{i},obj.ObjectName)
                        obj.ObjectName = [obj.ObjectName '_1'];
                        break;
                    end % END IF
                end % END FOR
                add_block([obj.FWLib '/BA_OBJECT/' obj.ObjectType '_'],obj.ObjectName,'Position', getPos(obj.ObjectName));
            catch ME
                Send2GUI(['    ERROR : ' ME.message],obj.h);
            end
            %% configure block
            set_param(obj.ObjectName,'DeviceId',obj.DevIDRef,'ObjectId',obj.ObjIDRef);
            if not(isempty(obj.NumOfStates))
                set_param(obj.ObjectName,'NumOfStates',obj.NumOfStates);
            end
            if not(isempty(obj.DefValue))
                set_param(obj.ObjectName,'DefValue',obj.DefValue);
            end
            ObjName = obj.ObjectName(find(obj.ObjectName=='/',1,'last')+1 : length(obj.ObjectName));
            tabs = char (9 * ones (1, (length (strfind (obj.ObjectName, '/'))-1)));
            fwrite (ObjList, sprintf('%s%s\t%s\t%s\t%s\n', tabs, ObjName, obj.ObjIDRef, obj.DevIDRef, obj.ObjectType));
            
        end
    end
end