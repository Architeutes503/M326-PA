function createControlMdl_v2(CtrlModelName)

% Load necessary matlab simulink libraries
load_system('simulink');
load_system('ApplFwS1v1_LIB');

%% CREATE SYSTEM

% Create the new System
sys = 'testModel';

%Check if the file already exists and delete it if it does
if exist(sys,'file') == 4
   % If it does then check whether it's open
    if bdIsLoaded(sys)
       % If it is then close it (without saving!)
       close_system(sys,0);
    end
end

new_system(sys) % Create the model
open_system(sys) % Open the model

% Specify 30x30 grid with 30 pixel as standard unit
xStart = 0;
yStart = 0;
size = 30;

xGrid = xStart:size:xStart+size*30;
yGrid = yStart:size:yStart+size*30;

size2 = size/2;
size4 = size/4;
size8 = size/8;

%% ADD BLOCKS

%% Top Level

% IN Input Value 
pos = [xGrid(2) yGrid(5)-size4 xGrid(3) yGrid(5)+size4];
add_block('built-in/Inport',[sys '/InputValuesIN'],'Position',pos)
set_param(gcb,'Interpolate','off')


% IN Object Info
pos = [xGrid(2) yGrid(7)-size4 xGrid(3) yGrid(7)+size4];
add_block('built-in/Inport',[sys '/ObjectInfoIN'],'Position',pos)
set_param(gcb,'Interpolate','off')


% IN Object Info (Output)
pos = [xGrid(2) yGrid(9)-size4 xGrid(3) yGrid(9)+size4];
add_block('built-in/Inport',[sys '/ObjectInfoOUT'],'Position',pos)
set_param(gcb,'Interpolate','off')

% Triggered Subsystem
pos = [xGrid(5) yGrid(4) xGrid(9) yGrid(10)];
add_block('simulink/Ports & Subsystems/Triggered Subsystem',[sys,'/Triggered Subsystem'],'Position',pos);
h = find_system( gcs, ...
    'LookUnderMasks', 'all', ...
    'FindAll', 'on', ...
    'Type', 'line' ) ;
delete_line(h);
delete_block([sys '/Triggered Subsystem/In1'])
delete_block([sys '/Triggered Subsystem/Out1'])

% Edit Trigger Type in Subsystem Function call
set_param([sys,'/Triggered Subsystem/Trigger'],'TriggerType','function-call');

% Add Function Call Generator and set sample time to 0.2 s
pos = [xGrid(2) yGrid(2) xGrid(3) yGrid(3)];
add_block('simulink/Ports & Subsystems/Function-Call Generator',[sys,'/Function-Call Generator'],'Position',pos);
set_param(gcb,'sample_time','0.1') % Set the sample time of the sub system here!

% OUT OutValue 
pos = [xGrid(11) yGrid(7)-size4 xGrid(12) yGrid(7)+size4];
add_block('built-in/Outport',[sys '/OutValues'],'Position',pos)

%% Triggered Subsystem Level

% IN Input Value 
pos = [xGrid(2) yGrid(5)+size2 xGrid(3) yGrid(6)];
add_block('built-in/Inport',[sys '/Triggered Subsystem/InputValuesIN'],'Position',pos)

% IN Object Info
pos = [xGrid(2) yGrid(7)+size4 xGrid(3) yGrid(7)+size4+size2];
add_block('built-in/Inport',[sys '/Triggered Subsystem/ObjectInfoIN'],'Position',pos)

% IN Object Info (Output)
pos = [xGrid(12) yGrid(6) xGrid(13) yGrid(6)+size2];
add_block('built-in/Inport',[sys '/Triggered Subsystem/ObjectInfoOUT'],'Position',pos)

% OUT OutValue 
pos = [xGrid(19) yGrid(9)-size8 xGrid(20) yGrid(9)+size2-size8];
add_block('built-in/Outport',[sys '/Triggered Subsystem/OutValues'],'Position',pos)

% BA_ComInterf
pos = [xGrid(4) yGrid(5) xGrid(8) yGrid(10)];
add_block('ApplFwS1v1_LIB/XFB/BA_ComInterf',[sys '/Triggered Subsystem/BA_ComInterf'],'Position',pos)

