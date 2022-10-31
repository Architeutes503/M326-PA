classdef BA_AREA < BA_OBJ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   (C) Copyright by Siemens Schweiz AG, Building Technologies Group,
%       HVAC Products, 2012
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Project                     : IMSES
%   Target Hardware             : PC 
%   Target Operating System     : WinXP Console
%   Language/Compiler           : Matlab 2010 and higher 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Workfile                    : BA_AREA.m
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
    methods 
        function generate(obj)
            %% create Simulink model
            % delete the last position (example: 'R_2/BA' --> 'R_2')
            SystemName = obj.ObjectName(1:find(obj.ObjectName=='/',1,'last')-1);
            new_system(SystemName);
            % disable unnecessary Error Messages
            set_param (SystemName, 'UnconnectedInputMsg', 'none');
            set_param (SystemName, 'UnconnectedOutputMsg', 'none');
            set_param (SystemName, 'UnconnectedOutputMsg', 'none');
            set_param (SystemName, 'BooleanDataType', 'off');
            set_param (SystemName, 'InheritedTsInSrcMsg', 'none');
			set_param (SystemName, 'Solver', 'FixedStepDiscrete');
			set_param (SystemName, 'SampleTimeConstraint', 'STIndependent');
			set_param (SystemName, 'InlineParams', 'on');
            %% save Simulink model
            % delete one more position if the file comes from a UNZIP-Folder
            FilePath=obj.FilePath;
            if  ~isempty(strfind(FilePath,'\_TEMP_UNZIP_FOLDER'))
                FilePath = FilePath(1:find(FilePath=='\',1,'last')-1);
            end
            FilePath = [FilePath '\' SystemName '\'];
            if (exist(FilePath) == 0)
                mkdir (FilePath);
            end
            save_system(SystemName,[FilePath  SystemName]);
            %% open Simulink model
            open(SystemName);
            %% add SubSystem BA-Model
            add_block('built-in/SubSystem',obj.ObjectName,'Position',getPos(obj.ObjectName));
            %% configure SubSystem BA-Model
            set_param (obj.ObjectName,... 
                'MaskDisplay',sprintf('disp (''BA-Model'');'),...
                'Mask','on',...
                'BackgroundColor','red',...
                'MaskIconOpaque', 'on',...
                'MaskIconUnits','Autoscale',...
                'MaskIconRotate','off');
            %% generate ObjectList
            if not(isempty(obj.ObjectList))
                for k=1:length(obj.ObjectList)
                    if not(isempty(obj.ObjectList{k}))
                        obj.ObjectList{k}.generate;
                    end    
                end    
            end
            % return the Path of the created System
            obj.FilePath=FilePath;
        end
    end
end