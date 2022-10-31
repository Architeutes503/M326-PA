function [simSys,nInOut,block_width] = generateRC_XFB(BaObjRef,blkAttr,blkParam)
% //-----------------------------------------------------------------------
% //	(C) Copyright Siemens Building Technologies, Inc.  2014
% //-----------------------------------------------------------------------
% //  Project             :  IMSES
% //  Author              :  Stefan Boetschi, stefan.boetschi@siemens.com
% //  Date of creation    :  29-Apr-2014
% //  Workfile            :  generateRC_XFB.m
% //  Template files      :  CreateSimulinkTestFrame.m
% //-----------------------------------------------------------------------
% //  Description:
% //  M-Function to be called from ImportChart.m when importing a
% //  Read-Config-Extension XFB block (RC_<x>) into a chart.
% //-----------------------------------------------------------------------
% //  Revisions:
% //  - 2014-06-10, Stefan Boetschi:
% //    Removed units from the config extension parameters
% //
% //  - 2014-05-06, Stefan Boetschi:
% //    Minor improvements in block placement under the mask
% //
% //  - 2014-04-29, Stefan Boetschi:
% //    Initial creation
% //-----------------------------------------------------------------------

%% Isolate NAME, VAR_INPUT and VAR_OUTPUT

NAME = blkAttr.Typ;
nParam = numel(blkParam);
if nParam == 0
    error(['The Read-Config-Extension XFB ',NAME,' contains no parameter information. ',...
        'Please check your ABT export (chart .xml files).']);
elseif nParam == 1
    
else
    % Initialize indices and counters of first input entry and number of
    % properties
    firstInp = 0;
    firstOutp = inf;
    countInp = 0;
    countOutp = 0;
    countPrpy = 0;
    for i=1:nParam
        % Get current parameter struct
        curParam = blkParam{i}.Attributes;
        % Store cell array indices of first input and output
        if strcmp(curParam.Name,'EN')
            firstInp = i+1;
            continue;
        elseif strcmp(curParam.Name,'ENO')
            firstOutp = i+1;
            continue;
        elseif (strcmp(curParam.Name,'CnfExtn'))
            % Do NOT provide CnfExtn and CnfExtnVers as input pins
            CnfExtn = curParam.Value;
            continue;
        elseif (strcmp(curParam.Name,'CnfExtnVers'))
            % Do NOT provide CnfExtn and CnfExtnVers as input pins
			if isfield(curParam,'Value')
				CnfExtnVers = curParam.Value;
			else
				CnfExtnVers = 0;
			end
            continue;
        end % END IF
        % Get input/output information
        if (i >= firstInp && i < firstOutp)
            % Increment input counter
            countInp = countInp + 1;
            % Store information
            VAR_INPUT{countInp} = curParam.Name;
            if isfield(curParam,'Value')
                VAR_INPUT_VAL{countInp} = curParam.Value;
            else 
                VAR_INPUT_VAL{countInp} = '';
            end
            if isfield(curParam,'Invisible')
                VAR_INPUT_INV{countInp} = upper(curParam.Invisible);
            else
               VAR_INPUT_INV{countInp} = ''; 
            end
        elseif (i >= firstOutp)
            % Increment output counter
            countOutp = countOutp + 1;
            % Increment property counter
            if ~(strcmp(curParam.Name,'NumPrpy') || strcmp(curParam.Name,'ReadVld') ||...
                    strcmp(curParam.Name,'ErrCode') || strcmp(curParam.Name,'RErrNr'))
                countPrpy = countPrpy + 1;
            end
            % Store information
            VAR_OUTPUT{countOutp} = curParam.Name;
            if isfield(curParam,'Value')
                VAR_OUTPUT_VAL{countOutp} = curParam.Value;
            else 
                VAR_OUTPUT_VAL{countOutp} = '';
            end
            if isfield(curParam,'Invisible')
                VAR_OUTPUT_INV{countOutp} = upper(curParam.Invisible);
            else
               VAR_OUTPUT_INV{countOutp} = ''; 
            end
        else
            % Should never get here!
            error('');
        end % END IF
    end % END FOR
end % END ELSE

%% Add the override input pins artificially

