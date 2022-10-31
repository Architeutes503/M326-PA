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
%
%   Author                      : Simon Marty
%   Version                     : v1.1
%   Date                        : 20-Feb-2012
%
%   Author                      : Thomas Rohr
%   Version                     : v1.0
%   Date                        : 17-Apr-2014
%   
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
%   2014-04-17 17:30 Simon Marty
%   Create Object if Object doesn't exist, but has a valid Link ID
%
%   2014-04-16 17:50 Simon Marty
%   Create new Area if a new connected Object is createt
%
%   2014-04-16 14:50 Simon Marty
%   Create Object if the Link ID in the subordinate_list is wrong but a
%   matching Placeholder in subordinate_annotations does exist
%
%   2013-11-07 11:30 Stefan Boetschi
%   Write error message to GUI if property Group-Category or Group-Number
%   is missing in the *.ba file to be imported.
%
%   2013-10-10 12:00 Stefan Boetschi
%   Support for Group-Master-Objects under construction
%   Support for Group-Member-Objects under construction
% 	
% 	2012-03-20 14:00 Thomas Rohr
%	Header comment was attached
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
properties (GetAccess = public)
  SubList
  ObjectList
  ObjectListPos
  DevIDRef
  ObjIDRef
  ObjectName
  ObjectType
  ObjectNode
  DocNode
  h
  FWLib
  FilePath
  BAObjTypeNames
end
methods(Static)
   function xmlChartName = getXmlChartName(obj)
       % liest den Chart File Name aus und gibt ihn als Funktionswert zurück
       persistent ChartName;
       if isempty(ChartName)
           % XML File vom Full Import Zip File
           xmlChart = dir([obj.FilePath '\*.XML']);
           ChartName = xmlChart.name;
       end
       xmlChartName = ChartName;
   end
   %%
   function ObjID = getUniqueObjID
       % eindeutige ID erzeugen
       % wird als ObjID für neu erzeugte Objekte gebraucht 
       persistent ID;
       if isempty(ID)
           ID=11000;
       end
       ID=ID+1;
       ObjID = int2str(ID);
   end