% BA_ComInterfOut
pos = [xGrid(14) yGrid(5) xGrid(18) yGrid(10)];
add_block('ApplFwS1v1_LIB/XFB/BA_ComInterf_Out',[sys '/Triggered Subsystem/BA_ComInterf_Out'],'Position',pos)

% Referenced Controlmodel
pos = [xGrid(9) yGrid(3) xGrid(13) yGrid(4)];
add_block('simulink/Ports & Subsystems/Model',[sys '/Triggered Subsystem/Control'],'Position',pos,'ModelName',CtrlModelName)

% Add OoSrv Ba_ComInterf Constant
pos = [xGrid(2) yGrid(9)-size8 xGrid(3) yGrid(9)+size2-size8];
add_block('built-in/Constant',[sys '/Triggered Subsystem/Constant1'],'Position',pos,'Value','0')

% Add OoSrv BA_ComInterf_Out Constant
pos = [xGrid(12) yGrid(8)+size2 xGrid(13) yGrid(9)];
add_block('built-in/Constant',[sys '/Triggered Subsystem/Constant2'],'Position',pos,'Value','0')

% Add Terminators for BA_ComInterf Outputs
% StaFlg
pos = [xGrid(9) yGrid(6) xGrid(10) yGrid(6)+size2];
add_block('built-in/Terminator',[sys '/Triggered Subsystem/T1'],'Position',pos)
% NumObj
pos = [xGrid(9) yGrid(8)+size2 xGrid(10) yGrid(9)];
add_block('built-in/Terminator',[sys '/Triggered Subsystem/T2'],'Position',pos)

% Add Terminators for BA_ComInterf_Out Outputs
% StaFlg
pos = [xGrid(19) yGrid(5)+size2 xGrid(20) yGrid(6)];
add_block('built-in/Terminator',[sys '/Triggered Subsystem/T3'],'Position',pos)
% NumObj
pos = [xGrid(19) yGrid(7)+size4 xGrid(20) yGrid(7)+size4+size2];
add_block('built-in/Terminator',[sys '/Triggered Subsystem/T4'],'Position',pos)

%% ADD LINES
% Top Level
add_line(gcs,'InputValuesIN/1','Triggered Subsystem/1', 'autorouting','on')
add_line(gcs,'ObjectInfoIN/1','Triggered Subsystem/2', 'autorouting','on')
add_line(gcs,'ObjectInfoOUT/1', 'Triggered Subsystem/3', 'autorouting','on')
add_line(gcs,'Function-Call Generator/1','Triggered Subsystem/Trigger', 'autorouting','on')
add_line(gcs,'Triggered Subsystem/1','OutValues/1', 'autorouting','on')

% Triggered Subsystem
add_line([sys,'/Triggered Subsystem'],'InputValuesIN/1','BA_ComInterf/1', 'autorouting','on')
add_line([sys,'/Triggered Subsystem'],'ObjectInfoIN/1','BA_ComInterf/2', 'autorouting','on')
add_line([sys,'/Triggered Subsystem'],'Constant1/1','BA_ComInterf/3', 'autorouting','on')
add_line([sys,'/Triggered Subsystem'],'ObjectInfoOUT/1','BA_ComInterf_Out/1', 'autorouting','on')
add_line([sys,'/Triggered Subsystem'],'Constant2/1','BA_ComInterf_Out/2', 'autorouting','on')
add_line([sys,'/Triggered Subsystem'],'BA_ComInterf/1','T1/1', 'autorouting','on')
add_line([sys,'/Triggered Subsystem'],'BA_ComInterf/2','T2/1', 'autorouting','on')
add_line([sys,'/Triggered Subsystem'],'BA_ComInterf_Out/1','T3/1', 'autorouting','on')
add_line([sys,'/Triggered Subsystem'],'BA_ComInterf_Out/2','T4/1', 'autorouting','on')
add_line([sys,'/Triggered Subsystem'],'BA_ComInterf_Out/3','OutValues/1', 'autorouting','on')



