for i=1:countOutp
   if ~(strcmp(VAR_OUTPUT{i},'NumPrpy') || strcmp(VAR_OUTPUT{i},'ReadVld') ...
           || strcmp(VAR_OUTPUT{i},'ErrCode') || strcmp(VAR_OUTPUT{i},'RErrNr'))
       % Increment input counter
       countInp = countInp + 1;
       % Add override input pin
       VAR_INPUT{countInp} = [VAR_OUTPUT{i},'_Ovrrd'];
   end % END IF
end % END FOR


%% Manipulate input pin order

% Make sure that BaObjRef is the last parameter of the VAR_INPUT list due to
% problems with WP_***,RP_*** blocks
% Wolfgang Schneider 17.10.2013
first=0;    % parameter for setting the BaObjRefPin
BaObjRefPin=length(VAR_INPUT(1,:)); % Default: BaObjRefPin is the last pin
for i=1:length(VAR_INPUT(1,:))
    if strcmp(VAR_INPUT(1,i),'BaObjRef') && i ~= length(VAR_INPUT(1,:)) % if BAObjRef isn't the last pin
        VAR_INPUT(1,i)=VAR_INPUT(1,i+1);                                % switch it with the next pin
        VAR_INPUT(1,i+1)={'BaObjRef'};
        %VAR_INPUT(2,i)=VAR_INPUT(2,i+1);
        %VAR_INPUT(2,i+1)={'STRUCT'};
        if first == 0 
            first = 1;
            BaObjRefPin=i;      % store the position for wiring (pin order is important for S-Function)                    
        end
    end
end

%% Determine number of input and output pins

% Number of input pins
if ( exist('VAR_INPUT') == 0 )
    pIn = 0.5;  
else
    pIn  = length(VAR_INPUT(1,:));
end
% Number of output pins
if ( exist('VAR_OUTPUT') == 0 )
    pOut = 0.5;
else
    pOut  = length(VAR_OUTPUT(1,:));
end

%% Prepare mask generation

% Number of XFB input pins
if pIn==1
    XFBpIn = 0.5;
else
    XFBpIn=pIn-1;
end

% Image width
x_res = 600;
% Side edge
side_edge = 50;
% Upper edge
top_edge = 50;
% Port width
port_width = 20;
% Port height
port_height = port_width/2;
% Subsystem minimum port y-distance
sub_Min_Port_Y_gap = port_height*3;
% Block width
block_width = 200;
% Block height
block_height = max(XFBpIn,pOut) * sub_Min_Port_Y_gap + 40;
% Block width of constants
kblock_width = 180;
% Block height of constants
kblock_height = kblock_width/4;
% Subsystem input port y-distance
% sub_In_Port_Y_gap  = block_height / (XFBpIn);
% Subsystem output port y-distance
sub_Out_Port_Y_gap = block_height / pOut;

%% Open a new model and add a subsystem (temporarily)

% New model
new_system(NAME);
open_system(NAME); % comment this line after debugging!
% Add a subsystem
modelSubSys = strcat(strcat(strcat(NAME,'/') ,NAME),'_'); 
simFB = add_block('built-in/SubSystem',modelSubSys,'Position',[side_edge top_edge side_edge+block_width top_edge+block_height]);

%% Define the subsystem

