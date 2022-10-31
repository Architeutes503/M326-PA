function ObjConnector ()

    [RoomModel, PathName,FilterIndex] = uigetfile( ...
            { '*.mdl','Models (*.mdl)'}, ... % Filterdefinition
            'Pick the ABT Control Model');
    RoomModel = strrep(RoomModel, '.mdl', '');    
    load_system ([PathName RoomModel]);

    [SimModel, PathName,FilterIndex] = uigetfile( ...
            { '*.mdl','Models (*.mdl)'}, ... % Filterdefinition
            'Pick the Simulation Model');
    SimModel = strrep(SimModel, '.mdl', '');
    load_system ([PathName SimModel]);    

    
    CollView = find_system(RoomModel, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'BlockType', 'S-Function', 'FunctionName', 'BA_VN_C_S1_SL');
    l_CollView = length(CollView);
    tmp = find_system(SimModel, 'FollowLinks', 'on', 'LookUnderMasks', 'all', 'BlockType', 'S-Function');

    i = 1;
    for n=1:length(tmp)
        fn = get_param (tmp(n), 'FunctionName');
            if ~isempty (strfind (fn{1}, 'BA_'))
                BAObjects{i,1} = tmp{n};
       
                a = strfind(BAObjects{i,1}, '/');
                al = length(a);
                BAObjects{i,2} = BAObjects{i,1}(a(al-1)+1:a(al)-1);       
                BAObjects{i,3} = BAObjects{i,1}(1:a(al)-1);       
                i = i + 1;
            end
    end

    for n=1:l_CollView
        a = strfind(CollView{n,1}, '/');
        al = length(a);
        CollView{n,2} = CollView{n,1}(a(al-1)+1:a(al)-1);
        CollView{n,3} = CollView{n,1}(1:a(al)-1);
    end

    out = 'Es wurden keine Objekte an eine Collection View verbunden.';

    [l_BA n] = size(BAObjects);
    for n=1:l_BA
        for i=1:l_CollView
            if ~isempty(strfind(BAObjects{n,2}, CollView{i,2}))
                ObjId = str2num(get_param (BAObjects{n,3}, 'ObjectId'));
                DevId = str2num(get_param (BAObjects{n,3}, 'DeviceId'));
            
                ItemObjId = str2num(get_param (CollView{i,3}, 'ItemObjectId'));
                ItemDevId = str2num(get_param (CollView{i,3}, 'ItemDeviceId'));

                avail = false;            
                l_item = length(ItemObjId);
                for m=1:l_item
                    if (ItemObjId(m) == ObjId) && (ItemDevId(m) == DevId)
                        avail = true;
                    end
                end
            
                if (avail == false)
                    if ((ItemObjId(1) == 4194303) && (ItemDevId(1) == 4194303))
                        ItemObjId(1) = ObjId;
                        ItemDevId(1) = DevId;                    
                    else
                        ItemObjId(l_item+1) = ObjId;
                        ItemDevId(l_item+1) = DevId;
                    end
                    ItemDevId = num2str(ItemDevId);
                    ItemDevId = [ '[' ItemDevId ']' ];
                    set_param (CollView{i,3}, 'ItemDeviceId', ItemDevId);
                
                    ItemObjId = num2str(ItemObjId);
                    ItemObjId = [ '[' ItemObjId ']' ];
                    set_param (CollView{i,3}, 'ItemObjectId', ItemObjId);
               
                    out = '';
                    disp (['   ' BAObjects{n,3} ' wurde mit der Collection View ' CollView{i,3} ' verbunden.']);
                end
            end
        end
    end

    disp(out);
    close_system ([PathName SimModel]);    
    save_system (RoomModel);
    close_system ([PathName RoomModel]);
end