function checkErr(ErrState, handles, hwaitbar)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% checkErr 
%   checkErr evaluate the State of the Simulation process, if there is
%   an Error, it aborts the Simulation and gives a Message to GUI.
%   
%   This function gets called by TSNet_Test.m after every Step
%
%   INPUTS
%  - ErrState  is the Value of the Simulation Error handling (see also 
%     GuiConstants)
%  - handles  structure with handles and user data (see GUIDATA)
%  - hwaitbar  Object to show the Simulation process to the User 
%
% CHANGES:
% 10-04-2015 // Dominik Zgraggen, 5559 - Creation for IPA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    switch ErrState       
        case {GuiConstants.NoError}
            set(handles.txt_State, 'String', GuiConstants.ErrOK);
            
        case {GuiConstants.TsNet_ReadErr} % in TSNet_Import() -> xlsread
            set(handles.txt_State, 'String', GuiConstants.ErrRead);
            delete(hwaitbar)
            error(GuiConstants.ErrRead);
            
        case {GuiConstants.TsNet_Keywords} % in TSNet_Import() -> getInd
            set(handles.txt_State, 'String', GuiConstants.ErrKeyW);
            delete(hwaitbar)
            error(GuiConstants.ErrKeyW);
            
        case {GuiConstants.CtrMdl_LoadErr} % TSNet_Sim() -> load_system
            set(handles.txt_State, 'String', GuiConstants.ErrLoadCtrMdl);
            delete(hwaitbar)
            error(GuiConstants.ErrLoadCtrMdl);    
            
        case  {GuiConstants.SimRunErr}  % in TSNet_Sim() -> sim
            set(handles.txt_State, 'String', GuiConstants.ErrSim);
            delete(hwaitbar)
            error(GuiConstants.ErrSim);
            
        case {GuiConstants.Report_WriteErr} % in TSNet_Report() -> xlswrite
            set(handles.txt_State, 'String', GuiConstants.ErrRep);
            delete(hwaitbar)
            error(GuiConstants.ErrRep);
            
        otherwise
            set(handles.txt_State, 'String', GuiConstants.ErrUnkown);
            delete(hwaitbar)
            error(GuiConstants.ErrUnkown);
    end
end