end
methods
    function parse(obj)
        import javax.xml.xpath.*
        factory = XPathFactory.newInstance;
        xpath = factory.newXPath;
        % Initialize BA Obj Types
        obj.BAObjTypeNames = {'R_A' 2;'R_B' 5;'R_M' 19;'R_UNSG' 48;...
                              'R_LGTCMD' 260;'R_BLSCMD' 258;'R_AX' 2;...
                              'R_BX' 5;'R_MX' 19;'R_LGTX' 262;'R_BLSX' 259;...
                              'W_A' 2;'W_B' 5;'W_M' 19;'CMD_A' 2;'CMD_B' 5;...
                              'CMD_M' 19;'CMD_LGT' 260;'CMD_BLS' 258;'CMD_AX' 2;'CMD_BX' 5};
		% Initial Parsing when running first time
        %% parsing ObjectNode wenn noch nicht vorhanden
        if isempty(obj.ObjectNode)
            expr   = xpath.compile('.//EOTypeRef[@Prototype="44"]');
            result = expr.evaluate(obj.DocNode, XPathConstants.NODE);
            obj.ObjectNode=result.getParentNode.getParentNode;    
        end
        %% nicht parsen wenn Objekt nicht vorhanden
        % parsing ObjectName wenn noch nicht vorhanden
        expr=xpath.compile('.//ShortDescription/@Value');
        name = expr.evaluate(obj.ObjectNode, XPathConstants.STRING);
        if isempty(obj.ObjectName)
            obj.ObjectName=[name '/BA'];
        else
            expr=['.//EOParameter[@Name="Object_Identifier"]//Value[@Value="' obj.ObjIDRef '"]'];
            expr=xpath.compile(expr);
            result=expr.evaluate(obj.DocNode, XPathConstants.NODE);
            if ~isempty(result)
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
            expr=xpath.compile('.//EOParameter[@Name="Object_Identifier"]//Value/@Value');
            obj.ObjIDRef=expr.evaluate(obj.ObjectNode, XPathConstants.STRING);
        end
        %% parsing Number of States wenn property NumOfStates vorhanden
        if isprop(obj,'NumOfStates')
            %% Alter Code, auskommentiert von Wolfgang ,28.03.13
            %expr=xpath.compile('.//EOParameter[@Name="Number_Of_States"]//Value/@Value');
            %obj.NumOfStates=expr.evaluate(obj.ObjectNode, XPathConstants.STRING);           
            %% Wolfgang, 28.03.13
            %%Number of States über State_Text ermitteln
            %%(Workaround, da export aus ABT diese Info für MCalcVal's nicht lieferte)
            expr=xpath.compile('.//EOParameter[@Name="State_Text"]//Value/@Value');
            array=expr.evaluate(obj.ObjectNode, XPathConstants.NODESET);
            obj.NumOfStates=num2str(array.getLength);
         
        end
        %% parsing DefValue wenn property DefVal vorhanden
        if isprop(obj,'DefValue')
            expr=xpath.compile('.//EOParameter[@Name="Relinquish_Default"]');   
            result=expr.evaluate(obj.ObjectNode, XPathConstants.NODE);
            if ~isempty(result)
                expr=xpath.compile('.//Value/@Value');
                obj.DefValue=expr.evaluate(result, XPathConstants.STRING);
            end  
        end
		%% TOM 09.10.2012
		%% parsing Present_Value wenn property Value vorhanden
        if isprop(obj,'Value')
            expr=xpath.compile('.//EOParameter[@Name="Present_Value"]');   
            result=expr.evaluate(obj.ObjectNode, XPathConstants.NODE);
            if ~isempty(result)
                expr=xpath.compile('.//Value/@Value');
                obj.Value=expr.evaluate(result, XPathConstants.STRING);
            end  
        end 
		%% TOM 09.10.2012
		%% parsing Max_Pres_Value wenn property UpperLimit vorhanden
        if isprop(obj,'UpperLimit')
            expr=xpath.compile('.//EOParameter[@Name="Max_Pres_Value"]');   
            result=expr.evaluate(obj.ObjectNode, XPathConstants.NODE);
            if ~isempty(result)
                expr=xpath.compile('.//Value/@Value');
                obj.UpperLimit=expr.evaluate(result, XPathConstants.STRING);
            end  
        end
		%% TOM 09.10.2012
		%% parsing Min_Pres_Value wenn property LowerLimit vorhanden
        if isprop(obj,'LowerLimit')
            expr=xpath.compile('.//EOParameter[@Name="Min_Pres_Value"]');   
            result=expr.evaluate(obj.ObjectNode, XPathConstants.NODE);
            if ~isempty(result)
                expr=xpath.compile('.//Value/@Value');
                obj.LowerLimit=expr.evaluate(result, XPathConstants.STRING);
            end  
        end 
        %% Stefan 10.10.2013, parse common properties of BA_GROUPMASTER and BA_GROUPMEMBER
        % parse GroupCategoryText if property exists
        if isprop(obj,'GroupCategoryText')
           expr=xpath.compile('.//EOParameter[@Name="Ds1_Group_Category_Text"]');
           result=expr.evaluate(obj.ObjectNode, XPathConstants.NODE);
           if ~isempty(result)
               expr=xpath.compile('.//Value/@Value');
               obj.GroupCategoryText=expr.evaluate(result, XPathConstants.STRING);
           end
        end
        % parse GroupCategory if property exists
        if isprop(obj,'GroupCategory')
           expr=xpath.compile('.//EOParameter[@Name="Ds1_Group_Category"]');
           result=expr.evaluate(obj.ObjectNode, XPathConstants.NODE);
           if ~isempty(result)
               expr=xpath.compile('.//Value/@Value');
               obj.GroupCategory=expr.evaluate(result, XPathConstants.STRING);
           else
               Send2GUI({... 
                    [ '    ERROR : Property Group-Category of Group-Object of type ',...
                      obj.ObjectType ' is missing. This could be an error in the *.ba export file.'];
                    [ '    Please enter the Group-Category manually in the Simulink model after the import has finished.'];
                    [ '            BaObjRef.DeviceId : ' obj.DevIDRef                                   ];...
                    [ '            BaObjRef.ObjectId : ' obj.ObjIDRef                                   ];...
                    [ '            Object Name       : ' obj.ObjectName];},obj.h);
           end
        end
        % parse GroupNumber if property exists
        if isprop(obj,'GroupNumber')
           expr=xpath.compile('.//EOParameter[@Name="Ds1_Group_Number"]');
           result=expr.evaluate(obj.ObjectNode, XPathConstants.NODE);
           if ~isempty(result)
               expr=xpath.compile('.//Value/@Value');
               obj.GroupNumber=expr.evaluate(result, XPathConstants.STRING);
           else
               Send2GUI({... 
                    [ '    ERROR : Property Group-Number of Group-Object of type ',...
                      obj.ObjectType ' is missing in the *.ba export file. '];
                    [ '    Please enter the Group-Number manually in the Simulink model after the import has finished.'];
                    [ '            BaObjRef.DeviceId : ' obj.DevIDRef                                   ];...
                    [ '            BaObjRef.ObjectId : ' obj.ObjIDRef                                   ];...
                    [ '            Object Name       : ' obj.ObjectName];},obj.h);
           end
        end
        % parse Out_Of_Service if property exists
        if isprop(obj,'OutOfService')
           expr=xpath.compile('.//EOParameter[@Name="Out_Of_Service"]');
           result=expr.evaluate(obj.ObjectNode, XPathConstants.NODE);
           if ~isempty(result) % Property value not empty in .ba-file -> parse
               expr=xpath.compile('.//Value/@Value');
               obj.OutOfService=expr.evaluate(result, XPathConstants.STRING); % string
           else % Property value empty in .ba-file -> set default value 'false': Object does participate in group communication
               obj.OutOfService = 'false';
           end
        end
        %% Stefan 10.10.2013, parse properties of BA_GROUPMASTER
        % parse Ds1_Acknowledge_Timeout if property exists
        if isprop(obj,'AcknowledgeTimeout')
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
        % parse Ds1_Command_Retry_Count if property exists
        if isprop(obj,'CommandRetryCount')
           expr=xpath.compile('.//EOParameter[@Name="Ds1_Command_Retry_Count"]');
           result=expr.evaluate(obj.ObjectNode, XPathConstants.NODE);
           if ~isempty(result) % Property value not empty in .ba-file -> parse
               expr=xpath.compile('.//Value/@Value');
               obj.CommandRetryCount=expr.evaluate(result, XPathConstants.STRING); % string
           else % Property value empty in .ba-file -> set default value '0' [s]: No redistribution of group commands
               obj.CommandRetryCount = '0';
           end
        end
        % parse Ds1_Collect_Data_Delay if property exists
        if isprop(obj,'CollectDataDelay')
           expr=xpath.compile('.//EOParameter[@Name="Ds1_Collect_Data_Delay"]');
           result=expr.evaluate(obj.ObjectNode, XPathConstants.NODE);
           if ~isempty(result) % Property value not empty in .ba-file -> parse
               expr=xpath.compile('.//Value/@Value');
               obj.CollectDataDelay=expr.evaluate(result, XPathConstants.STRING); % string
           else % Property value empty in .ba-file -> set default value '0' [s]: No collect data delay
               obj.CollectDataDelay = '0';
           end
        end
        % parse Ds1_Heartbeat_Interval if property exists
        if isprop(obj,'HeartbeatInterval')
           expr=xpath.compile('.//EOParameter[@Name="Ds1_Heartbeat_Interval"]');
           result=expr.evaluate(obj.ObjectNode, XPathConstants.NODE);
           if ~isempty(result) % Property value not empty in .ba-file -> parse
               expr=xpath.compile('.//Value/@Value');
               obj.HeartbeatInterval=expr.evaluate(result, XPathConstants.STRING); % string
           else % Property value empty in .ba-file -> set default minimal allowed value '15' [min]
               obj.HeartbeatInterval = '15';
           end
        end
        %% Stefan 10.10.2013, parse BA_GROUPMEMBER specific properties in a BA_GROUPMEMBER specific method
        if strcmp(obj.ObjectType,'BA_GROUP_MEMBER')
            obj.parseGroupMemberProp;
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
    
    function generateObjectList(obj)
        import javax.xml.xpath.*
        factory = XPathFactory.newInstance;
        xpath = factory.newXPath;
        % XML Object vom Chart File
        xDoc = xmlread(obj.getXmlChartName(obj));
        % Wenn NewArea=1, wird eine neue Area für alle neuen connected Objekte erstellt
        NewArea=0;
        % Wenn Create=1, wird das Objekt erzeugt, ansonstet nicht
        Create=1;
        if isempty(obj.SubList)
            Send2GUI('    ERROR : Es wurde kein AF Object gefunden',obj.h); 
        else
           count = 1;
           %die Sublist wird durchsucht
           for k=1:size(obj.SubList,2)
                exprXML=xpath.compile(['.//FB[@Name="' obj.SubList{3,k} '"]/@Typ']);
                % Chart File nach Sublist Objektnamen durchsuchen
                resultXML=exprXML.evaluate(xDoc, XPathConstants.STRING);
                
                exprBA=xpath.compile(['.//EOParameter[@Name="Object_Identifier"]//Value[@Value="' obj.SubList{2,k} '"]']);
                resultBA=exprBA.evaluate(obj.DocNode, XPathConstants.NODE);
                %[EngineeringObject]
                    
                if ~strcmpi(obj.SubList{3,k},'') && ~strcmpi(obj.SubList{3,k},'~') && strcmpi(obj.SubList{2,k},'4194303')
                    % Subordinate_Annotations enthält Platzhalter für ein
                    % Objekt, welches die Subordinate_List NICHT enthält.
                    % Objekt ist in XML Chart vorhanden
                    % -> Neues Objekt erzeugen
                    % Fall 2
                    
                    if strcmpi(obj.SubList{4,k},'false')
                        % für SubList Elemente = Connected
                        % Neue Area für alle connected Elemente anlegen
                        obj.ObjectList{count}=BA_VN_F;
                        % Objekt = ViewNode Function
                        obj.ObjectList{count}.ObjectType='BA_VN_F';
                        % Platzierungs Ort für neue Area ermitteln
                        SubString=obj.ObjectName;
                        slash=strfind(SubString,'/');
                        TestName=SubString(1:slash);
                        TestName=[TestName 'BA/ConnectedArea'];
                        obj.ObjectList{count}.ObjectName=TestName;
                        % count erhöhen, nächstes Objekt
                        count = count + 1;
                        NewArea=1;
                    else
                        % owned, eine neue Area muss nicht erstellt werden
                        NewArea=0;
                    end
                    if ~isempty(resultXML)
                        % wenn Object Type im Chart gefunden wurde
                        for c=1:size(obj.BAObjTypeNames)
                            if strcmpi(obj.BAObjTypeNames(c,1),resultXML)
                                % Object type Nummer von Regelwerk herauslesen
                                ProtoType=obj.BAObjTypeNames{c,2};
                            end 
                        end
                        if isempty(ProtoType) || ProtoType==0
                            % Wenn nichts im Chart File gefunden, kein Objekt erzeugen
                            Create=0;
                            Send2GUI({...
                            ['    ERROR : Object Type of Object ' obj.SubList{3,k} ' could not be defined'];...
                             '            The Object is not going to be created'} ,obj.h); 
                        else
                            % Objekt Type konnte ermittelt werden, Objekt wird erzeugt
                            Create=1;
                        end
                    else
                        % Subordinate_Annotations enthält Platzhalter für ein
                        % Objekt, welches die Subordinate_List NICHT enthält.
                        % Objekt ist in XML Chart NICHT vorhanden
                        % Fall3
                        if strcmpi(obj.SubList{4,k},'true')
                            Send2GUI({...
                            ['    ERROR : Sublist Object ' obj.SubList{3,k} ' has no valid Object ID'];...
                             '            '} ,obj.h); 
                        end
                        % Kein Objekt erzeugen
                        Create=0; 
                    end     
                elseif isempty(resultBA)
                    % Fall 1
                    % Verweis ist in Subordinate_List vorhanden. Das
                    % Objekt, auf das verwiesen wird, ist jedoch nicht
                    % vorhenden -> es muss erstellt werden
                    
                    Send2GUI({... 
                      '    ERROR : Engineering Object not found. This could be an Error in the *.ba Export File.' ;...
                    [ '            Subordinate List of Object: | ' obj.ObjectName ' | at Position ' num2str(k)   ];...   
                    [ '            BaObjRef.DeviceId : ' obj.SubList{1,k}                                        ];...
                    [ '            BaObjRef.ObjectId : ' obj.SubList{2,k}                                        ];...
                    [ '            Object Name       : ' obj.SubList{3,k}                                        ];...
                    [ '            Valid for Import  : ' obj.SubList{4,k}                                        ]},obj.h);
                    ProtoType = str2double (obj.SubList{2,k});
                    ProtoType = bitand(ProtoType, hex2dec('FFC00000'));
                    ProtoType = bitshift(ProtoType, -22);
                    Create=1;
                else
                    % Normalfall
                    if strcmpi(obj.SubList{4,k},'true')
                        % nur owned Objekte erstellen
                        ObjectNode_v = resultBA.getParentNode.getParentNode.getParentNode.getParentNode;
                        exprBA=xpath.compile('.//EOTypeRef//@Prototype');
                        ProtoType = exprBA.evaluate(ObjectNode_v, XPathConstants.NUMBER);
                        Create=1;
                    else
                        Create=0;
                    end
                end
                if Create == 1
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

                        case{7,8,9,15,16}
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
                        end
                        obj.ObjectList{count}.ObjectName=strcat(obj.ObjectName,'/',obj.SubList{3,k});

                        %% Stefan, 04.10.13: UNDER CONSTRUCTION %%
                        case {29} % SIE_BA_GROUPMASTER = 29 // GrpMaster
                        Send2GUI('    WARNING : Support for BA_GROUP_MASTER (GrpMaster) is currently under construction',obj.h);
                        obj.ObjectList{count}=BA_GROUPMASTER;
                        obj.ObjectList{count}.ObjectType = 'BA_GROUP_MASTER';
                        obj.ObjectList{count}.ObjectName = strcat(obj.ObjectName,'/', obj.SubList{3,k});              

                        % comment the continue statement in order to make the
                        % BA_GROUP_MASTER objects appear in the ObjectList:
                        % continue % Jump to next Iteration
                        %% Stefan, 10.10.13: UNDER CONSTRUCTION %%
                        case {30} % SIE_BA_GROUPMEMBER = 30 // GrpMbr
                        Send2GUI('    WARNING : Support for BA_GROUP_MEMBER (GrpMbr) is currently under construction',obj.h);
                        obj.ObjectList{count}=BA_GROUPMEMBER;
                        obj.ObjectList{count}.ObjectType = 'BA_GROUP_MEMBER';
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

                        case {44} % SIE_BA_VNOBJECTAREA = 44 // AreaView
                        Send2GUI({...
                            '    ERROR : There should be only on AreaView Object (ProtoType 44) in the *.ba File';...
                            '            Proof if there is an Error in the *.ba File'} ,obj.h);
                        continue % Jump to next Iteration      

                        otherwise 
                        Send2GUI({...
                            ['    ERROR : ProtoType ' ProtoType ' not identified'];...
                             '            The ProtoType number is wrong in the *.ba File or not implemented.';...
                             '            Implement the ProtoType in function generateObjectList(obj) in BA_OBJ.m';...
                             '            or write a warning/hint message for it.'} ,obj.h); 
                        continue % Jump to next Iteration
                    end
                    %%
                    if NewArea==1
                        % Bei Erzeugung von fehlenden connected Objekte
                        % muss neue Area erstellt werden
                        obj.ObjectList{count}.ObjectName=[TestName '/' obj.SubList{3,k}];
                    end

                    if  strcmpi(obj.SubList{2,k},'4194303')
                        % Dem neuen Objekt eine identische Objekt ID zuweisen
                        obj.ObjectList{count}.ObjIDRef=BA_OBJ.getUniqueObjID;
                        % Die Objekt ID in der Objekt Liste eintragen
                        obj.SubList{2,k}=obj.ObjectList{count}.ObjIDRef;
                    else
                        obj.ObjectList{count}.ObjIDRef=obj.SubList{2,k};
                    end
                    % passing the handle
                    obj.ObjectList{count}.h=obj.h;
                    % passing the FirmwareLib
                    obj.ObjectList{count}.FWLib=obj.FWLib;
                    % passing the DocNode
                    obj.ObjectList{count}.DocNode=obj.DocNode;
                    % passing the ObjectNode
                    obj.ObjectList{count}.ObjectNode=ObjectNode_v;
                    % passing the ObjectList Position
                    obj.ObjectList{count}.ObjectListPos=count;
                    %aus Sublist mitgeben
                    obj.ObjectList{count}.DevIDRef=obj.SubList{1,k};
                    
                    if not(isempty(obj.ObjectList{count}))
                        obj.ObjectList{count}.parse;
                    end
                  
                    count=count+1;
                end
            end
        end
    end             
end
end