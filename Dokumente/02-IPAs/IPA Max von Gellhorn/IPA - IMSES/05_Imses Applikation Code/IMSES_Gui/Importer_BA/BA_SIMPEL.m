classdef BA_SIMPEL < BA_OBJ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   (C) Copyright by Siemens Schweiz AG, Building Technologies Group,
%       HVAC Products, 2012
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Project                     : IMSES
%   Target Hardware             : PC 
%   Target Operating System     : WinXP Console
%   Language/Compiler           : Matlab 2010 and higher 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Workfile                    : BA_SIMPLE.m
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
		UpperLimit
		LowerLimit
		DefValue
		Value
    end 
    methods 
        function generate(obj)
            try
                %% add block
                add_block([obj.FWLib '/BA_OBJECT/' obj.ObjectType '_'],obj.ObjectName,'Position',getPos(obj.ObjectName));
            catch
                Send2GUI(['    ERROR : The Block' obj.ObjectType 'is not existing in the Simulink Firmware Library'],obj.h);
            end
           
            %% configure block
            
            set_param(obj.ObjectName,'DeviceId',obj.DevIDRef,'ObjectId',obj.ObjIDRef);
            fields = get_param(obj.ObjectName, 'DialogParameters');
            if isfield (fields, 'DefValue')
                if ~(isempty(obj.DefValue)) 
                    set_param(obj.ObjectName,'DefValue',obj.DefValue);
                else
                    set_param(obj.ObjectName,'DefValue','0');
                end
            end
               
            if isfield(fields, 'Value')
                if ~(isempty(obj.Value))
                    set_param(obj.ObjectName,'Value',obj.Value);
                else
                    set_param(obj.ObjectName,'Value','0');
                end
            end

            if isfield(fields, 'UpperLimit')
                if ~(isempty(obj.UpperLimit))
                    set_param(obj.ObjectName,'UpperLimit',obj.UpperLimit);
                else
                    set_param(obj.ObjectName,'UpperLimit','3.402822E+38');
                end
            end

            if isfield(fields, 'LowerLimit')
                if ~(isempty(obj.LowerLimit))
                    set_param(obj.ObjectName,'LowerLimit',obj.LowerLimit);
                else
                    set_param(obj.ObjectName,'LowerLimit','-3.402822E+38');
                end						
            end
            
            if isfield(fields, 'MaxPrVal')
                if ~(isempty(obj.UpperLimit))
                    set_param(obj.ObjectName,'MaxPrVal',obj.UpperLimit);
                else
                    set_param(obj.ObjectName,'MaxPrVal','3.402822E+38');
                end
            end

            if isfield(fields, 'MinPrVal')
                if ~(isempty(obj.LowerLimit))
                    set_param(obj.ObjectName,'MinPrVal',obj.LowerLimit);
                else
                    set_param(obj.ObjectName,'MinPrVal','-3.402822E+38');
                end						
            end            
            
        end   
    end
end