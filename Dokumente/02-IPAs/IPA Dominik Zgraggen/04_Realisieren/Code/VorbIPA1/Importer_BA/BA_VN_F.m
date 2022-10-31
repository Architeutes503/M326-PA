classdef BA_VN_F < BA_OBJ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   (C) Copyright by Siemens Schweiz AG, Building Technologies Group,
%       HVAC Products, 2012
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Project                     : IMSES
%   Target Hardware             : PC 
%   Target Operating System     : WinXP Console
%   Language/Compiler           : Matlab 2010 and higher 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Workfile                    : BA_VN_F.m
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
%   2014-07-28 11:55 Stefan Boetschi
%   Adapted error message sent to the GUI.
% 	
% 	2012-03-20 14:00 Thomas Rohr
%	Header comment was attached
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
    methods
        function generate(obj, ObjList)       
            
            %% 21.08.2013, Tom 4114, Chart Subsystem muss hier nicht generiert werden. Dieses wird vom ChartImporter gemacht.
%             %% add Chart subsystem           
%             % delete the middle position (example: 'R_2/BA/Rad01' --> 'R_2/Rad01')
%             ObjName = strrep(obj.ObjectName,'/BA','');
%             add_block('built-in/SubSystem',ObjName,'Position',getPos(ObjName));
%             %% configure Chart subsystem
%             set_param (ObjName,...
%                 'MaskDisplay', sprintf('disp (''Chart'');'),...
%                 'Mask','on',...
%                 'BackgroundColor','lightblue',...
%                 'MaskIconOpaque', 'on',...
%                 'MaskIconUnits','Autoscale',...
%                 'MaskIconRotate','off');
            
            
            %% add BA_VN_F subsystem
            add_block('built-in/SubSystem',obj.ObjectName,'Position',getPos(obj.ObjectName));
            %% configure BA_VN_F subsystem
            set_param (obj.ObjectName,...
                'MaskDisplay', sprintf('disp (''ViewNode Function'');'),...
                'Mask','on',...
                'BackgroundColor','red',...
                'MaskIconOpaque', 'on',...
                'MaskIconUnits','Autoscale',...
                'MaskIconRotate','off');
            %% add BA_VN_F
            % double the last position (example: 'R_2/BA/Rad01' --> 'R_2/BA/Rad01/Rad01')
            ObjName = obj.ObjectName(find(obj.ObjectName=='/',1,'last') : length(obj.ObjectName));
            ObjName = [obj.ObjectName ObjName];
            add_block([obj.FWLib '/BA_OBJECT/BA_VN_F_'],ObjName,'Position',getPos(ObjName));
            
            %% configure BA_VN_F
            tabs = char (9 * ones (1, (length (strfind (obj.ObjectName, '/')) - 1)));
            name = obj.ObjectName(find(obj.ObjectName=='/',1,'last')+1 : length(obj.ObjectName));
            fwrite (ObjList, sprintf('%s%s\t%s\t%s\t%s\n', tabs, name, obj.ObjIDRef, obj.DevIDRef, obj.ObjectType  ));
            if not(isempty(obj.SubList))
                fwrite (ObjList, sprintf('%sSubordinated List\n', tabs));
                ItemDeviceId=obj.SubList{1,1};
                ItemObjectId=obj.SubList{2,1};
                fwrite (ObjList, sprintf('\t%s1 %s\t%s\t%s\t%s\n', tabs, obj.SubList{3,1}, obj.SubList{2,1}, obj.SubList{1,1}, obj.SubList{4,1}));
                if size(obj.SubList,2)>= 2
                    for k=2:size(obj.SubList,2)
                        ItemDeviceId=[ItemDeviceId ' ' obj.SubList{1,k}];
                        ItemObjectId=[ItemObjectId ' ' obj.SubList{2,k}];
                        fwrite (ObjList, sprintf('\t%s%d %s\t%s\t%s\t%s\n', tabs, k, obj.SubList{3,k}, obj.SubList{2,k}, obj.SubList{1,k}, obj.SubList{4,k}));                        
                    end
                end
                set_param(ObjName,'ItemDeviceId',['[' ItemDeviceId ']'],'ItemObjectId',['[' ItemObjectId ']']);
            end
            set_param(ObjName,'DeviceId',['[' obj.DevIDRef ']'],'ObjectId',['[' obj.ObjIDRef ']']);
            
            %% generate ObjectList
            if not(isempty(obj.ObjectList))
                fwrite (ObjList, sprintf('%sObject List\n', tabs));
                for k=1:length(obj.ObjectList)
                    if not(isempty(obj.ObjectList{k}))
                        try
                            obj.ObjectList{k}.generate(ObjList);
                        catch
                            Send2GUI({...
                            [ '    ERROR : The generate method of the following object produces an error:'];...
                            [ '            BaObjRef.DeviceId : ' obj.ObjectList{k}.DevIDRef         ];...
                            [ '            BaObjRef.ObjectId : ' obj.ObjectList{k}.ObjIDRef         ];...
                            [ '            Object Type       : ' obj.ObjectList{k}.ObjectType       ];...
                            [ '            Object Name       : ' obj.ObjectList{k}.ObjectName       ];} ,obj.h);
                        end
                    end    
                end
                fwrite (ObjList, sprintf('\n'));    
            end
        end
    end
end