% Switch mask to on
set_param (simFB, 'Mask', 'on');
% Link the help library
set_param(simFB, 'MaskHelp', sprintf('web([''file:///'' which(''SiemensBuildingLibraryHelp0deDE.chm'')])'));
% Set icon options
set_param (simFB, 'MaskIconOpaque', 'off');
set_param (simFB, 'MaskIconUnits','Normalized');
set_param (simFB, 'MaskIconRotate', 'off');
% Switch drop shadow to on
set_param(simFB, 'DropShadow' , 'on');
% Convert colors to percent [%]
color_R = 224 / 255;
color_G = 224 / 255;
color_B = 232 / 255;
% Set XFB background color (light blue)
set_param(simFB, 'BackgroundColor', 'lightBlue');
% Generate mask dialogue
Variables = [];
for i=1:floor(XFBpIn)*2+floor(pOut) 
    if i <= XFBpIn % input pin checkboxes
        %Prompt(1,i) = strcat(VAR_INPUT (1,i), ': Invisible');
        %Variables = [ Variables sprintf('Invisible_%d=@%d;',i,i)];
        if (length(VAR_INPUT{i})>6 && strcmp(VAR_INPUT{i}(end-6+1:end),'_Ovrrd'))
            Prompt(1,i) = strcat(VAR_INPUT (1,i), ': Visible');
            Variables = [ Variables sprintf('Visible_%d=@%d;',i,i)];
            Callback{i}= sprintf('CallbackRC(%d)',i);            
        else
            Prompt(1,i) = strcat(VAR_INPUT (1,i), ': Invisible');
            Variables = [ Variables sprintf('Invisible_%d=@%d;',i,i)];
            Callback{i}= sprintf('Callback(%d)',i);
        end
        Values{i} = 'off';
        TunableValues{i} = 'off';
        Styles{i} = 'checkbox';
    else
        if i<=XFBpIn+pOut % output pin checkboxes
            j= i-floor(XFBpIn);
            Prompt(1,i) = strcat(VAR_OUTPUT (1,j), ': Invisible');
            Variables = [ Variables sprintf('Invisible_%d=@%d;',i,i)];
            Values{i} = 'off';
            TunableValues{i} = 'off';
            Styles{i} = 'checkbox';
            Callback{i}= sprintf('Callback(%d)',i);
        else % input pin entry fields
            j= i-floor(XFBpIn)-floor(pOut);
            if (length(VAR_INPUT{j})>6 && strcmp(VAR_INPUT{j}(end-6+1:end),'_Ovrrd'))
                % Override pin
                %ovrrideStr = VAR_INPUT{j}(1:end-6);
                Prompt{i} = strcat(VAR_INPUT{j}, ': Default');
                Variables = strcat(Variables, strcat(strcat('Default_',VAR_INPUT{j}),sprintf('=@%d;',i)));
                for k=1:countOutp
                   if (strcmp(VAR_INPUT{j}(1:end-6),VAR_OUTPUT{k}))
                       % 2014-06-10, Stefan Boetschi: Remove units from the
                       % values
                       letterInd = isletter(VAR_OUTPUT_VAL{k});
                       VAR_OUTPUT_VAL{k}(letterInd) = '';
                       Values{i} = VAR_OUTPUT_VAL{k};
                   end % END IF
                end % END FOR
                Callback{i}= sprintf('CallbackRC(%d)',i);
                TunableValues{i} = 'on';
            else
                % Not an override pin
                Prompt(1,i) = strcat(VAR_INPUT (1,j), ': Default');
                Variables = strcat(Variables, strcat(strcat('Default_',VAR_INPUT (1,j)),sprintf('=@%d;',i)));
                Values{i} = '0';
                Callback{i}= sprintf('Callback(%d)',i);
                TunableValues{i} = 'off';
            end % END IF
            Styles{i} = 'edit';
        end
    end
end

i=floor(XFBpIn)*2+floor(pOut)+1;
Prompt{1,i} = 'BaObjRef.DeviceId';
Variables = strcat(Variables, sprintf('DeviceId=@%d;', i));
Values{i} = '4194303';
TunableValues{i}= 'on';
Styles{i} = 'edit';
Callback{i}= '';

i=i+1;
Prompt{1,i} = 'BaObjRef.ObjectId';
Variables = strcat(Variables, sprintf('ObjectId=@%d;',i));
Values{i} = BaObjRef.ObjectId; % Insert the correct ObjectId reference
TunableValues{i}= 'on';
Styles{i} = 'edit';
Callback{i}='';

i=i+1;
Prompt{1,i} = 'BaObjRef.ItemId';
Variables = strcat(Variables, sprintf('ItemId=@%d;',i));
Values{i} = '-1';
TunableValues{i}= 'on';
Styles{i} = 'edit';
Callback{i}= '';

% i=i+1;
% Prompt{1,i} = 'CnfExtn';
% Variables = strcat(Variables, sprintf('CnfExtn=@%d;',i));
% Values{i} = CnfExtn;
% TunableValues{i}= 'off';
% Styles{i} = 'edit';
% Callback{i}= '';
% 
% i=i+1;
% Prompt{1,i} = 'CnfExtnVers';
% Variables = strcat(Variables, sprintf('CnfExtnVers=@%d;',i));
% Values{i} = CnfExtnVers;
% TunableValues{i}= 'off';
% Styles{i} = 'edit';
% Callback{i}= '';
% 
% % Define mask enables
% for k=1:i
%     if (k <= i-2)
%         MaskEnables{k} = 'on';
%     else 
%         MaskEnables{k} = 'off'; % Disable editing of CnfExtn and CnfExtnVers in IMSES
%     end
% end  

