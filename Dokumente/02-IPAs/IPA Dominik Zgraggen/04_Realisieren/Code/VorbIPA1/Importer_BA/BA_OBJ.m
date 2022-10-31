classdef BA_OBJ < hgsetget
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   (C) Copyright by Siemens Schweiz AG, Building Technologies Group,
    %       HVAC Products, 2012
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   Project                     : IMSES
    %   Target Hardware             : PC
    %   Target Operating System     : WinXP Console
    %   Language/Compiler           : Matlab 2010 and higher
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   Workfile                    : BA_OBJ.m
    %   Author                      : Thomas Rohr
    %   Version                     : v1.0
    %   Date                        : 20-Feb-2012
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Matlab Informations
    %   zugriff auf properties von außerhalb nur mit
    %   superclass: < hgsetget   ???
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
    %   2014-07-28 11:50 Stefan Boetschi
    %   Do only rely on the part names if the object id can not be computed
    %   from the string information provided in the subordinate lists.
    %
    %   2014-07-21 16:45 Stefan Boetschi
    %   Compute the ObjectIds based on the string information provided in the
    %   ABT export MP1.2
    %
    %   2014-07-07 09:10 Stefan Boetschi
    %   Adapted warnings sent to the IMSES GUI
    %
    %   2014-06-11 07:50 Stefan Boetschi
    %   Update for ABT export version MP1.2
    %
    % 	2012-03-20 14:00 Thomas Rohr
    %	Header comment was attached
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (GetAccess = public)
        SubList %DevIDRef, ObjIDRef
        ObjectList
        ObjectListPos
        DevIDRef
        ObjIDRef
        ObjectName
        ObjectType
        ObjectTypeNr
        ObjectNode
        DocNode
        h
        FWLib
        FilePath
        FileName
        Version
        BAObjTypeIds
        ChartFilePath
    end
    methods
        function parse(obj)
            import javax.xml.xpath.*
            factory = XPathFactory.newInstance;
            xpath = factory.newXPath;
            % 2014-07-08, Stefan Boetschi: BA Obj Type Ids
            [obj.BAObjTypeIds,~,~] = generateImporterObjectTypeMappings;
            % Initial Parsing when running first time
            %% 2014-05-27, Stefan Boetschi: MP1.2 -> Parse ObjectTypeNr if still empty
            if (strcmp(obj.Version , 'MP1.2') == 1)
                if (isempty(obj.ObjectTypeNr))
                    expr=xpath.compile('.//Property[@Name="Object_Type"]/@Value');
                    obj.ObjectTypeNr =expr.evaluate(obj.DocNode, XPathConstants.STRING);
                end
            end
            %% parsing ObjectNode wenn noch nicht vorhanden
            if isempty(obj.ObjectNode)
                if (strcmp(obj.Version , 'MP1.2') == 1)
                    obj.ObjectNode = []; % <-- i.e. only use obj.DocNode!
                else
                    expr   = xpath.compile('.//EOTypeRef[@Prototype="44"]');
                    result = expr.evaluate(obj.DocNode, XPathConstants.NODE);
                    obj.ObjectNode=result.getParentNode.getParentNode;
                end
            end
            %% parsing ObjectName wenn noch nicht vorhanden
            if (strcmp(obj.Version , 'MP1.2') == 1)
                expr=xpath.compile('.//Property[@Name="Object_Name"]/@Value');
                name=expr.evaluate(obj.DocNode, XPathConstants.STRING);
            else
                expr=xpath.compile('.//ShortDescription/@Value');
                name = expr.evaluate(obj.ObjectNode, XPathConstants.STRING);
            end
            
            if isempty(obj.ObjectName)
                obj.ObjectName=[name '/BA'];
            else
                if (strcmp(obj.Version , 'MP1.2') == 1)
                else
                    old  = obj.ObjectName(find(obj.ObjectName=='/',1,'last') + 1 : length(obj.ObjectName));
                    obj.ObjectName = strrep (obj.ObjectName, old, name);
                    dname = strfind(obj.ObjectName, name);
                    if length(dname) > 1
                        obj.ObjectName = [obj.ObjectName '_'];
                    end
                end
            end
            %% parsing ObjIDRef wenn noch nicht vorhanden
            if isempty(obj.ObjIDRef)
                if (strcmp(obj.Version , 'MP1.2') == 1)
                    expr=xpath.compile('.//Property[@Name="Object_Identifier"]/@Value');
                    obj.ObjIDRef=expr.evaluate(obj.DocNode, XPathConstants.STRING);
                else
                    expr=xpath.compile('.//EOParameter[@Name="Object_Identifier"]//Value/@Value');
                    obj.ObjIDRef=expr.evaluate(obj.ObjectNode, XPathConstants.STRING);
                end
            end
            
            %% parsing Number of States wenn property NumOfStates vorhanden
            if isprop(obj,'NumOfStates')
                %% Alter Code, auskommentiert von Wolfgang ,28.03.13
                %expr=xpath.compile('.//EOParameter[@Name="Number_Of_States"]//Value/@Value');
                %obj.NumOfStates=expr.evaluate(obj.ObjectNode, XPathConstants.STRING);
                %% Wolfgang, 28.03.13
                %%Number of States über State_Text ermitteln
                %%(Workaround, da export aus ABT diese Info für MCalcVal's nicht lieferte)
                if (strcmp(obj.Version , 'MP1.2') == 1)
                    % 2014-06-11, Stefan Boetschi: MP1.2 export
                    expr=xpath.compile('.//Property[@Name="Number_Of_States"]/@Value');
                    obj.NumOfStates = expr.evaluate(obj.DocNode, XPathConstants.STRING);
                else
                    expr=xpath.compile('.//EOParameter[@Name="State_Text"]//Value/@Value');
                    array=expr.evaluate(obj.ObjectNode, XPathConstants.NODESET);
                    obj.NumOfStates=num2str(array.getLength);
                end
                
            end
            %% parsing DefValue wenn property DefVal vorhanden
            if isprop(obj,'DefValue')
                if (strcmp(obj.Version , 'MP1.2') == 1)
                    % 2014-06-11, Stefan Boetschi: MP1.2 export
                    expr=xpath.compile('.//Property[@Name="Relinquish_Default"]/@Value');
                    obj.DefValue = expr.evaluate(obj.DocNode, XPathConstants.STRING);
                else
                    expr=xpath.compile('.//EOParameter[@Name="Relinquish_Default"]');
                    result=expr.evaluate(obj.ObjectNode, XPathConstants.NODE);
                    if ~isempty(result)
                        expr=xpath.compile('.//Value/@Value');
                        obj.DefValue=expr.evaluate(result, XPathConstants.STRING);
                    end
                end
            end
            %% TOM 09.10.2012
            %% parsing Present_Value wenn property Value vorhanden
            if isprop(obj,'Value')
                if (strcmp(obj.Version , 'MP1.2') == 1)
                    % 2014-06-11, Stefan Boetschi: MP1.2 export
                    expr=xpath.compile('.//Property[@Name="Present_Value"]/@Value');
                    obj.Value = expr.evaluate(obj.DocNode, XPathConstants.STRING);
                else
                    expr=xpath.compile('.//EOParameter[@Name="Present_Value"]');
                    result=expr.evaluate(obj.ObjectNode, XPathConstants.NODE);
                    if ~isempty(result)
                        expr=xpath.compile('.//Value/@Value');
                        obj.Value=expr.evaluate(result, XPathConstants.STRING);
                    end
                end
            end
            %% TOM 09.10.2012
            %% parsing Max_Pres_Value wenn property UpperLimit vorhanden
            if isprop(obj,'UpperLimit')
                if (strcmp(obj.Version , 'MP1.2') == 1)
                    % 2014-06-11, Stefan Boetschi: MP1.2 export
                    expr=xpath.compile('.//Property[@Name="Max_Pres_Value"]/@Value');
                    obj.UpperLimit = expr.evaluate(obj.DocNode, XPathConstants.STRING);
                else
                    expr=xpath.compile('.//EOParameter[@Name="Max_Pres_Value"]');
                    result=expr.evaluate(obj.ObjectNode, XPathConstants.NODE);
                    if ~isempty(result)
                        expr=xpath.compile('.//Value/@Value');
                        obj.UpperLimit=expr.evaluate(result, XPathConstants.STRING);
                    end
                end
            end
            %% TOM 09.10.2012
            %% parsing Min_Pres_Value wenn property LowerLimit vorhanden
            if isprop(obj,'LowerLimit')
                if (strcmp(obj.Version , 'MP1.2') == 1)
                    % 2014-06-11, Stefan Boetschi: MP1.2 export
                    expr=xpath.compile('.//Property[@Name="Min_Pres_Value"]/@Value');
                    obj.LowerLimit = expr.evaluate(obj.DocNode, XPathConstants.STRING);
                else
                    expr=xpath.compile('.//EOParameter[@Name="Min_Pres_Value"]');
                    result=expr.evaluate(obj.ObjectNode, XPathConstants.NODE);
                    if ~isempty(result)
                        expr=xpath.compile('.//Value/@Value');
                        obj.LowerLimit=expr.evaluate(result, XPathConstants.STRING);
                    end
                end
            end
            %% Wolfgang 22.01.2014
            %% parsing PresentValue2
            if isprop(obj,'PresentValue2')
                if (strcmp(obj.Version , 'MP1.2') == 1)
                    % 2014-06-11, Stefan Boetschi: MP1.2 export
                    expr=xpath.compile('.//Property[@Name="Ds1_Present_Value_2"]/@Value');
                    obj.PresentValue2 = expr.evaluate(obj.DocNode, XPathConstants.STRING);
                else
                    expr=xpath.compile('.//EOParameter[@Name="Ds1_Present_Value_2"]');
                    result=expr.evaluate(obj.ObjectNode, XPathConstants.NODE);
                    if ~isempty(result)
                        expr=xpath.compile('.//Value/@Value');
                        obj.PresentValue2=expr.evaluate(result, XPathConstants.STRING);
                    end
                end
            end            
            
            
            %% Stefan 10.10.2013, parse common properties of BA_GROUPMASTER and BA_GROUPMEMBER
            % parse GroupCategoryText if property exists
            if isprop(obj,'GroupCategoryText')
                if (strcmp(obj.Version , 'MP1.2') == 1)
                    % 2014-06-11, Stefan Boetschi: MP1.2 export
                    expr=xpath.compile('.//Property[@Name="Ds1_Group_Category_Text"]/@Value');
                    obj.GroupCategoryText = expr.evaluate(obj.DocNode, XPathConstants.STRING);
                else
                    expr=xpath.compile('.//EOParameter[@Name="Ds1_Group_Category_Text"]');
                    result=expr.evaluate(obj.ObjectNode, XPathConstants.NODE);
                    if ~isempty(result)
                        expr=xpath.compile('.//Value/@Value');
                        obj.GroupCategoryText=expr.evaluate(result, XPathConstants.STRING);
                    end
                end
            end
            % parse GroupCategory if property exists
            if isprop(obj,'GroupCategory')
                if (strcmp(obj.Version , 'MP1.2') == 1)
                    % 2014-06-11, Stefan Boetschi: MP1.2 export
                    expr=xpath.compile('.//Property[@Name="Ds1_Group_Category"]/@Value');
                    obj.GroupCategory = expr.evaluate(obj.DocNode, XPathConstants.STRING);
                    if isempty(obj.GroupCategory)
                        Send2GUI({...
                            [ '    ERROR : Property Group-Category of Group-Object of type ',...
                            obj.ObjectType ' is missing. This could be an error in the ABT export file.'];
                            [ '    Please enter the Group-Category manually in the Simulink model after the import has finished.'];
                            [ '            BaObjRef.DeviceId : ' obj.DevIDRef                                   ];...
                            [ '            BaObjRef.ObjectId : ' obj.ObjIDRef                                   ];...
                            [ '            Object Name       : ' obj.ObjectName];},obj.h);
                    end
                else
                    expr=xpath.compile('.//EOParameter[@Name="Ds1_Group_Category"]');
                    result=expr.evaluate(obj.ObjectNode, XPathConstants.NODE);
                    if ~isempty(result)
                        expr=xpath.compile('.//Value/@Value');
                        obj.GroupCategory=expr.evaluate(result, XPathConstants.STRING);
                    else
                        Send2GUI({...
                            [ '    ERROR : Property Group-Category of Group-Object of type ',...
                            obj.ObjectType ' is missing. This could be an error in the ABT export file.'];
                            [ '    Please enter the Group-Category manually in the Simulink model after the import has finished.'];
                            [ '            BaObjRef.DeviceId : ' obj.DevIDRef                                   ];...
                            [ '            BaObjRef.ObjectId : ' obj.ObjIDRef                                   ];...
                            [ '            Object Name       : ' obj.ObjectName];},obj.h);
                    end
                end
            end
            % parse GroupNumber if property exists
            if isprop(obj,'GroupNumber')
                if (strcmp(obj.Version , 'MP1.2') == 1)
                    % 2014-06-11, Stefan Boetschi: MP1.2 export
                    expr=xpath.compile('.//Property[@Name="Ds1_Group_Number"]/@Value');
                    obj.GroupNumber = expr.evaluate(obj.DocNode, XPathConstants.STRING);
                    if isempty(obj.GroupNumber)
                        Send2GUI({...
                            [ '    ERROR : Property Group-Number of Group-Object of type ',...
                            obj.ObjectType ' is missing in the ABT export file. '];
                            [ '    Please enter the Group-Number manually in the Simulink model after the import has finished.'];
                            [ '            BaObjRef.DeviceId : ' obj.DevIDRef                                   ];...
                            [ '            BaObjRef.ObjectId : ' obj.ObjIDRef                                   ];...
                            [ '            Object Name       : ' obj.ObjectName];},obj.h);
                    end
                else
                    expr=xpath.compile('.//EOParameter[@Name="Ds1_Group_Number"]');
                    result=expr.evaluate(obj.ObjectNode, XPathConstants.NODE);
                    if ~isempty(result)
                        expr=xpath.compile('.//Value/@Value');
                        obj.GroupNumber=expr.evaluate(result, XPathConstants.STRING);
                    else
                        Send2GUI({...
                            [ '    ERROR : Property Group-Number of Group-Object of type ',...
                            obj.ObjectType ' is missing in the ABT export file. '];
                            [ '    Please enter the Group-Number manually in the Simulink model after the import has finished.'];
                            [ '            BaObjRef.DeviceId : ' obj.DevIDRef                                   ];...
                            [ '            BaObjRef.ObjectId : ' obj.ObjIDRef                                   ];...
                            [ '            Object Name       : ' obj.ObjectName];},obj.h);
                    end
                end
            end
            % parse Out_Of_Service if property exists
            if isprop(obj,'OutOfService')
                if (strcmp(obj.Version , 'MP1.2') == 1)
                    expr=xpath.compile('.//Property[@Name="Out_Of_Service"]/@Value');
                    obj.OutOfService = lower(expr.evaluate(obj.DocNode, XPathConstants.STRING));
                    if isempty(obj.OutOfService)
                        obj.OutOfService = 'false';
                    end
                else
                    expr=xpath.compile('.//EOParameter[@Name="Out_Of_Service"]');
                    result=expr.evaluate(obj.ObjectNode, XPathConstants.NODE);
                    if ~isempty(result) % Property value not empty in .ba-file -> parse
                        expr=xpath.compile('.//Value/@Value');
                        obj.OutOfService=expr.evaluate(result, XPathConstants.STRING); % string
                    else % Property value empty in .ba-file -> set default value 'false': Object does participate in group communication
                        obj.OutOfService = 'false';
                    end
                end
            end
            %% Stefan 10.10.2013, parse properties of BA_GROUPMASTER
            % parse Ds1_Acknowledge_Timeout if property exists
            if isprop(obj,'AcknowledgeTimeout')
                if (strcmp(obj.Version , 'MP1.2') == 1)
                    expr=xpath.compile('.//Property[@Name="Ds1_Acknowledge_Timeout"]/@Value');
                    obj.AcknowledgeTimeout = expr.evaluate(obj.DocNode, XPathConstants.STRING);
                    if isempty(obj.AcknowledgeTimeout)
                        obj.AcknowledgeTimeout = '0';
                    end
                else
                    expr=xpath.compile('.//EOParameter[@Name="Ds1_Acknowledge_Timeout"]');
                    result=expr.evaluate(obj.ObjectNode, XPathConstants.NODE);
                    if ~isempty(result) % Property value not empty in .ba-file -> parse
                        expr=xpath.compile('.//Value/@Value');
                        obj.AcknowledgeTimeout=expr.evaluate(result, XPathConstants.STRING); % string
                    else
                        % Property value empty in .ba-file -> set default value '0' [s]: No acknowledgement of distributed group commands
                        % by BA-Group-Member-Objects required
                        obj.AcknowledgeTimeout = '0';
                    end
                end
            end
            % parse Ds1_Command_Retry_Count if property exists
            if isprop(obj,'CommandRetryCount')
                if (strcmp(obj.Version , 'MP1.2') == 1)
                    expr=xpath.compile('.//Property[@Name="Ds1_Command_Retry_Count"]/@Value');
                    obj.CommandRetryCount = expr.evaluate(obj.DocNode, XPathConstants.STRING);
                    if isempty(obj.AcknowledgeTimeout)
                        obj.CommandRetryCount = '0';
                    end
                else
                    expr=xpath.compile('.//EOParameter[@Name="Ds1_Command_Retry_Count"]');
                    result=expr.evaluate(obj.ObjectNode, XPathConstants.NODE);
                    if ~isempty(result) % Property value not empty in .ba-file -> parse
                        expr=xpath.compile('.//Value/@Value');
                        obj.CommandRetryCount=expr.evaluate(result, XPathConstants.STRING); % string
                    else % Property value empty in .ba-file -> set default value '0' [s]: No redistribution of group commands
                        obj.CommandRetryCount = '0';
                    end
                end
            end
            % parse Ds1_Collect_Data_Delay if property exists
            if isprop(obj,'CollectDataDelay')
                if (strcmp(obj.Version , 'MP1.2') == 1)
                    expr=xpath.compile('.//Property[@Name="Ds1_Collect_Data_Delay"]/@Value');
                    obj.CollectDataDelay = expr.evaluate(obj.DocNode, XPathConstants.STRING);
                    if isempty(obj.CollectDataDelay)
                        obj.CollectDataDelay = '0';
                    end
                else
                    expr=xpath.compile('.//EOParameter[@Name="Ds1_Collect_Data_Delay"]');
                    result=expr.evaluate(obj.ObjectNode, XPathConstants.NODE);
                    if ~isempty(result) % Property value not empty in .ba-file -> parse
                        expr=xpath.compile('.//Value/@Value');
                        obj.CollectDataDelay=expr.evaluate(result, XPathConstants.STRING); % string
                    else % Property value empty in .ba-file -> set default value '0' [s]: No collect data delay
                        obj.CollectDataDelay = '0';
                    end
                end
            end
            % parse Ds1_Heartbeat_Interval if property exists
            if isprop(obj,'HeartbeatInterval')
                if (strcmp(obj.Version , 'MP1.2') == 1)
                    expr=xpath.compile('.//Property[@Name="Ds1_Heartbeat_Interval"]/@Value');
                    obj.HeartbeatInterval = expr.evaluate(obj.DocNode, XPathConstants.STRING);
                    if isempty(obj.HeartbeatInterval)
                        obj.HeartbeatInterval= '15';
                    end
                else
                    expr=xpath.compile('.//EOParameter[@Name="Ds1_Heartbeat_Interval"]');
                    result=expr.evaluate(obj.ObjectNode, XPathConstants.NODE);
                    if ~isempty(result) % Property value not empty in .ba-file -> parse
                        expr=xpath.compile('.//Value/@Value');
                        obj.HeartbeatInterval=expr.evaluate(result, XPathConstants.STRING); % string
                    else % Property value empty in .ba-file -> set default minimal allowed value '15' [min]
                        obj.HeartbeatInterval = '15';
                    end
                end
            end
            %% Stefan 10.10.2013, parse BA_GROUPMEMBER specific properties in a BA_GROUPMEMBER specific method
            if strcmp(obj.ObjectType,'BA_GROUP_MEMBER')
                obj.parseGroupMemberProp;
            end
            %% Stefan 05.08.2014, parse BA_LOOP specific properties in a BA_LOOP specific method
            if strcmp(obj.ObjectType,'BA_LOOP')
               obj.parseLoopProp; 
            end
            %%
            obj.getSubList;
            if not(isempty(obj.SubList))
                obj.generateObjectList;
            end
        end
        function getSubList(obj)
            import javax.xml.xpath.*
            factory = XPathFactory.newInstance;
            xpath = factory.newXPath;
            
            if (strcmp(obj.Version , 'MP1.2') == 1)
                % erzeugen der Knotenliste Subordinate_Annotations
                expr=xpath.compile('.//Property[@Name="Subordinate_Annotations"]/@Value');
                Subordinate_Annotations = expr.evaluate(obj.DocNode, XPathConstants.STRING);
                if ~isempty(Subordinate_Annotations)
                    Subordinate_Annotations = regexprep(Subordinate_Annotations, '[[?]]', '');
                    if ~isempty(Subordinate_Annotations) % 2014-06-10, Stefan Boetschi: Check again after regexprep()
                        Subordinate_Annotations = textscan(Subordinate_Annotations, '%s', 'delimiter', '|');
                        Subordinate_Annotations = Subordinate_Annotations{1,1};
                        
                        % erzeugen der Knotenliste Ds1_Subordinate_Attributes
                        expr=xpath.compile('.//Property[@Name="Ds1_Subordinate_Attributes"]/@Value');
                        Ds1_Subordinate_Attributes = expr.evaluate(obj.DocNode, XPathConstants.STRING);
                        Ds1_Subordinate_Attributes = regexprep(Ds1_Subordinate_Attributes, '[[?{?}?]]', '');
                        Ds1_Subordinate_Attributes = textscan(Ds1_Subordinate_Attributes, '%s', 'delimiter', '|');
                        Ds1_Subordinate_Attributes = Ds1_Subordinate_Attributes{1,1};
                        
                        % 2014-07-08, Stefan Boetschi: Parse
                        % Subordinate_List
                        expr=xpath.compile('.//Property[@Name="Subordinate_List"]/@Value');
                        Subordinate_List = expr.evaluate(obj.DocNode, XPathConstants.STRING);
                        Subordinate_List = regexp(Subordinate_List,')|(','split');
                        for l=1:numel(Subordinate_List)
                            if strcmp(Subordinate_List{l},'[') || strcmp(Subordinate_List{l},'|') || strcmp(Subordinate_List{l},']')
                                Subordinate_List{l} = '';
                            end
                        end
                        Subordinate_List = Subordinate_List(~cellfun('isempty',Subordinate_List));
                        
                        % 2014-07-08, Stefan Boetschi: Compute the ObjId
                        % following the rule: ObjId = ObjTypId*2^22 +
                        % ObjInstance
                        for k=1:numel(Subordinate_List)
                            % Default DeviceId
                            obj.SubList{1,k}='4194303';
                            % Extract information that forms the ObjectId
                            curEntry = Subordinate_List{k};
                            barInd = strfind(curEntry,'|');
                            if strcmp(curEntry(barInd+1:end),'Unassigned')
                                % Default ObjectId
                                obj.SubList{2,k}='4194303';
                            else
                                % Compute ObjectId
                                commaInd = strfind(curEntry,',');
                                ObjTypeString = curEntry(barInd+1:commaInd-1);
                                ObjInstance = str2num(curEntry(commaInd+1:end));
                                foundTypeId = false;
                                for c=1:size(obj.BAObjTypeIds)
                                    if strcmpi(obj.BAObjTypeIds(c,1),ObjTypeString)
                                        foundTypeId = true;
                                        % Read object type number from the
                                        % table
                                        ObjTypId=obj.BAObjTypeIds{c,2};
                                        obj.SubList{2,k} = num2str(ObjTypId*(2^22)+ObjInstance);
                                    end
                                end
                                if ~foundTypeId
                                    % Default ObjectId
                                    obj.SubList{2,k}='4194303';
                                end
                                
                            end
                        end
                        
                        for k=1:numel(Subordinate_Annotations)
                            % Speichern der benötigten Subortinate List Informationen in ein Array SubList{4,k}
                            if ~(strcmp(char(Subordinate_Annotations{k}),''))
                                obj.SubList{3,k} = char(Subordinate_Annotations{k});
                            else
                                obj.SubList{3,k} = '<no ObjectName>';
                            end
                            obj.SubList{4,k} = char(Ds1_Subordinate_Attributes{k});
                        end
                    end
                end
            else
                % erzeugen der Knotenliste Subordinate_List
                expr=xpath.compile('.//EOParameter[@Name="Subordinate_List"]//Element');
                Subordinate_List=expr.evaluate(obj.ObjectNode, XPathConstants.NODESET);
                % erzeugen der Knotenliste Subordinate_Annotations
                expr=xpath.compile('.//EOParameter[@Name="Subordinate_Annotations"]//Element');
                Subordinate_Annotations=expr.evaluate(obj.ObjectNode, XPathConstants.NODESET);
                % erzeugen der Knotenliste Ds1_Subordinate_Attributes
                expr=xpath.compile('.//EOParameter[@Name="Ds1_Subordinate_Attributes"]//Element');
                Ds1_Subordinate_Attributes=expr.evaluate(obj.ObjectNode, XPathConstants.NODESET);
                for k=1:Subordinate_Annotations.getLength
                    % Speichern der benötigten Subortinate List Informationen in ein Array SubList{4,k}
                    expr=xpath.compile('.//Field[@Name="DevIDRef"]//Value/@Value');
                    obj.SubList{1,k}=expr.evaluate(Subordinate_List.item(k-1), XPathConstants.STRING);
                    expr=xpath.compile('.//Field[@Name="ObjIDRef"]//Value/@Value');
                    obj.SubList{2,k}=expr.evaluate(Subordinate_List.item(k-1), XPathConstants.STRING);
                    expr=xpath.compile('.//Value/@Value');
                    obj.SubList{3,k}=expr.evaluate(Subordinate_Annotations.item(k-1), XPathConstants.STRING);
                    expr=xpath.compile('.//Bit/@Value');
                    obj.SubList{4,k}=expr.evaluate(Ds1_Subordinate_Attributes.item(k-1), XPathConstants.STRING);
                end
            end
        end
        
        function generateObjectList(obj)
            import javax.xml.xpath.*
            factory = XPathFactory.newInstance;
            xpath = factory.newXPath;
            
            if isempty(obj.SubList)
                Send2GUI('    ERROR : No AF object has been found.',obj.h);
            else
                count = 1;
                %die Sublist wird durchsucht
                for k=1:size(obj.SubList,2)
                    %für SubList Elemente = TRUE
                    if strcmpi(obj.SubList{4,k},'true')
                        
                        %get Engineering Object Node
                        %suche Nach zweitem vorkommen der Objekt ID,
                        %Device ID kann nicht geprüft werden bzw.
                        %Verküpfung der SubList mit Objekt
                        if (strcmp(obj.Version , 'MP1.2') == 1)
                            expr=xpath.compile('.//OwnedBAObjects//BAObject');
                            BAObjects=expr.evaluate(obj.DocNode, XPathConstants.NODESET);
                            %check ob BA Object innerhalb des Files ist ansonsten
                            %neues File öffenen.
                            if (BAObjects.getLength == 0)
                                % 2014-06-10, Stefan Boetschi: Have to search ALL
                                % the .xml files in the subfolder for the owned BA
                                % object
                                fileCollection = dir([obj.FilePath '\' strtok(obj.FileName, '.')...
                                    '\*.xml']);
                                foundBAflag = false;
                                % Search for ViewNode functions
                                if (length(fileCollection) > 1)
                                    % Multiple files below the current superior
                                    % object -> find the correct one
                                    for l=1:length(fileCollection)
                                        xDoc = xmlread([obj.FilePath '\' strtok(obj.FileName, '.') '\' fileCollection(l).name]);
                                        expr=xpath.compile('.//Entity//Property[@Name="PartName"]/@Value');
                                        partName = expr.evaluate(xDoc, XPathConstants.STRING);
                                        expr=xpath.compile('.//Entity//Property[@Name="Object_Identifier"]/@Value');
                                        objID = expr.evaluate(xDoc, XPathConstants.STRING);
                                        % Check if PartName coincides with entry of
                                        % Subordinate_Annotations of superior object
                                        if (strcmp(partName, obj.SubList{3,k}) && strcmp(obj.SubList{2,k},'4194303')) || ((strcmp(objID, obj.SubList{2,k}) && ~strcmp(objID,'4194303')))
                                            expr=xpath.compile('.//Entity//Property[@Name="Ds1_Ba_Prototype"]/@Value');
                                            ProtoType = expr.evaluate(xDoc, XPathConstants.NUMBER);
                                            ObjectNode_v = xDoc;
                                            obj.SubList{1,k} = '4194303';
                                            if ~strcmp(obj.SubList{2,k},objID)
                                                obj.SubList{2,k} = objID;
                                            end
                                            % 2014-07-21, Stefan Boetschi:
                                            % Replace the part name from the
                                            % Subordinate_List with the one parsed
                                            % directly from the correct .xml file
                                            % if the two strings do not match
                                            if ~strcmp(partName, obj.SubList{3,k})
                                                obj.SubList{3,k} = partName;
                                            end
                                            foundBAflag = true;
                                            path = [obj.FilePath '\' strtok(obj.FileName, '.') '\'];
                                            file = fileCollection(l);
                                            break;
                                        end
                                    end
                                else
                                    % Only one file below the current superior
                                    % object -> take it irrespective of the object
                                    % part name
                                    xDoc = xmlread([obj.FilePath '\' strtok(obj.FileName, '.') '\' fileCollection(1).name]);
                                    expr=xpath.compile('.//Entity//Property[@Name="Ds1_Ba_Prototype"]/@Value');
                                    ProtoType = expr.evaluate(xDoc, XPathConstants.NUMBER);
                                    ObjectNode_v = xDoc;
                                    expr=xpath.compile('.//Entity//Property[@Name="Object_Identifier"]/@Value');
                                    obj.SubList{1,k} = '4194303';
                                    if ~strcmp(obj.SubList{2,k},expr.evaluate(ObjectNode_v, XPathConstants.STRING))
                                        obj.SubList{2,k} = expr.evaluate(ObjectNode_v, XPathConstants.STRING);
                                    end
                                    foundBAflag = true;
                                    path = [obj.FilePath '\' strtok(obj.FileName, '.') '\'];
                                    file = fileCollection(1);
                                end
                                % Search for owned BA objects
                                if (foundBAflag == false)
                                    for l=1:length(fileCollection)
                                        xDoc = xmlread([obj.FilePath '\' strtok(obj.FileName, '.') '\' fileCollection(l).name]);
                                        % Get object id of entity in the current
                                        % file of the file collection
                                        expr = xpath.compile(['.//Entity//Property[@Name="Object_Identifier"]/@Value']);
                                        curObjId = expr.evaluate(xDoc,XPathConstants.STRING);
                                        % Compare object ids: only parse the
                                        % current file for owned BA objects if the
                                        % object ids match
                                        if strcmp(curObjId,obj.ObjIDRef)
                                            expr = xpath.compile(['.//Entity//OwnedBAObjects//BAObject[@Name="' obj.SubList{3,k} '"]']);
                                            result = expr.evaluate(xDoc,XPathConstants.NODE);
                                            if ~isempty(result)
                                                ObjectNode_v = result;
                                                expr=xpath.compile('.//Property[@Name="Ds1_Ba_Prototype"]/@Value');
                                                ProtoType = expr.evaluate(ObjectNode_v, XPathConstants.NUMBER);
                                                expr=xpath.compile('.//Property[@Name="Object_Identifier"]/@Value');
                                                obj.SubList{1,k} = '4194303';
                                                if ~strcmp(obj.SubList{2,k},expr.evaluate(ObjectNode_v, XPathConstants.STRING))
                                                    obj.SubList{2,k} = expr.evaluate(ObjectNode_v, XPathConstants.STRING);
                                                end
                                                foundBAflag = true;
                                                path = [obj.FilePath '\' strtok(obj.FileName, '.') '\'];
                                                file = fileCollection(l);
                                                break;
                                            end
                                        end
                                    end
                                end
                                % Search for items of ViewNode Collections
                                if (foundBAflag == false)
                                    folderContents = dir([obj.FilePath '\' strtok(obj.FileName, '.')]);
                                    dirCount = 0;
                                    for l=1:length(folderContents)
                                        curFolderPath = [obj.FilePath '\' strtok(obj.FileName, '.') '\' folderContents(l).name];
                                        if (isdir(curFolderPath) && ~strcmp(folderContents(l).name,'.') && ~strcmp(folderContents(l).name,'..'))
                                            dirCount = dirCount + 1;
                                            dirList{dirCount} = folderContents(l).name;
                                            break;
                                        end
                                    end
                                    for m=1:dirCount
                                        curFolder = dirList{m};
                                        fileCollection = dir([obj.FilePath '\' strtok(obj.FileName, '.')...
                                            '\' curFolder '\*.xml']);
                                        for l=1:length(fileCollection)
                                            xDoc = xmlread([obj.FilePath '\' strtok(obj.FileName, '.')...
                                                '\' curFolder '\' fileCollection(l).name]);
                                            expr=xpath.compile('.//Entity//Property[@Name="PartName"]/@Value');
                                            partName = expr.evaluate(xDoc, XPathConstants.STRING);
                                            expr=xpath.compile('.//Entity//Property[@Name="Object_Identifier"]/@Value');
                                            objID = expr.evaluate(xDoc, XPathConstants.STRING);
                                            if (strcmp(partName, obj.SubList{3,k}) && strcmp(obj.SubList{2,k},'4194303')) || ((strcmp(objID, obj.SubList{2,k}) && ~strcmp(objID,'4194303')))
                                                expr=xpath.compile('.//Entity//Property[@Name="Ds1_Ba_Prototype"]/@Value');
                                                ProtoType = expr.evaluate(xDoc, XPathConstants.NUMBER);
                                                ObjectNode_v = xDoc;
                                                obj.SubList{1,k} = '4194303';
                                                if ~strcmp(obj.SubList{2,k},objID)
                                                    obj.SubList{2,k} = objID;
                                                end
                                                % 2014-07-21, Stefan Boetschi:
                                                % Replace the part name from the
                                                % Subordinate_List with the one parsed
                                                % directly from the correct .xml file
                                                % if the two strings do not match
                                                if ~strcmp(partName, obj.SubList{3,k})
                                                    obj.SubList{3,k} = partName;
                                                end
                                                foundBAflag = true;
                                                path = [obj.FilePath '\' strtok(obj.FileName, '.') '\' curFolder '\'];
                                                file = fileCollection(l);
                                            end
                                        end
                                    end
                                end
                                % Could neither find a ViewNode Function nor an
                                % owend BA object -> error
                                if (foundBAflag == false)
                                    Send2GUI({...
                                        '    ERROR : Engineering Object not found. This could be an error in the ABT export file.' ;...
                                        [ '            Subordinate List of Object: | ' obj.ObjectName ' | at Position ' num2str(k)   ];...
                                        [ '            BaObjRef.DeviceId : ' obj.SubList{1,k}                                        ];...
                                        [ '            BaObjRef.ObjectId : ' obj.SubList{2,k}                                        ];...
                                        [ '            Object Name       : ' obj.SubList{3,k}                                        ];...
                                        [ '            Valid for Import  : ' obj.SubList{4,k}                                        ]},obj.h);
                                    continue % Jump to next Iteration
                                end
                            else
                                expr=['.//OwnedBAObjects//BAObject[@Id="' num2str(k) '"]'];
                                expr=xpath.compile(expr);
                                result=expr.evaluate(obj.DocNode, XPathConstants.NODE);
                                if isempty(result)
                                    Send2GUI({...
                                        '    ERROR : Engineering Object not found. This could be an error in the ABT export file.' ;...
                                        [ '            Subordinate List of Object: | ' obj.ObjectName ' | at Position ' num2str(k)   ];...
                                        [ '            BaObjRef.DeviceId : ' obj.SubList{1,k}                                        ];...
                                        [ '            BaObjRef.ObjectId : ' obj.SubList{2,k}                                        ];...
                                        [ '            Object Name       : ' obj.SubList{3,k}                                        ];...
                                        [ '            Valid for Import  : ' obj.SubList{4,k}                                        ]},obj.h);
                                    continue % Jump to next Iteration
                                else
                                    ObjectNode_v = result;
                                    expr=xpath.compile('.//Property[@Name="Ds1_Ba_Prototype"]/@Value');
                                    ProtoType = expr.evaluate(ObjectNode_v, XPathConstants.NUMBER);
                                    expr=xpath.compile('.//Property[@Name="Object_Identifier"]/@Value');
                                    obj.SubList{1,k} = '4194303';
                                    if ~strcmp(obj.SubList{2,k},expr.evaluate(ObjectNode_v, XPathConstants.STRING))
                                        obj.SubList{2,k} = expr.evaluate(ObjectNode_v, XPathConstants.STRING);
                                    end
                                end
                            end
                        else
                            expr=['.//EOParameter[@Name="Object_Identifier"]//Value[@Value="' obj.SubList{2,k} '"]'];
                            expr=xpath.compile(expr);
                            result=expr.evaluate(obj.DocNode, XPathConstants.NODE);
                            %[EngineeringObject]
                            if isempty(result)
                                Send2GUI({...
                                    '    ERROR : Engineering Object not found. This could be an Error in the ABT export file.' ;...
                                    [ '            Subordinate List of Object: | ' obj.ObjectName ' | at Position ' num2str(k)   ];...
                                    [ '            BaObjRef.DeviceId : ' obj.SubList{1,k}                                        ];...
                                    [ '            BaObjRef.ObjectId : ' obj.SubList{2,k}                                        ];...
                                    [ '            Object Name       : ' obj.SubList{3,k}                                        ];...
                                    [ '            Valid for Import  : ' obj.SubList{4,k}                                        ]},obj.h);
                                ProtoType = str2double (obj.SubList{2,k});
                                ProtoType = bitand(ProtoType, hex2dec('FFC00000'));
                                ProtoType = bitshift(ProtoType, -22);
                                continue % Jump to next Iteration
                            else
                                ObjectNode_v = result.getParentNode.getParentNode.getParentNode.getParentNode;
                                expr=xpath.compile('.//EOTypeRef//@Prototype');
                                ProtoType = expr.evaluate(ObjectNode_v, XPathConstants.NUMBER);
                            end
                        end
                        
                        %Hier jetzt mit Switch Case Bewerten und Richtiges BACNET Objekt
                        %zuweisen.
                        % 1. in Liste eintragen Objekt{1,:}
                        switch ProtoType
                            case{1,2,3,4,5,6,11,12,13,14,17,32}
                                obj.ObjectList{count}=BA_SIMPEL;
                                switch ProtoType
                                    case {1} % SIE_BA_ANALOGINPUT = 1, // AI
                                        obj.ObjectList{count}.ObjectType='BA_AI';
                                    case {2} % SIE_BA_ANALOGPROCESSVALUE = 2 // APrcVal
                                        obj.ObjectList{count}.ObjectType='BA_AV';
                                    case {3} % SIE_BA_ANALOGOUTPUT = 3, // AO
                                        obj.ObjectList{count}.ObjectType='BA_AO';
                                    case {11} % SIE_BA_ANALOGCONFIGVALUE = 11 // ACnfVal
                                        obj.ObjectList{count}.ObjectType='BA_ACNV';
                                    case {12} % SIE_BA_ANALOGCALCULATEDVALUE = 12 // ACalcVal
                                        obj.ObjectList{count}.ObjectType='BA_ACV';
                                    case {4} % SIE_BA_BINARYINPUT = 4, // BI
                                        obj.ObjectList{count}.ObjectType='BA_BI';
                                    case {5} % SIE_BA_BINARYPROCESSVALUE = 5 // BPrcVal
                                        obj.ObjectList{count}.ObjectType='BA_BV';
                                    case {6} % SIE_BA_BINARYOUTPUT = 6, // BO
                                        obj.ObjectList{count}.ObjectType='BA_BO';
                                    case {13} % SIE_BA_BINARYCONFIGVALUE      = 13 // BCnfVal
                                        obj.ObjectList{count}.ObjectType='BA_BCNV';
                                    case {14} % SIE_BA_BINARYCALCULATEDVALUE = 14 // BCalcVal
                                        obj.ObjectList{count}.ObjectType='BA_BCV';
                                    case {17} % SIE_BA_UNSIGNEDCONFIGVALUE = 17 // UCnfVal
                                        obj.ObjectList{count}.ObjectType='BA_UNSGCNV';
                                    case {32} % SIE_BA_COMMAND = 32 // CmdObj
                                        obj.ObjectList{count}.ObjectType='BA_CMD';
                                end
                                obj.ObjectList{count}.ObjectName=strcat(obj.ObjectName,'/',obj.SubList{3,k});
                                
                            case{7,8,9,15,16,19}
                                obj.ObjectList{count}=BA_MULTI;
                                switch ProtoType
                                    case {7} % SIE_BA_MULTISTATEINPUT = 7, // MI
                                        obj.ObjectList{count}.ObjectType='BA_MI';
                                    case {8} % SIE_BA_MULTISTATEPROCESSVALUE = 8 // MPrcVal
                                        obj.ObjectList{count}.ObjectType='BA_MV';
                                    case {9} % SIE_BA_MULTISTATEOUTPUT = 9, // MO
                                        obj.ObjectList{count}.ObjectType='BA_MO';
                                    case {15} % SIE_BA_MULTISTATECONFIGVALUE  = 15 // MCnfVal
                                        obj.ObjectList{count}.ObjectType='BA_MCNV';
                                    case {16} % SIE_BA_MULTISTATECALCULATEDVALUE = 16 // MCalcVal
                                        obj.ObjectList{count}.ObjectType='BA_MCV';
                                    case {19} %SIE_BA_MULTISTATETRIGGERVALUE
                                        obj.ObjectList{count}.ObjectType='BA_MTV';
                                end
                                obj.ObjectList{count}.ObjectName=strcat(obj.ObjectName,'/',obj.SubList{3,k});
                                
                                % Stefan, 04.10.13
                            case {29} % SIE_BA_GROUPMASTER = 29 // GrpMaster
                                % Send2GUI('    WARNING : GrpMstr and GrpMbr objects in IMSES do not support lighting and blinds applications so far.',obj.h);
                                obj.ObjectList{count}=BA_GROUPMASTER;
                                obj.ObjectList{count}.ObjectType = 'BA_GROUP_MASTER';
                                obj.ObjectList{count}.ObjectName = strcat(obj.ObjectName,'/', obj.SubList{3,k});
                                
                                % comment the continue statement in order to make the
                                % BA_GROUP_MASTER objects appear in the ObjectList:
                                % continue % Jump to next Iteration
                                % Stefan, 10.10.13
                            case {30} % SIE_BA_GROUPMEMBER = 30 // GrpMbr
                                % Send2GUI('    WARNING : GrpMstr and GrpMbr objects in IMSES do not support lighting and blinds applications so far.',obj.h);
                                obj.ObjectList{count}=BA_GROUPMEMBER;
                                obj.ObjectList{count}.ObjectType = 'BA_GROUP_MEMBER';
                                obj.ObjectList{count}.ObjectName = strcat(obj.ObjectName,'/', obj.SubList{3,k});
                                
                                % Stefan, 05.08.14
                            case {33} % SIE_BA_LOOP
                                obj.ObjectList{count}=BA_LOOP;
                                obj.ObjectList{count}.ObjectType = 'BA_LOOP';
                                obj.ObjectList{count}.ObjectName = strcat(obj.ObjectName,'/', obj.SubList{3,k});
                                
                                % OBJ_STRUCTURED_VIEW
                            case {40} % SIE_BA_VNOBJECTFUNCTIONAL = 40 // FnctView
                                obj.ObjectList{count}=BA_VN_F;
                                obj.ObjectList{count}.ObjectType='BA_VN_F';
                                obj.ObjectList{count}.ObjectName=strcat(obj.ObjectName,'/', obj.SubList{3,k});
                                
                            case {41} % SIE_BA_VNOBJECTCOLLECTION = 41 // ColView
                                obj.ObjectList{count}=BA_VN_C;
                                obj.ObjectList{count}.ObjectType='BA_VN_C';
                                obj.ObjectList{count}.ObjectName=strcat(obj.ObjectName,'/',obj.SubList{3,k});
                            
                            % OBJ_STRUCTURED_VIEW
                            case {42} % SIE_BA_VNOBJECTDEVICE = 42 // Device_View
                                obj.ObjectList{count}=BA_VN_F;
                                obj.ObjectList{count}.ObjectType='BA_VN_F';
                                obj.ObjectList{count}.ObjectName=strcat(obj.ObjectName,'/', obj.SubList{3,k});     
                                
                            case {44} % SIE_BA_VNOBJECTAREA = 44 // AreaView
                                Send2GUI({...
                                    '    ERROR : There should be only one AreaView object (ProtoType 44) in the ABT export file.';...
                                    '            Please check that file for errors.'} ,obj.h);
                                continue % Jump to next Iteration
                                
                            otherwise
                                Send2GUI({...
                                    ['    ERROR : Prototype ' num2str(ProtoType) ' unknown.'];...
                                    '            BA objects with this prototype number are not supported by IMSES so far.';...
                                    [ '            BaObjRef.DeviceId : ' obj.SubList{1,k}                                        ];...
                                    [ '            BaObjRef.ObjectId : ' obj.SubList{2,k}                                        ];...
                                    [ '            Object Name       : ' obj.SubList{3,k}                                        ];...
                                    [ '            Valid for Import  : ' obj.SubList{4,k}                                        ]},obj.h);
                                continue % Jump to next Iteration
                                
                        end
                        % passing the handle
                        obj.ObjectList{count}.h=obj.h;
                        % passing the FirmwareLib
                        obj.ObjectList{count}.FWLib=obj.FWLib;
                        % passing the DocNode
                        obj.ObjectList{count}.DocNode=ObjectNode_v;
                        % passing the ObjectNode
                        obj.ObjectList{count}.ObjectNode=ObjectNode_v;
                        % passing the ObjectList Position
                        obj.ObjectList{count}.ObjectListPos=count;
                        %aus Sublist mitgeben
                        obj.ObjectList{count}.DevIDRef=obj.SubList{1,k};
                        obj.ObjectList{count}.ObjIDRef=obj.SubList{2,k};
                        obj.ObjectList{count}.Version = obj.Version;
                        % 2014-05-27, Stefan Boetschi: MP1.2 -> Also save obj.FilePath and
                        % obj.FileName
                        if (strcmp(obj.Version , 'MP1.2') == 1)
                            if (BAObjects.getLength == 0)
                                if exist([path '\' file.name], 'file')
                                    obj.ObjectList{count}.FilePath = path;
                                    obj.ObjectList{count}.FileName = file.name;
                                end
                            else
                                obj.ObjectList{count}.FilePath = obj.FilePath;
                                obj.ObjectList{count}.FileName = obj.FileName;
                            end
                        end
                        
                        
                        if not(isempty(obj.ObjectList{count}))
                            obj.ObjectList{count}.parse;
                        end
                        count=count+1;
                    end
                end
            end
        end % generateObjectList(obj)
    end % METHODS
end % CLASSDEF