function generateNestedChartInterface(xml,system,parentSystem)
% //-----------------------------------------------------------------------
% //	(C) Copyright Siemens Building Technologies, Inc.  2014
% //-----------------------------------------------------------------------
% //  Project             :  IMSES
% //  Author              :  Stefan Boetschi, stefan.boetschi@siemens.com
% //  Date of creation    :  29-Apr-2014
% //  Workfile            :  generateNestedChartInterface.m
% //-----------------------------------------------------------------------
% //  Description:
% //  M-Function to be called from ImportXML.m after having imported all
% //  charts and nested charts in the application. This function adds
% //  constant blocks and connects them to corresponding subsystems if
% //  necessary.
% //-----------------------------------------------------------------------
% //  Revisions:
% //
% //  - 2014-06-24, Stefan Boetschi:
% //    Initial creation
% //-----------------------------------------------------------------------

% Check if the nested chart has an interface
if isfield(xml,'Interface')
    % Get position of the current subsystem
    pos = get_param(system, 'Inport');
    for nInterface = 1 : numel(xml.Interface)
        % Get current interface pin information
        if numel (xml.Interface) == 1
            curInterface = xml.Interface.Attributes;
        else
            curInterface = xml.Interface{nInterface}.Attributes;
        end
        % Get the name of the current interface pin
        curName = curInterface.Name;
        % Prepare the value of the current interface pin
        curValue = curInterface.Value;
        letterInd = isletter(curValue);
        curValue = curValue(~letterInd);
        % Get the subsystem port number of the current interface pin
        try
            curPortNum = str2num(get_param([system '/' curName],'Port')); %#ok<ST2NM>
            % Get the port numbers of all the unlinked interface pins
            lineHandles = get_param(system,'LineHandles');
            unlinkedPorts = lineHandles.Inport == -1;
            % Check if the current interface pin is unlinked
            if (unlinkedPorts(curPortNum))
                % Add a constant block with the correct value
                simConst = 0;
                %
                try
                    if ischar(curValue)
                        simConst = add_block(...
                            'built-in/Constant', ...
                            [parentSystem '/Const'], ...
                            'MakeNameUnique','on', ...
                            'Value',['[' curValue ']'], ...
                            'Position',[pos(curPortNum,1)-100 pos(curPortNum,2)-7 pos(curPortNum,1)+15-80 pos(curPortNum,2)+15-7], ...
                            'ShowName','off', ...
                            'SampleTime', '-1');
                    else
                        simConst = add_block(...
                            'built-in/Constant', ...
                            [parentSystem '/Const'], ...
                            'MakeNameUnique','on', ...
                            'Value',['[' sprintf('%d ',curValue) ']'], ...
                            'Position',[pos(curPortNum,1)-100 pos(curPortNum,2)-7 pos(curPortNum,1)+15-80 pos(curPortNum,2)+15-7], ...
                            'ShowName','off', ...
                            'SampleTime', '-1');
                    end
                    portConst = get_param(simConst,'PortHandles');
                    portFB    = get_param(system,'PortHandles');
                    add_line(parentSystem,portConst.Outport(1),portFB.Inport(curPortNum),'autorouting','on');
                catch %#ok<CTCH>
                    if (simConst ~= 0)
                        delete_block(simConst)
                    end
                end
                %
            end % END IF
        catch %#ok<CTCH>
            % Just don't add the constant if an error occured
        end
    end % END FOR: Interface
end % END IF

end % END OF FUNCTION