Variables = strcat(Variables, '''');
set_param(simFB, 'MaskPrompts', Prompt);
% if pIn==1
    set_param(simFB, 'MaskVariables', Variables);
% else
%     set_param(simFB, 'MaskVariables', Variables{1});
% end
set_param(simFB, 'MaskValues', Values);
set_param(simFB, 'MaskCallbacks', Callback);
set_param(simFB, 'MaskTunableValues', TunableValues);
set_param(simFB, 'MaskStyles', Styles);
% set_param(simFB, 'MaskEnables', MaskEnables);

% Write RC_XFB name to the front side
t = sprintf('plot([0.5,0.5],[0.1,0.9])\ntext(0.5, 0.95,'' %s '', ''HorizontalAlignment'', ''center'')\ntext(0.5,0.05,''CnfExtn: %s / CnfExtnVers: %s'', ''HorizontalAlignment'', ''center'')',...
    NAME,CnfExtn,CnfExtnVers(2:end-1));
set_param (simFB, 'MaskDisplay', t);

%% Add input and output ports to the subsystem

x1 = side_edge;
x2 = x1+port_width;
x3 = x_res - (port_width + side_edge);
x4 = x3+port_width;

% Input
terminatorCount = 0; % Enumerates the terminator blocks
groundCount = 0; % Enumerates the ground blocks
for i=1:XFBpIn
    j=i;
    if i >= BaObjRefPin %>= and not == because i gets reseted after each loop
        j=i+1;
    end
    y1 = ((j-1)* sub_Out_Port_Y_gap )+ top_edge + (sub_Out_Port_Y_gap/2.5);
    y2 = y1+port_height;
    VarName = VAR_INPUT (1,i);
    if (length(VarName{1})>6 && strcmp(VarName{1}(end-6+1:end),'_Ovrrd'))
        for k=1:countOutp
            if (strcmp(VarName{1}(1:end-6),VAR_OUTPUT{k}))
                curValue = VAR_OUTPUT_VAL{k};
            end % END IF
        end % END FOR
        add_block('built-in/Constant', strcat(strcat(modelSubSys,'/'),VarName{1}),'Position', [x1 y1 x2 y2],...
            'Value', curValue, 'SampleTime', '-1' );
    else
        add_block('built-in/Inport', strcat(strcat(modelSubSys,'/'),VarName{1}),'Position', [x1 y1 x2 y2]);
    end
%     % Add Terminator block beside unused input blocks
%     if (strcmp(VarName{1},'CnfExtn') || strcmp(VarName{1},'CnfExtnVers'))
%         term_x1 = x1+40;
%         term_x2 = term_x1+port_width;
%         terminatorCount = terminatorCount + 1;
%         add_block('built-in/Terminator', strcat(strcat(modelSubSys,'/'),['Terminator_',num2str(terminatorCount)]),...
%             'Position', [term_x1 y1 term_x2 y2]);
%         % Wire the blocks
%         oPort = strcat(VarName{1}, '/1');
%         iPort = ['Terminator_',num2str(terminatorCount),'/1'];
%         add_line(modelSubSys,oPort,iPort);
%     end
    
    if j == XFBpIn+1
        break;      % necessary, internal changes of i will be reseted after each loop
    end
end
% Model BaObjRef with three constans
ky1 = y2;
ky2 = ky1 + kblock_height;
kx1 = x1+80;
kx2 = kx1 + kblock_width;
add_block('built-in/Constant', strcat(strcat(modelSubSys,'/'),'Constant4'),'Position', [kx1 ky1 kx2 ky2], 'Value', 'DeviceId', 'SampleTime', '-1' ,'Hide Name','off');
ky1 = ky2+5;
ky2 = ky1 + kblock_height;
add_block('built-in/Constant', strcat(strcat(modelSubSys,'/'),'Constant3'),'Position', [kx1 ky1 kx2 ky2], 'Value', 'ObjectId', 'SampleTime', '-1' ,'Hide Name','off');
ky1 = ky2+5;
ky2 = ky1 + kblock_height;
add_block('built-in/Constant', strcat(strcat(modelSubSys,'/'),'Constant5'),'Position', [kx1 ky1 kx2 ky2], 'Value', 'ItemId', 'SampleTime', '-1' ,'Hide Name','off');
% Add a mux and a terminator block
my1 = y2;
my2 = ky2;
mx1 = kx2+40;
mx2 = mx1+7;
add_block('built-in/Mux', strcat(strcat(modelSubSys,'/'),'Mux'), 'Position', [mx1 my1 mx2 my2], 'Inputs', '3', 'DisplayOption', 'bar');
terminatorCount = terminatorCount + 1;
term_x1 = mx1+40;
term_x2 = term_x1+port_width;
add_block('built-in/Terminator', strcat(strcat(modelSubSys,'/'),['Terminator_',num2str(terminatorCount)]),...
            'Position', [term_x1 my1 term_x2 my2]);
% Place the wires
oPort = 'Constant4/1';
iPort = 'Mux/1';
add_line(modelSubSys, oPort, iPort);
oPort = 'Constant3/1';
iPort = 'Mux/2';
add_line(modelSubSys, oPort, iPort);
oPort = 'Constant5/1';
iPort = 'Mux/3';
add_line(modelSubSys, oPort, iPort);
oPort = 'Mux/1';
iPort = ['Terminator_',num2str(terminatorCount),'/1'];
add_line(modelSubSys, oPort, iPort);

% Output
for i=1:pOut
    y1 = ((i-1)* sub_Out_Port_Y_gap )+ top_edge + (sub_Out_Port_Y_gap/2.5) ;
    y2 = y1+port_height;
    VarName = VAR_OUTPUT (1,i);
    add_block('built-in/Outport',strcat(strcat(modelSubSys,'/'),VarName{1}),'Position', [x3 y1 x4 y2]);
    % Add Ground block beside ErrCode and RErrNr outports
    if (strcmp(VarName{1},'ErrCode') || strcmp(VarName{1},'RErrNr'))
       groundCount = groundCount + 1;
       ground_x3 = x3-40;
       ground_x4 = ground_x3+port_width;
       add_block('built-in/Ground', strcat(strcat(modelSubSys,'/'),['Ground_',num2str(groundCount)]),...
            'Position', [ground_x3 y1 ground_x4 y2]);
        % Wire the blocks
        oPort = ['Ground_',num2str(groundCount),'/1'];
        iPort = strcat(VarName{1}, '/1');
        add_line(modelSubSys,oPort,iPort);
    end
    % Add constant block beside ReadVld outport
    if (strcmp(VarName{1},'ReadVld'))
        const_x3 = x3-40;
        const_x4 = const_x3+port_width;
        add_block('built-in/Constant', strcat(strcat(modelSubSys,'/'),'ConstantReadVld'),'Position', [const_x3 y1 const_x4 y2],...
            'Value', '1', 'SampleTime', '-1' ,'Hide Name','off');
        % Wire the blocks
        oPort = 'ConstantReadVld/1';
        iPort = strcat(VarName{1}, '/1');
        add_line(modelSubSys,oPort,iPort);
    end
    % Add constant block beside NumPrpy outport
    if (strcmp(VarName{1},'NumPrpy'))
        const_x3 = x3-40;
        const_x4 = const_x3+port_width;
        add_block('built-in/Constant', strcat(strcat(modelSubSys,'/'),'ConstantNumPrpy'),'Position', [const_x3 y1 const_x4 y2],...
            'Value', num2str(countPrpy), 'SampleTime', '-1' ,'Hide Name','off');
        % Wire the blocks
        oPort = 'ConstantNumPrpy/1';
        iPort = strcat(VarName{1}, '/1');
        add_line(modelSubSys,oPort,iPort);
    end
end

% Place the feedthrough wires from Inports to Outports
for i=1:pOut
    VarName = VAR_OUTPUT (1,i);
    if ~(strcmp(VarName{1},'NumPrpy') || strcmp(VarName{1},'ReadVld') ||...
                    strcmp(VarName{1},'ErrCode') || strcmp(VarName{1},'RErrNr'))
     oPort = [VarName{1},'_Ovrrd','/1'];
     iPort = [VarName{1},'/1'];
     add_line(modelSubSys,oPort,iPort);
    end
end

% Return the number of inputs and outputs
nInOut = [countInp countOutp];

% Return also the model name
simSys = modelSubSys;

end

