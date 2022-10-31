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
   end
   methods
    function parse(obj)
        import javax.xml.xpath.*
        factory = XPathFactory.newInstance;
        xpath = factory.newXPath; 
		% Initial Parsing when running first time
        %% parsing ObjectNode wenn noch nicht vorhanden
        if isempty(obj.ObjectNode)
            expr   = xpath.compile('.//EOTypeRef[@Prototype="44"]');
            result = expr.evaluate(obj.DocNode, XPathConstants.NODE);
            obj.ObjectNode=result.getParentNode.getParentNode;    
        end
        %% parsing ObjectName wenn noch nicht vorhanden
        if isempty(obj.ObjectName)
            expr=xpath.compile('.//ShortDescription/@Value');
            obj.ObjectName=expr.evaluate(obj.ObjectNode, XPathConstants.STRING);
            obj.ObjectName=[obj.ObjectName '/BA'];
        end    
        %% parsing ObjIDRef wenn noch nicht vorhanden
        if isempty(obj.ObjIDRef)
            expr=xpath.compile('.//EOParameter[@Name="Object_Identifier"]//Value/@Value');
            obj.ObjIDRef=expr.evaluate(obj.ObjectNode, XPathConstants.STRING);
        end
        %% parsing Number of States wenn property NumOfStates vorhanden
        if isprop(obj,'NumOfStates')
            expr=xpath.compile('.//EOParameter[@Name="Number_Of_States"]//Value/@Value');
            obj.NumOfStates=expr.evaluate(obj.ObjectNode, XPathConstants.STRING);    
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

        if isempty(obj.SubList)
            Send2GUI('    ERROR : Es wurde kein AF Object gefunden',obj.h); 
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
                expr=['.//EOParameter[@Name="Object_Identifier"]//Value[@Value="' obj.SubList{2,k} '"]'];
                expr=xpath.compile(expr);
                result=expr.evaluate(obj.DocNode, XPathConstants.NODE);
                %[EngineeringObject]
                if isempty(result)
                    Send2GUI({... 
                    [ '    ERROR : Engineering Object not found. This could be an Error in the *.ba Export File.'];...
                    [ '            Subordinate List of Object: | ' obj.ObjectName ' | at Position ' num2str(k)   ];...   
                    [ '            BaObjRef.DeviceId : ' obj.SubList{1,k}                                        ];...
                    [ '            BaObjRef.ObjectId : ' obj.SubList{2,k}                                        ];...
                    [ '            Object Name       : ' obj.SubList{3,k}                                        ];...
                    [ '            Valid for Import  : ' obj.SubList{4,k}                                        ]},obj.h);
                    continue % Jump to next Iteration
                end
                ObjectNode = result.getParentNode.getParentNode.getParentNode.getParentNode;
                expr=xpath.compile('.//EOTypeRef//@Prototype');
                ProtoType = expr.evaluate(ObjectNode, XPathConstants.NUMBER);
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

                case {29} % SIE_BA_GROUPMASTER = 29 // GrpMaster
                    %%% NOT SUPPORTED YET%%%%
                    Send2GUI('    ERROR : BA_GROUPMASTER (GrpMaster) is not supported yet',obj.h);
                continue % Jump to next Iteration

                case {30} % SIE_BA_GROUPMEMBER = 30 // GrpMbr
                    %%% NOT SUPPORTED YET%%%%
                    Send2GUI('    ERROR : BA_GROUPMEMBER (GrpMbr) is not supported yet',obj.h);
                continue % Jump to next Iteration

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
                        ['    ERROR : There should be only on AreaView Object (ProtoType 44) in the *.ba File'];...
                        ['            Proof if there is an Error in the *.ba File']} ,obj.h);
                    continue % Jump to next Iteration      

                otherwise   
                    Send2GUI({...
                        ['    ERROR : ProtoType ' ProtoType ' not identified'];...
                        ['            The ProtoType number is wrong in the *.ba File or not implemented.'];...
                        ['            Implement the ProtoType in function generateObjectList(obj) in BA_OBJ.m'];...
                        ['            or write a warning/hint message for it.']} ,obj.h); 
                    continue % Jump to next Iteration

                end
                % passing the handle
                obj.ObjectList{count}.h=obj.h;
                % passing the FirmwareLib
                obj.ObjectList{count}.FWLib=obj.FWLib;
                % passing the DocNode
                obj.ObjectList{count}.DocNode=obj.DocNode;
                % passing the ObjectNode
                obj.ObjectList{count}.ObjectNode=ObjectNode;
                % passing the ObjectList Position
                obj.ObjectList{count}.ObjectListPos=count;
                %aus Sublist mitgeben
                obj.ObjectList{count}.DevIDRef=obj.SubList{1,k};
                obj.ObjectList{count}.ObjIDRef=obj.SubList{2,k};

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