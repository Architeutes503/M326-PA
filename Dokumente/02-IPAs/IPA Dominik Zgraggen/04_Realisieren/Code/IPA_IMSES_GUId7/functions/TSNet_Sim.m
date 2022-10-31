function [TSNetTestStruct, ErrState]=TSNet_Sim(TSNetTestStruct)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TSNet_Sim  
%      TSNet_Sim manages the simulation part of the TSNet Test
%
%      INPUTS
%      TSNetTestStruct      Struct with TSNet Test Data
%
%      OUTPUTS:
%      TSNetTestStruct      Struct with TSNet Test Data
%
%      This function is called by "TSNet_Test.m" when called
%      through the TSNet Gui.
%
% CHANGES:
% 14-01-2015 // Created by Wolfgang Schneider (rework of tsnet_test_v1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load System
try
    load_system(TSNetTestStruct.MdlName);
    ErrState = 0;
catch
   ErrState = GuiConstants.CtrMdl_LoadErr;
   return
end

SampleTime=0.1;

set_param(gcs, 'SimulationMode','Normal'); %Assure that the simulation mode is set to normal


%% Generate Input Vector
% Object Info Input

ObjInfoIN=zeros(1,length(TSNetTestStruct.InputObj)*3);

for i=1:length(TSNetTestStruct.InputObj)
    ObjInfoIN((i-1)*3+1)=TSNetTestStruct.InputObj(i).ObjTypeNr;   % Object Type Number
    ObjInfoIN((i-1)*3+2)=TSNetTestStruct.InputObj(i).ObjID;       % Object ID
    ObjInfoIN((i-1)*3+3)=TSNetTestStruct.InputObj(i).PropID;      % Object Property ID
end

% Object Info Output
ObjInfoOUT=zeros(1,length(TSNetTestStruct.OutputObj)*3);

for i=1:length(TSNetTestStruct.OutputObj)
    ObjInfoOUT((i-1)*3+1)=TSNetTestStruct.OutputObj(i).ObjTypeNr;   % Object Type Number
    ObjInfoOUT((i-1)*3+2)=TSNetTestStruct.OutputObj(i).ObjID;       % Object ID
    ObjInfoOUT((i-1)*3+3)=TSNetTestStruct.OutputObj(i).PropID;      % Object Property ID
end

% Inputvalues

InputValues=[];
for i=1:length(TSNetTestStruct.InputObj)
    InputValues=[InputValues, TSNetTestStruct.InputObj(i).EnableT', TSNetTestStruct.InputObj(i).Prio, TSNetTestStruct.InputObj(i).Value'];
end

% generate input matrix

MatrixRWTimeSize=ones(length(TSNetTestStruct.RWTime(1:end-1)),1);
u=[TSNetTestStruct.RWTime(1:end-1), InputValues, MatrixRWTimeSize*ObjInfoIN, MatrixRWTimeSize*ObjInfoOUT];
%Input =    SimTime             ,    InputWrite, [ObjTypeNr, ObjID,PropID],  [ObjTypeNr, ObjID,PropID]

% set options
options=[];

%% set input port dimensions
[~,n]=size(InputValues);

set_param([gcs,'/InputValuesIN'],'PortDimensions',num2str(n));
set_param([gcs,'/ObjectInfoIN'],'PortDimensions',num2str(length(ObjInfoIN)));
set_param([gcs,'/ObjectInfoOUT'],'PortDimensions',num2str(length(ObjInfoOUT)));



%% Save state before simulation
TSNetTestStruct.SimIn.u=u;
TSNetTestStruct.SimIn.MaxTime=max(TSNetTestStruct.RWTime);
TSNetTestStruct.SimIn.options=options;

% Save to folder
save('TSNetTestStruct.mat','TSNetTestStruct');

%% Simulation
try 
    warning off;
    [t,x,y] = sim(gcs,[0,TSNetTestStruct.SimIn.MaxTime],TSNetTestStruct.SimIn.options,TSNetTestStruct.SimIn.u);
    warning on;
    ErrState = 0;
catch exp
    ErrState = GuiConstants.SimRunErr;    
    save_system(gcs);
    close_system(gcs);
    return
end

% Save and Close
save_system(gcs);
close_system(gcs);

%% Store Outputs

TSNetTestStruct.SimOut.t=t;
TSNetTestStruct.SimOut.y=y;

% Save to folder
save('TSNetTestStruct.mat','TSNetTestStruct');
end %FUNCTION