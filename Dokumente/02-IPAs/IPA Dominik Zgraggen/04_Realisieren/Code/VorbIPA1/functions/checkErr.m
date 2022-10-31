function checkErr(ErrState, handles, hwaitbar)
    switch ErrState       
        case {GuiConstants.NoError}
            set(handles.txt_SimState, 'String', '...');
        case {GuiConstants.TsNet_ReadErr}
            set(handles.txt_SimState, 'String', 'TsNet: Read Error!');
            delete(hwaitbar)
            error('TsNet: Read Error!');
        case {GuiConstants.TsNet_Keywords}
            set(handles.txt_SimState, 'String', 'Could not find Keywords in TsNet!');
            delete(hwaitbar)
            error('Could not find Keywords in TsNet!');
        case  {GuiConstants.SimRunErr}
            set(handles.txt_SimState, 'String', 'Simulation failed!');
            delete(hwaitbar)
            error('Simulation failed!');
        case {GuiConstants.Report_WriteErr}
            set(handles.txt_SimState, 'String', 'Could not write to Report-File');
            delete(hwaitbar)
            error('Could not write to Report-File');
        otherwise
            set(handles.txt_SimState, 'String', 'unknown Error!');
            delete(hwaitbar)
            error('unknown Error');
    end
end

