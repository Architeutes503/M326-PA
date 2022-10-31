classdef BA_LOOP < BA_OBJ
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   (C) Copyright by Siemens Schweiz AG, Building Technologies Group,
    %       R&D Zug, Comfort Systems, System Applications, 2014
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   Project                     : IMSES
    %   Target Hardware             : PC
    %   Target Operating System     : MS Windows 7
    %   Language/Compiler           : Matlab R2011b
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   Workfile                    : BA_LOOP.m
    %   Author                      : Stefan Boetschi
    %   Version                     : v1.0
    %   Date                        : 05.08.2014
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  Revision History
    % 	(Put meaningful comments in SourceSafe for log below!)
    % 	(Please remove blank lines and very old comments!)
    %
    %   2013-10-11 08:45 Stefan Boetschi
    %   Initial creation
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        
        Yctl
        CtrlType
        CtrlState
        CtrlMode
        Rlb
        OoSrv
        WritePrio
        Yctlmax
        Yctlmin
        Yofs
        OutputUnits
        ManipVarRef
        Xctl
        CtrldVarUnits
        CtrldVarRef
        Sp
        Actgtyp
        Gain
        PropConstUnit
        RiseTime
        FallTime
        NumStages
        SwitchDelay
        HysOff
        HysOn
        NeutralZone
        DiffUnits
        Tn
        IntConstUnits
        Tv
        DerivConstUnits
        
    end
    
    methods
        
        function parseLoopProp(obj)
            %% XPath settings
            import javax.xml.xpath.*
            factory = XPathFactory.newInstance;
            xpath = factory.newXPath;
            %% Parse properties
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
            % Read the XML file and get a node to the BA-Loop
            xDoc = xmlread([obj.FilePath '\' obj.FileName]);
            expr = xpath.compile('.//Entity');
            entity = expr.evaluate(xDoc,XPathConstants.NODE);
            % parse Yctl
            expr = xpath.compile('.//Property[@Name="Yctl"]/@Value');
            result = expr.evaluate(entity,XPathConstants.STRING);
            if ~isempty(result)
                obj.Yctl = result;
            end
            % parse Ds1_Controller_Type
            expr = xpath.compile('.//Property[@Name="Ds1_Controller_Type"]/@Value');
            result = expr.evaluate(entity,XPathConstants.STRING);
            if ~isempty(result)
                obj.CtrlType = result;
            else
                Send2GUI({
                    [ '    ERROR : Could not find the controller type information for BA-Loop-Object in the ABT export.'     ];...
                    [ '            Please add the corresponding value manually to the block mask of the object.'    ];...
                    [ '            BaObjRef.DeviceId : ' obj.DevIDRef                                   ];...
                    [ '            BaObjRef.ObjectId : ' obj.ObjIDRef                                   ];...
                    [ '            Object Name       : ' obj.ObjectName];},obj.h);
            end
            % parse Ds1_Controller_State
            expr = xpath.compile('.//Property[@Name="Ds1_Controller_State"]/@Value');
            result = expr.evaluate(entity,XPathConstants.STRING);
            if ~isempty(result)
                obj.CtrlState = result;
            end
            % parse Ds1_Controller_Mode
            expr = xpath.compile('.//Property[@Name="Ds1_Controller_Mode"]/@Value');
            result = expr.evaluate(entity,XPathConstants.STRING);
            if ~isempty(result)
                obj.CtrlMode = result;
            end
            % parse Reliability
            expr = xpath.compile('.//Property[@Name="Reliability"]/@Value');
            result = expr.evaluate(entity,XPathConstants.STRING);
            if ~isempty(result)
                obj.Rlb = result;
            else
                Send2GUI({
                    [ '    ERROR : Could not find the reliability information for BA-Loop-Object in the ABT export.'     ];...
                    [ '            Please add the corresponding value manually to the block mask of the object.'    ];...
                    [ '            BaObjRef.DeviceId : ' obj.DevIDRef                                   ];...
                    [ '            BaObjRef.ObjectId : ' obj.ObjIDRef                                   ];...
                    [ '            Object Name       : ' obj.ObjectName];},obj.h);
            end
            % parse OoSrv
            expr = xpath.compile('.//Property[@Name="Out_Of_Service"]/@Value');
            result = expr.evaluate(entity,XPathConstants.STRING);
            if ~isempty(result)
                if strcmpi(result,'true')
                    obj.OoSrv = '1';
                else
                    obj.OoSrv = '0';
                end
            else
                Send2GUI({
                    [ '    ERROR : Could not find the out-of-service information for BA-Loop-Object in the ABT export.'     ];...
                    [ '            Please add the corresponding value manually to the block mask of the object.'    ];...
                    [ '            BaObjRef.DeviceId : ' obj.DevIDRef                                   ];...
                    [ '            BaObjRef.ObjectId : ' obj.ObjIDRef                                   ];...
                    [ '            Object Name       : ' obj.ObjectName];},obj.h);
            end
            % parse Priority_For_Writing
            expr = xpath.compile('.//Property[@Name="Priority_For_Writing"]/@Value');
            result = expr.evaluate(entity,XPathConstants.STRING);
            if ~isempty(result)
                obj.WritePrio = result;
            end
            % parse Yctlmax (= max. output)
            expr = xpath.compile('.//Property[@Name="Yctlmax"]/@Value');
            result = expr.evaluate(entity,XPathConstants.STRING);
            if ~isempty(result)
                obj.Yctlmax = result;
            else
                Send2GUI({
                    [ '    ERROR : Could not find the max. output (= Yctlmax) information for BA-Loop-Object in the ABT export.'     ];...
                    [ '            Please add the corresponding value manually to the block mask of the object.'    ];...
                    [ '            BaObjRef.DeviceId : ' obj.DevIDRef                                   ];...
                    [ '            BaObjRef.ObjectId : ' obj.ObjIDRef                                   ];...
                    [ '            Object Name       : ' obj.ObjectName];},obj.h);
            end
            % parse Yctlmin (= min. output)
            expr = xpath.compile('.//Property[@Name="Yctlmin"]/@Value');
            result = expr.evaluate(entity,XPathConstants.STRING);
            if ~isempty(result)
                obj.Yctlmin = result;
            else
                Send2GUI({
                    [ '    ERROR : Could not find the min. output (= Yctlmin) information for BA-Loop-Object in the ABT export.'     ];...
                    [ '            Please add the corresponding value manually to the block mask of the object.'    ];...
                    [ '            BaObjRef.DeviceId : ' obj.DevIDRef                                   ];...
                    [ '            BaObjRef.ObjectId : ' obj.ObjIDRef                                   ];...
                    [ '            Object Name       : ' obj.ObjectName];},obj.h);
            end
            % parse Yofs = Bias
            expr = xpath.compile('.//Property[@Name="Yofs"]/@Value');
            result = expr.evaluate(entity,XPathConstants.STRING);
            if ~isempty(result)
                obj.Yofs = result;
            else
                Send2GUI({
                    [ '    ERROR : Could not find the bias (= YCtrOfs) information for BA-Loop-Object in the ABT export.'     ];...
                    [ '            Please add the corresponding value manually to the block mask of the object.'    ];...
                    [ '            BaObjRef.DeviceId : ' obj.DevIDRef                                   ];...
                    [ '            BaObjRef.ObjectId : ' obj.ObjIDRef                                   ];...
                    [ '            Object Name       : ' obj.ObjectName];},obj.h);
            end
            % parse Output_Units
            expr = xpath.compile('.//Property[@Name="Output_Units"]/@Value');
            result = expr.evaluate(entity,XPathConstants.STRING);
            if ~isempty(result)
                obj.OutputUnits = result;
            end
            % parse Manipulated_Variable_Reference
            expr = xpath.compile('.//Property[@Name="Manipulated_Variable_Reference"]/@Value');
            result = expr.evaluate(entity,XPathConstants.STRING);
            if ~isempty(result)
                obj.ManipVarRef = result;
            end
            % parse Xctl
            expr = xpath.compile('.//Property[@Name="Xctl"]/@Value');
            result = expr.evaluate(entity,XPathConstants.STRING);
            if ~isempty(result)
                obj.Xctl = result;
            end
            % parse Controlled_Variable_Units
            expr = xpath.compile('.//Property[@Name="Controlled_Variable_Units"]/@Value');
            result = expr.evaluate(entity,XPathConstants.STRING);
            if ~isempty(result)
                obj.CtrldVarUnits = result;
            end
            % parse Controlled_Variable_Reference
            expr = xpath.compile('.//Property[@Name="Controlled_Variable_Reference"]/@Value');
            result = expr.evaluate(entity,XPathConstants.STRING);
            if ~isempty(result)
                obj.CtrldVarRef = result;
            end
            % parse Sp
            expr = xpath.compile('.//Property[@Name="Sp"]/@Value');
            result = expr.evaluate(entity,XPathConstants.STRING);
            if ~isempty(result)
                obj.Sp = result;
            end
            % parse Actgtyp
            expr = xpath.compile('.//Property[@Name="Actgtyp"]/@Value');
            result = expr.evaluate(entity,XPathConstants.STRING);
            if ~isempty(result)
                obj.Actgtyp = result;
            end
            % parse Gain = PropConst
            expr = xpath.compile('.//Property[@Name="Gain"]/@Value');
            result = expr.evaluate(entity,XPathConstants.STRING);
            if ~isempty(result)
                obj.Gain = result;
            else
                Send2GUI({
                    [ '    ERROR : Could not find the gain (= prop. constant) information for BA-Loop-Object in the ABT export.'     ];...
                    [ '            Please add the corresponding value manually to the block mask of the object.'    ];...
                    [ '            BaObjRef.DeviceId : ' obj.DevIDRef                                   ];...
                    [ '            BaObjRef.ObjectId : ' obj.ObjIDRef                                   ];...
                    [ '            Object Name       : ' obj.ObjectName];},obj.h);
            end
            % parse Proportional_Constant_Units
            expr = xpath.compile('.//Property[@Name="Proportional_Constant_Units"]/@Value');
            result = expr.evaluate(entity,XPathConstants.STRING);
            if ~isempty(result)
                obj.PropConstUnit = result;
            end
            % parse Ds1_Rise_Time
            expr = xpath.compile('.//Property[@Name="Ds1_Rise_Time"]/@Value');
            result = expr.evaluate(entity,XPathConstants.STRING);
            if ~isempty(result)
                obj.RiseTime = result;
            else
                Send2GUI({
                    [ '    ERROR : Could not find the rise time information for BA-Loop-Object in the ABT export.'     ];...
                    [ '            Please add the corresponding value manually to the block mask of the object.'    ];...
                    [ '            BaObjRef.DeviceId : ' obj.DevIDRef                                   ];...
                    [ '            BaObjRef.ObjectId : ' obj.ObjIDRef                                   ];...
                    [ '            Object Name       : ' obj.ObjectName];},obj.h);
            end
            % parse Ds1_Fall_Time
            expr = xpath.compile('.//Property[@Name="Ds1_Fall_Time"]/@Value');
            result = expr.evaluate(entity,XPathConstants.STRING);
            if ~isempty(result)
                obj.FallTime = result;
            else
                Send2GUI({
                    [ '    ERROR : Could not find the fall time information for BA-Loop-Object in the ABT export.'     ];...
                    [ '            Please add the corresponding value manually to the block mask of the object.'    ];...
                    [ '            BaObjRef.DeviceId : ' obj.DevIDRef                                   ];...
                    [ '            BaObjRef.ObjectId : ' obj.ObjIDRef                                   ];...
                    [ '            Object Name       : ' obj.ObjectName];},obj.h);
            end
            % parse Ds1_Number_Of_Stages
            expr = xpath.compile('.//Property[@Name="Ds1_Number_Of_Stages"]/@Value');
            result = expr.evaluate(entity,XPathConstants.STRING);
            if ~isempty(result)
                obj.NumStages = result;
            else
                Send2GUI({
                    [ '    ERROR : Could not find the number of stages information for BA-Loop-Object in the ABT export.'     ];...
                    [ '            Please add the corresponding value manually to the block mask of the object.'    ];...
                    [ '            BaObjRef.DeviceId : ' obj.DevIDRef                                   ];...
                    [ '            BaObjRef.ObjectId : ' obj.ObjIDRef                                   ];...
                    [ '            Object Name       : ' obj.ObjectName];},obj.h);
            end
            % parse Ds1_Switch_Delay
            expr = xpath.compile('.//Property[@Name="Ds1_Switch_Delay"]/@Value');
            result = expr.evaluate(entity,XPathConstants.STRING);
            if ~isempty(result)
                obj.SwitchDelay = result;
            else
                Send2GUI({
                    [ '    ERROR : Could not find the switch delay information for BA-Loop-Object in the ABT export.'     ];...
                    [ '            Please add the corresponding value manually to the block mask of the object.'    ];...
                    [ '            BaObjRef.DeviceId : ' obj.DevIDRef                                   ];...
                    [ '            BaObjRef.ObjectId : ' obj.ObjIDRef                                   ];...
                    [ '            Object Name       : ' obj.ObjectName];},obj.h);
            end
            % parse Ds1_Hysteresis_Off
            expr = xpath.compile('.//Property[@Name="Ds1_Hysteresis_Off"]/@Value');
            result = expr.evaluate(entity,XPathConstants.STRING);
            if ~isempty(result)
                obj.HysOff = result;
            else
                Send2GUI({
                    [ '    ERROR : Could not find the hysteresis off information for BA-Loop-Object in the ABT export.'     ];...
                    [ '            Please add the corresponding value manually to the block mask of the object.'    ];...
                    [ '            BaObjRef.DeviceId : ' obj.DevIDRef                                   ];...
                    [ '            BaObjRef.ObjectId : ' obj.ObjIDRef                                   ];...
                    [ '            Object Name       : ' obj.ObjectName];},obj.h);
            end
            % parse Ds1_Hysteresis_On
            expr = xpath.compile('.//Property[@Name="Ds1_Hysteresis_On"]/@Value');
            result = expr.evaluate(entity,XPathConstants.STRING);
            if ~isempty(result)
                obj.HysOn = result;
            else
                Send2GUI({
                    [ '    ERROR : Could not find the hysteresis on information for BA-Loop-Object in the ABT export.'     ];...
                    [ '            Please add the corresponding value manually to the block mask of the object.'    ];...
                    [ '            BaObjRef.DeviceId : ' obj.DevIDRef                                   ];...
                    [ '            BaObjRef.ObjectId : ' obj.ObjIDRef                                   ];...
                    [ '            Object Name       : ' obj.ObjectName];},obj.h);
            end
            % parse Ds1_Neutral_Zone
            expr = xpath.compile('.//Property[@Name="Ds1_Neutral_Zone"]/@Value');
            result = expr.evaluate(entity,XPathConstants.STRING);
            if ~isempty(result)
                obj.NeutralZone = result;
            else
                Send2GUI({
                    [ '    ERROR : Could not find the neutral zone information for BA-Loop-Object in the ABT export.'     ];...
                    [ '            Please add the corresponding value manually to the block mask of the object.'    ];...
                    [ '            BaObjRef.DeviceId : ' obj.DevIDRef                                   ];...
                    [ '            BaObjRef.ObjectId : ' obj.ObjIDRef                                   ];...
                    [ '            Object Name       : ' obj.ObjectName];},obj.h);
            end
            % parse Ds1_Differential_Units
            expr = xpath.compile('.//Property[@Name="Ds1_Differential_Units"]/@Value');
            result = expr.evaluate(entity,XPathConstants.STRING);
            if ~isempty(result)
                obj.DiffUnits = result;
            end
            % parse Tn = IntConst
            expr = xpath.compile('.//Property[@Name="Tn"]/@Value');
            result = expr.evaluate(entity,XPathConstants.STRING);
            if ~isempty(result)
                obj.Tn = result;
            else
                Send2GUI({
                    [ '    ERROR : Could not find the integral constant (= Tn) information for BA-Loop-Object in the ABT export.'     ];...
                    [ '            Please add the corresponding value manually to the block mask of the object.'    ];...
                    [ '            BaObjRef.DeviceId : ' obj.DevIDRef                                   ];...
                    [ '            BaObjRef.ObjectId : ' obj.ObjIDRef                                   ];...
                    [ '            Object Name       : ' obj.ObjectName];},obj.h);
            end
            % parse Tv = DerivConst
            expr = xpath.compile('.//Property[@Name="Tv"]/@Value');
            result = expr.evaluate(entity,XPathConstants.STRING);
            if ~isempty(result)
                obj.Tv = result;
            else
                Send2GUI({
                    [ '    ERROR : Could not find the derivative constant (= Tv) information for BA-Loop-Object in the ABT export.'     ];...
                    [ '            Please add the corresponding value manually to the block mask of the object.'    ];...
                    [ '            BaObjRef.DeviceId : ' obj.DevIDRef                                   ];...
                    [ '            BaObjRef.ObjectId : ' obj.ObjIDRef                                   ];...
                    [ '            Object Name       : ' obj.ObjectName];},obj.h);
            end
            % parse Integral_Constant_Units
            expr = xpath.compile('.//Property[@Name="Integral_Constant_Units"]/@Value');
            result = expr.evaluate(entity,XPathConstants.STRING);
            if ~isempty(result)
                obj.IntConstUnits = result;
            end
            % parse Derivative_Constant_Units
            expr = xpath.compile('.//Property[@Name="Derivative_Constant_Units"]/@Value');
            result = expr.evaluate(entity,XPathConstants.STRING);
            if ~isempty(result)
                obj.DerivConstUnits = result;
            end
            
        end % END OF METHOD: parseLoopProp
        
        function generate(obj, ObjList)
            
            %% Write block information to file ObjectList.txt
            tabs = char (9 * ones (1, (length (strfind (obj.ObjectName, '/')) - 1)));
            name = obj.ObjectName(find(obj.ObjectName=='/',1,'last')+1 : length(obj.ObjectName));
         
            fwrite(ObjList, sprintf('%s%s\t%s\t%s\t%s\n', tabs, name, obj.ObjIDRef, obj.DevIDRef, obj.ObjectType));
            
            %% Try to add block (copy from the Firmware Library)
            try
                % 2014-08-05, Stefan Boetschi: Handle the exception when
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
                add_block([obj.FWLib '/BA_OBJECT/BA_LOOP_'],obj.ObjectName,'Position',getPos(obj.ObjectName));
            catch ME
                Send2GUI(['    ERROR : ' ME.message],obj.h);
            end
            
            %% Configure block
            % Object identifier, Device identifier
            set_param(obj.ObjectName,'DeviceId',obj.DevIDRef,'ObjectId',obj.ObjIDRef);
            % Default value for out of service flag
            set_param(obj.ObjectName,'DefOutOfService',obj.OoSrv);
            % Reliability
            set_param(obj.ObjectName,'Rlb',obj.Rlb);
            % Proportional Constant (= Gain)
            set_param(obj.ObjectName,'PropConst',obj.Gain);
            % Integral Constant (= Tn)
            set_param(obj.ObjectName,'IntConst',obj.Tn);
            % Derivative Constant (= Tv)
            set_param(obj.ObjectName,'DerivConst',obj.Tv);
            % Neutral Zone
            set_param(obj.ObjectName,'NeutralZone',obj.NeutralZone);
            % Rise Time
            set_param(obj.ObjectName,'RiseTime',obj.RiseTime);
            % Fall Time
            set_param(obj.ObjectName,'FallTime',obj.FallTime);
            % Bias (= YctrOfs)
            set_param(obj.ObjectName,'IntConst',obj.Yofs);
            % Controller Type
            set_param(obj.ObjectName,'ControllerType',obj.CtrlType);
            % Hysteresis On
            set_param(obj.ObjectName,'HysteresisOn',obj.HysOn);
            % Hysteresis Off
            set_param(obj.ObjectName,'HysteresisOff',obj.HysOff);
            % Switch Delay
            set_param(obj.ObjectName,'SwitchDelay',obj.SwitchDelay);
            % Max. Output (= Yctlmax)
            set_param(obj.ObjectName,'MaxOutput',obj.Yctlmax);
            % Max. Output (= Yctlmin)
            set_param(obj.ObjectName,'MinOutput',obj.Yctlmin);
            % Number of stages
            set_param(obj.ObjectName,'NumOfSts',obj.NumStages);          
            
            
        end % END OF METHOD: generate
        
    end % END OF METHODS
    
end % END OF CLASSDEF
