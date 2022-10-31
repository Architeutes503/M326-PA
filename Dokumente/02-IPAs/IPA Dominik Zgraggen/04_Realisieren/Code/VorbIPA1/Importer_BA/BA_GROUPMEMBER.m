classdef BA_GROUPMEMBER < BA_OBJ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   (C) Copyright by Siemens Schweiz AG, Building Technologies Group,
%       R&D Zug, Comfort Systems, System Applications, 2013
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Project                     : IMSES
%   Target Hardware             : PC 
%   Target Operating System     : WinXP Console
%   Language/Compiler           : Matlab 2010 and higher 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Workfile                    : BA_GROUPMEMBER.m
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
%   2014-07-28 13:00 Stefan Boetschi
%   Several bugfixes regarding the MP1.2 import
%
%   2014-07-11 08:00 Stefan Boetschi
%   Parse a property list from a SDU export in order to translate the
%   properties in string format (MP1.2 ABT export) to the corresponding
%   property Ids
%
%   2014-07-09 16:40 Stefan Boetschi
%   Compute the Object Ids of the group items based on the information
%   given in the ABT export version MP1.2
%
%   2014-07-07 09:10 Stefan Boetschi
%   Adapted warnings sent to the IMSES GUI
% 	
%   2013-10-11 08:45 Stefan Boetschi
%   Added method parseGroupMemberProp()
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
       GroupCategoryText
       GroupCategory
       GroupNumber
       OutOfService
       ObjectPropRefList
       % Stefan Boetschi, 2014-01-06: Property removed (based on cASA-[T010.S060-2]) 
       %ObjectPropIdList
       OperationList
       DataTagNumList
       DataTagList
       DefaultValueList
       DefaultPrioList
    end
    methods
        %% Stefan, 10.10.2013: Add method which parses BA_GROUPMEMBER specific properties from the *.ba-file
        function parseGroupMemberProp(obj)
            %% XPath settings
            import javax.xml.xpath.*
            factory = XPathFactory.newInstance;
            xpath = factory.newXPath;
            %% Parse properties
            if (strcmp(obj.Version , 'MP1.2') == 1) % MP1.2
                % Find the correct file and adjust obj.FilePath and
                % obj.FileName
                nameParts = textscan(obj.ObjectName,'%s','delimiter','/');
                tempName = nameParts{1}{end};
                fileNameParts = textscan(obj.FileName,'%s','delimiter','.');
                subfolder = fileNameParts{1}{1};
                path = [obj.FilePath '\' subfolder];
                fileCandidates = dir([path '\' tempName '*.xml']);
                if ~isempty(fileCandidates)
                    file = fileCandidates(1).name;
                    obj.FilePath = path;
                    obj.FileName = file;
                end
                % Read the XML file and get a node to the BA-Group-Member
                xDoc = xmlread([obj.FilePath '\' obj.FileName]);
                expr = xpath.compile('.//Entity');
                entity = expr.evaluate(xDoc,XPathConstants.NODE);
                % parse Ds1_Item_Values_Data_Tag_Number
                expr = xpath.compile('.//Property[@Name="Ds1_Item_Values_Data_Tag_Number"]/@Value');
                result = expr.evaluate(entity,XPathConstants.STRING);
                if ~isempty(result)
                    groupTags = regexprep(result, '[[?{?}?]]', '');
                    groupTags = textscan(groupTags, '%s', 'delimiter', '|');
                    groupTags = groupTags{1};
                    for i=1:length(groupTags)
                       obj.DataTagNumList{i} = groupTags{i}; 
                    end
                else
                    Send2GUI({
                            [ '    ERROR : Item ObjIDRef of property Object-Property-Reference-List of Group-Object of type ',...
                            obj.ObjectType ' is empty. This could be an error in the ABT export file.'     ];...
                            [ '            BaObjRef.DeviceId : ' obj.DevIDRef                                   ];...
                            [ '            BaObjRef.ObjectId : ' obj.ObjIDRef                                   ];...
                            [ '            Object Name       : ' obj.ObjectName];},obj.h);
                end
                % parse Ds1_Item_Values_Operation
                expr = xpath.compile('.//Property[@Name="Ds1_Item_Values_Operation"]/@Value');
                result = expr.evaluate(entity,XPathConstants.STRING);
                if ~isempty(result)
                    itemOperations = regexprep(result, '[[?{?}?]]', '');
                    itemOperations = textscan(itemOperations, '%s', 'delimiter', '|');
                    itemOperations = itemOperations{1};
                    for i=1:length(itemOperations)
                        curOpText = lower(itemOperations{i});
                        if strcmp(curOpText,'write')
                            curOp = '2'; % CS7_BaAccessParameter.h -> EBaPropCtrlFlags -> PropWrite = 2
                        elseif strcmp(curOpText,'read');
                            curOp = '1'; % CS7_BaAccessParameter.h -> EBaPropCtrlFlags -> PropRead = 1
                        elseif strcmp(curOpText,'update');
                            curOp = '4'; % CS7_BaAccessParameter.h -> EBaPropCtrlFlags -> PropUpdate = 4
                        else
                            Send2GUI({
                                [ '    ERROR : The entry ', curOpText ,' of Operation-List of Group-Object of type ',...
                                obj.ObjectType ' is unknown. This could be an error in the ABT export file.'     ];...
                                [ '            BaObjRef.DeviceId : ' obj.DevIDRef                                   ];...
                                [ '            BaObjRef.ObjectId : ' obj.ObjIDRef                                   ];...
                                [ '            Object Name       : ' obj.ObjectName];},obj.h);
                        end
                        obj.OperationList{i} = curOp;
                    end
                else
                    Send2GUI({
                        [ '    ERROR : An entry of Operation-List of Group-Object of type ',...
                        obj.ObjectType ' is empty. This could be an error in the ABT export file.'     ];...
                        [ '            BaObjRef.DeviceId : ' obj.DevIDRef                                   ];...
                        [ '            BaObjRef.ObjectId : ' obj.ObjIDRef                                   ];...
                        [ '            Object Name       : ' obj.ObjectName];},obj.h);
                end
                % Ds1_Item_Values_Object_Property_Ref
                expr = xpath.compile('.//Property[@Name="Ds1_Item_Values_Object_Property_Ref"]/@Value');
                result = expr.evaluate(entity,XPathConstants.STRING);
                if ~isempty(result)
                    tempString = regexprep(result, '[[?{?}?]]', '');
                    tempString = strrep(tempString,')|(','#');
                    tempCell = regexp(tempString,'#','split');
                    tempCell{1}(1) = '';
                    tempCell{end}(end) = '';
                    cellCount = length(tempCell);
                    objPropRef = tempCell;
                    for i=1:length(objPropRef)
                        curObjPropRef = strrep(objPropRef{i},'(','');
                        curObjPropRef = strrep(curObjPropRef,')','');
                        curObjPropRef = textscan(curObjPropRef, '%s', 'delimiter', '|');
                        curObjIdRef = curObjPropRef{1}{1};
                        curPrpId = curObjPropRef{1}{2};
                        curArrayIdx = curObjPropRef{1}{3};
                        curDevIdRef = '4194303';
                        % Check and set curObjIdRef
                        if ~strcmpi(curObjIdRef,'unassigned')
                            % 2014-07-09, Stefan Boetschi:
                            % Extract information that forms the ObjectId
                            commaInd = strfind(curObjIdRef,',');
                            ObjTypeString = curObjIdRef(1:commaInd-1);
                            ObjInstance = str2num(curObjIdRef(commaInd+1:end));
                            foundTypeId = false;
                            for c=1:size(obj.BAObjTypeIds)
                                if strcmpi(obj.BAObjTypeIds(c,1),ObjTypeString)
                                    foundTypeId = true;
                                    % Read object type number from the
                                    % table
                                    ObjTypId=obj.BAObjTypeIds{c,2};
                                    obj.ObjectPropRefList{i}.ObjIDRef = num2str(ObjTypId*(2^22)+ObjInstance);
                                end
                            end
                            if ~foundTypeId
                                Send2GUI({
                                    [ '    ERROR : Could not transform the string entry "', curObjIdRef,'" of object ID in Object Property Reference List of Group-Object of type ',...
                                    obj.ObjectType ' into a numeric object ID. Please assign the correct object ID manually in the Simulink mask of the BA object.'     ];...
                                    [ '            BaObjRef.DeviceId : ' obj.DevIDRef                                   ];...
                                    [ '            BaObjRef.ObjectId : ' obj.ObjIDRef                                   ];...
                                    [ '            Object Name       : ' obj.ObjectName];},obj.h);
                            end
                        else
                            % If item object id unassigned: use default
                            % object id
                            obj.ObjectPropRefList{i}.ObjIDRef = '4194303';
                        end
                        % Load property id list from a .mat file
                        propList = generateImporterPropertyList;
                        % Check and set curPrpId
                        foundPropId = false;  
                        if ~isempty(propList)
                            for c=1:length(propList.propIds)
                                if strcmpi(propList.propDescr(c),curPrpId)
                                    foundPropId = true;
                                    obj.ObjectPropRefList{i}.PrpId = num2str(propList.propIds(c));
                                end
                            end
                        else
                            Send2GUI({
                                [ '    Warning : Could not load or generate the property lookup table needed to transform the string format properties ',...
                                'from the ABT export MP1.2 into the corresponding numeric property ID.']},obj.h);
                        end
                        if ~foundPropId
                            obj.ObjectPropRefList{i}.PrpId = curPrpId;
                            Send2GUI({
                                [ '    ERROR : The string entry "', curPrpId,'" of property ID in Object Property Reference List of Group-Object of type ',...
                                obj.ObjectType ' is unknown. Please assign the correct property ID manually in the Simulink mask of the BA object.'     ];...
                                [ '            BaObjRef.DeviceId : ' obj.DevIDRef                                   ];...
                                [ '            BaObjRef.ObjectId : ' obj.ObjIDRef                                   ];...
                                [ '            Object Name       : ' obj.ObjectName];},obj.h);
                        end                        
                        % Check and set curArrayIdx
                        if ~strcmpi(curArrayIdx,'unassigned')
                           % If array index unassigned: set array index to 0
                           % (information is not used by IMSES anyway)
                           obj.ObjectPropRefList{i}.ArrayIdx = curArrayIdx; 
                        else
                            obj.ObjectPropRefList{i}.ArrayIdx = '0';
                        end
                        % Set curDevIdRef
                        obj.ObjectPropRefList{i}.DevIDRef = curDevIdRef;                        
                    end
                else
                    Send2GUI({
                        [ '    ERROR : An entry of Operation-List of Group-Object of type "',...
                        obj.ObjectType '" is empty. This could be an error in the ABT export file.'     ];...
                        [ '            BaObjRef.DeviceId : ' obj.DevIDRef                                   ];...
                        [ '            BaObjRef.ObjectId : ' obj.ObjIDRef                                   ];...
                        [ '            Object Name       : ' obj.ObjectName];},obj.h);
                end
                % Ds1_Item_Values
                expr = xpath.compile('.//Property[@Name="Ds1_Item_Values"]/@Value');
                result = expr.evaluate(entity,XPathConstants.STRING);
                if ~isempty(result)
                    tempString = regexprep(result, '[[?{?}?]]', '');
                    tempCell = regexp(tempString,')|(','split');
                    cellCount = 0;
                    for i=1:length(tempCell)
                        if (~strcmp(tempCell{i},'') && ~strcmp(tempCell{i},'|'))
                            cellCount = cellCount + 1;
                            defVals{cellCount} = tempCell{i};
                        end
                    end
                    %defVals = strsplit(defVals,')|(');
                    for i=1:length(defVals)
                        curDefVal = strrep(defVals{i},'(','');
                        curDefVal = strrep(curDefVal,')','');
                        curDefVal = textscan(curDefVal, '%s', 'delimiter', ':');
                        curDefVal = curDefVal{1}{2};
                        if strcmpi(curDefVal,'null')
                            curDefVal = '0';
                        end
                        obj.DefaultValueList{i}.value = curDefVal;
                    end
                else
                    Send2GUI({
                        [ '    ERROR : An entry of Item Default Values of Group-Object of type "',...
                        obj.ObjectType '" is empty. This could be an error in the ABT export file.'     ];...
                        [ '            BaObjRef.DeviceId : ' obj.DevIDRef                                   ];...
                        [ '            BaObjRef.ObjectId : ' obj.ObjIDRef                                   ];...
                        [ '            Object Name       : ' obj.ObjectName];},obj.h);
                end
                % Ds1_Item_Values_Priority
                expr = xpath.compile('.//Property[@Name="Ds1_Item_Values_Priority"]/@Value');
                result = expr.evaluate(entity,XPathConstants.STRING);
                if ~isempty(result)
                    defPrios = regexprep(result, '[[?{?}?]]', '');
                    defPrios = textscan(defPrios,'%s','delimiter','|');
                    for i=1:length(defPrios{1})
                        curDefPrio = textscan(defPrios{1}{i}, '%s', 'delimiter', ':');
                        curDefPrio = curDefPrio{1}{1};
                        obj.DefaultPrioList{i} = curDefPrio;
                    end
                else
                    Send2GUI({
                        [ '    ERROR : An entry of Item Default Priority of Group-Object of type "',...
                        obj.ObjectType '" is empty. This could be an error in the ABT export file.'     ];...
                        [ '            BaObjRef.DeviceId : ' obj.DevIDRef                                   ];...
                        [ '            BaObjRef.ObjectId : ' obj.ObjIDRef                                   ];...
                        [ '            Object Name       : ' obj.ObjectName];},obj.h);
                end
            else % MP1.16
                %% parse Ds1_Item_Values_Object_Property_Ref
                % generate nodelist Ds1_Item_Values_Object_Property_Ref
                expr=xpath.compile('.//EOParameter[@Name="Ds1_Item_Values_Object_Property_Ref"]//Element');
                list=expr.evaluate(obj.ObjectNode, XPathConstants.NODESET);
                % save the information contained in the list to a cell array of
                % structures
                for i=1:list.getLength
                    % ObjIDRef, mandatory
                    expr=xpath.compile('.//Field[@Name="ObjIDRef"]//Value/@Value');
                    result=expr.evaluate(list.item(i-1), XPathConstants.STRING);
                    if ~isempty(result)
                        obj.ObjectPropRefList{i}.ObjIDRef=result;
                    else
                        Send2GUI({
                            [ '    ERROR : Item ObjIDRef of property Object-Property-Reference-List of Group-Object of type ',...
                            obj.ObjectType ' is empty. This could be an error in the ABT export file.'     ];...
                            [ '            BaObjRef.DeviceId : ' obj.DevIDRef                                   ];...
                            [ '            BaObjRef.ObjectId : ' obj.ObjIDRef                                   ];...
                            [ '            Object Name       : ' obj.ObjectName];},obj.h);
                    end
                    % PrpId, mandatory
                    expr=xpath.compile('.//Field[@Name="PrpId"]//Value/@Value');
                    result = expr.evaluate(list.item(i-1), XPathConstants.STRING);
                    if ~isempty(result)
                        obj.ObjectPropRefList{i}.PrpId=result;
                    else
                        Send2GUI({
                            [ '    ERROR : Item PrpId of property Object-Property-Reference-List of Group-Object of type ',...
                            obj.ObjectType ' is empty. This could be an error in the ABT export file.'     ];...
                            [ '            BaObjRef.DeviceId : ' obj.DevIDRef                                   ];...
                            [ '            BaObjRef.ObjectId : ' obj.ObjIDRef                                   ];...
                            [ '            Object Name       : ' obj.ObjectName];},obj.h);
                    end
                    % ArrayIdx, optional
                    expr=xpath.compile('.//Field[@Name="ArrayIdx"]//Value/@Value');
                    result = expr.evaluate(list.item(i-1), XPathConstants.STRING);
                    if ~isempty(result)
                        obj.ObjectPropRefList{i}.ArrayIdx=result;
                    end
                    % DevIDRef, optional
                    expr=xpath.compile('.//Field[@Name="DevIDRef"]//Value/@Value');
                    result = expr.evaluate(list.item(i-1), XPathConstants.STRING);
                    if ~isempty(result)
                        obj.ObjectPropRefList{i}.DevIDRef=result;
                    end
                end
                %% Stefan Boetschi, 2014-01-06: Property removed (based on cASA-[T010.S060-2])
                %            %% parse Ds1_Item_Values_Object_Property_Id
                %            % generate nodelist Ds1_Item_Values_Object_Property_Id
                %            expr=xpath.compile('.//EOParameter[@Name="Ds1_Item_Values_Property_Id"]//Element');
                %            list=expr.evaluate(obj.ObjectNode, XPathConstants.NODESET);
                %            % save the information contained in the list to a cell array of
                %            % char arrays
                %            for i=1:list.getLength
                %                % PropId
                %                expr=xpath.compile('.//Value/@Value');
                %                result=expr.evaluate(list.item(i-1), XPathConstants.STRING);
                %                if ~isempty(result)
                %                    obj.ObjectPropIdList{i}=result;
                %                end
                %            end
                %% parse Ds1_Item_Values_Operation
                % generate nodelist Ds1_Item_Values_Operation
                expr=xpath.compile('.//EOParameter[@Name="Ds1_Item_Values_Operation"]//Element');
                list=expr.evaluate(obj.ObjectNode, XPathConstants.NODESET);
                % save the information contained in the list to a cell array of
                % char arrays
                for i=1:list.getLength
                    % Operation
                    expr=xpath.compile('.//Value/@Value');
                    result=expr.evaluate(list.item(i-1), XPathConstants.STRING);
                    if ~isempty(result)
                        obj.OperationList{i}=result;
                    else
                        Send2GUI({
                            [ '    ERROR : An entry of Operation-List of Group-Object of type ',...
                            obj.ObjectType ' is empty. This could be an error in the ABT export file.'     ];...
                            [ '            BaObjRef.DeviceId : ' obj.DevIDRef                                   ];...
                            [ '            BaObjRef.ObjectId : ' obj.ObjIDRef                                   ];...
                            [ '            Object Name       : ' obj.ObjectName];},obj.h);
                    end
                end
                %% parse Ds1_Item_Values_Data_Tag_Number
                % generate nodelist Ds1_Item_Values_Data_Tag_Number
                expr=xpath.compile('.//EOParameter[@Name="Ds1_Item_Values_Data_Tag_Number"]//Element');
                list=expr.evaluate(obj.ObjectNode, XPathConstants.NODESET);
                % save the information contained in the list to a cell array of
                % char arrays
                for i=1:list.getLength
                    % Data Tag Number
                    expr=xpath.compile('.//Value/@Value');
                    result=expr.evaluate(list.item(i-1), XPathConstants.STRING);
                    if ~isempty(result)
                        obj.DataTagNumList{i}=result;
                    else
                        Send2GUI({
                            [ '    ERROR : An entry of Group-Data-Tag-List (Number) of Group-Object of type ',...
                            obj.ObjectType ' is empty. This could be an error in the ABT export file.'     ];...
                            [ '            BaObjRef.DeviceId : ' obj.DevIDRef                                   ];...
                            [ '            BaObjRef.ObjectId : ' obj.ObjIDRef                                   ];...
                            [ '            Object Name       : ' obj.ObjectName];},obj.h);
                    end
                end
                %% parse Ds1_Item_Values_Data_Tag
                % generate nodelist Ds1_Item_Values_Data_Tag
                expr=xpath.compile('.//EOParameter[@Name="Ds1_Item_Values_Data_Tag"]//Element');
                list=expr.evaluate(obj.ObjectNode, XPathConstants.NODESET);
                % save the information contained in the list to a cell array of
                % char arrays
                for i=1:list.getLength
                    % Data Tag
                    expr=xpath.compile('.//Value/@Value');
                    result=expr.evaluate(list.item(i-1), XPathConstants.STRING);
                    if ~isempty(result)
                        obj.DataTagList{i}=result;
                    end
                end
                %% parse Ds1_Item_Values
                % generate nodelist Ds1_Item_Values
                expr=xpath.compile('.//EOParameter[@Name="Ds1_Item_Values"]//Element');
                list=expr.evaluate(obj.ObjectNode, XPathConstants.NODESET);
                % save the information contained in the list to a cell array
                % of structures
                for i=1:list.getLength
                    % entryType (Name)
                    expr=xpath.compile('.//Entry/@Name');
                    entryType=expr.evaluate(list.item(i-1), XPathConstants.STRING);
                    if ~isempty(entryType)
                        % Get entry type/name
                        obj.DefaultValueList{i}.entryType=entryType;
                        expr=xpath.compile('.//Entry/@Order');
                        % Get entry order
                        order = expr.evaluate(list.item(i-1), XPathConstants.STRING);
                        obj.DefaultValueList{i}.order=order;
                        % Get default value if entry type is not "Null_Value"
                        if ~strcmp(entryType,'Null_Value')
                            expr=xpath.compile('.//Value/@Value');
                            value = expr.evaluate(list.item(i-1), XPathConstants.STRING);
                            obj.DefaultValueList{i}.value=value;
                        else
                            % Set default value to '0' (empty cell) if entry type is "Null_Value"
                            obj.DefaultValueList{i}.value='0';
                        end
                    else
                        Send2GUI({
                            [ '    ERROR : Item Entry of property Default-Value-List of Group-Object of type ',...
                            obj.ObjectType ' does not have a specified name. This could be an error in the ABT export file.'     ];...
                            [ '            BaObjRef.DeviceId : ' obj.DevIDRef                                   ];...
                            [ '            BaObjRef.ObjectId : ' obj.ObjIDRef                                   ];...
                            [ '            Object Name       : ' obj.ObjectName];},obj.h);
                    end
                end
                %% parse Ds1_Item_Values_Priority
                % generate nodelist Ds1_Item_Values_Priority
                expr=xpath.compile('.//EOParameter[@Name="Ds1_Item_Values_Priority"]//Element');
                list=expr.evaluate(obj.ObjectNode, XPathConstants.NODESET);
                % save the information contained in the list to a cell array of
                % char arrays
                for i=1:list.getLength
                    % Priority
                    expr=xpath.compile('.//Value/@Value');
                    result=expr.evaluate(list.item(i-1), XPathConstants.STRING);
                    if ~isempty(result)
                        obj.DefaultPrioList{i}=result;
                    end
                end
            end
        end
        
        %%
        function generate(obj, ObjList)
             
             %% Write block information to file ObjectList.txt
             tabs = char (9 * ones (1, (length (strfind (obj.ObjectName, '/')) - 1)));
             name = obj.ObjectName(find(obj.ObjectName=='/',1,'last')+1 : length(obj.ObjectName));
             
             % Check if Group number and group category are defined for the
             % current Group-Member-Object
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
             
             % Write Object-Property-Reference-List to ObjectList.txt
             fwrite(ObjList, sprintf('\t%sObject Property Reference List\n', tabs));
             for i=1:length(obj.ObjectPropRefList)
                 if ~isempty(obj.ObjectPropRefList{i}.ObjIDRef)
                     ObjIDRef = obj.ObjectPropRefList{i}.ObjIDRef;
                 else
                     ObjIDRef = '<no ObjIDRef>';
                 end
                 if ~isempty(obj.ObjectPropRefList{i}.PrpId)
                     PrpId = obj.ObjectPropRefList{i}.PrpId;
                 else
                     PrpId = '<no PrpId>';
                 end
                 if ~isempty(obj.ObjectPropRefList{i}.ArrayIdx)
                     ArrayIdx = obj.ObjectPropRefList{i}.ArrayIdx;
                 else
                     ArrayIdx = '<no ArrayIdx>';
                 end
                 if ~isempty(obj.ObjectPropRefList{i}.DevIDRef)
                     DevIDRef = obj.ObjectPropRefList{i}.DevIDRef;
                 else
                     DevIDRef = '<no DevIDRef>';
                 end
                 fwrite(ObjList, sprintf('\t%s\t%s\t%s\t%s\t%s\n', tabs, ObjIDRef, DevIDRef, PrpId, ArrayIdx));
             end
             
             %% Try to add block (copy from the Firmware Library)
             try
                 % 2014-07-28, Stefan Boetschi: Handle the exception when
                 % the name of the current block has already been used in
                 % the current subsystem (e.g. 'CenFcd' GrpMbr in the
                 % 'CenFcd' VN_F)
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
                 add_block([obj.FWLib '/BA_OBJECT/BA_G_MBR_'],obj.ObjectName,'Position',getPos(obj.ObjectName));
             catch ME
                 Send2GUI(['    ERROR : ' ME.message],obj.h);
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
             
             % Object-Property-Reference-List
             ItemObjId = '';
             ItemDevId = ''; % Property is optional!
             flagDevId = false; % Set to true if property is defined
             ItemPrpId = '';
             ItemArrayIdx = ''; % Property is optional!
             flagArrayIdx = false; % Set to true if property is defined
             ItemDataTag = '';
             ItemOps = '';
             ItemDefVal = '';
             ItemDefPrio = '';
             for i=1:length(obj.ObjectPropRefList)
                 ItemObjId = [ItemObjId, ' ', obj.ObjectPropRefList{i}.ObjIDRef];
                 ItemPrpId = [ItemPrpId, ' ', obj.ObjectPropRefList{i}.PrpId];
                 if isfield(obj.ObjectPropRefList{i},'DevIDRef')
                     flagDevId = true;
                     ItemDevId = [ItemDevId, ' ', obj.ObjectPropRefList{i}.DevIDRef];
                 else
                     flagDevId = false;
                     ItemDevId = [];
                 end
                 if isfield(obj.ObjectPropRefList{i},'ArrayIdx')
                     flagArrayIdx = true;
                     ItemArrayIdx = [ItemArrayIdx, ' ', obj.ObjectPropRefList{i}.ArrayIdx];
                 else
                     flagArrayIdx = false;
                     ItemArrayIdx = [];
                 end
             end
             set_param(obj.ObjectName,'ItemObjId',['[',ItemObjId(2:end),']']);
             set_param(obj.ObjectName,'ItemPrpId',['[',ItemPrpId(2:end),']']);
             set_param(obj.ObjectName,'ItemDevId',['[',ItemDevId(2:end),']']);
             set_param(obj.ObjectName,'ItemArrayIdx',['[',ItemArrayIdx(2:end),']']);
             
             % Operation-List
             ItemOps = '';
             for i=1:length(obj.OperationList)
                ItemOps = [ItemOps, ' ', obj.OperationList{i}]; 
             end
             set_param(obj.ObjectName,'ItemOps',['[',ItemOps(2:end),']']);
             
             % Group-Data-Tag-List
             ItemDataTag = '';
             for i=1:length(obj.DataTagNumList)
                ItemDataTag = [ItemDataTag, ' ', obj.DataTagNumList{i}]; 
             end
             set_param(obj.ObjectName,'ItemDataTag',['[',ItemDataTag(2:end),']']);
             
             % Default-Priority-List
             ItemDefPrio = '';
             for i=1:length(obj.DefaultPrioList)
                ItemDefPrio = [ItemDefPrio, ' ', obj.DefaultPrioList{i}]; 
             end
             set_param(obj.ObjectName,'ItemDefPrio',['[',ItemDefPrio(2:end),']']);
             
             % Default-Value-List
             ItemDefVal = '';
             for i=1:length(obj.DefaultValueList)
                ItemDefVal = [ItemDefVal, ' ', obj.DefaultValueList{i}.value]; 
             end
             set_param(obj.ObjectName,'ItemDefVal',['[',ItemDefVal(2:end),']']);  


        end
    end
end