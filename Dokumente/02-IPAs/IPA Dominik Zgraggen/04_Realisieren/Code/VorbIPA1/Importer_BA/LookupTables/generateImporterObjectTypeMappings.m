function [BAObjTypeIds,BAObjTypeNames,DefaultBAObjTypeNames] =...
    generateImporterObjectTypeMappings( )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   (C) Copyright by Siemens Schweiz AG, Building Technologies Group,
%       R&D Zug, Comfort Systems, System Applications, 2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Project                     : IMSES
%   Target Hardware             : PC 
%   Target Operating System     : Win7
%   Language/Compiler           : Matlab 2011b and higher 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Workfile                    : generateImporterObjectTypeIds.m
%   Author                      : Stefan Boetschi
%   Version                     : v1.0
%   Date                        : 11.07.2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Matlab Informations
% 
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
%   2014-07-21 17:05 Stefan Boetschi
%   Added the mapping for VN_F objects: 'STR_VIEW' -> 29 (BAObjTypeIds)
%
%   2014-07-14 10:25 Stefan Boetschi
%   Renamed function to generateImporterObjectTypeMappings() and added the
%   mappings for BAObjTypeNames and DefaultBAObjTypeNames
%
%   2014-07-11 08:30 Stefan Boetschi
%   Initial creation
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% In the ABT export MP1.2 the object type is stored in string format. The
% hard coded table below provides a mapping from the object type in string
% format to the numeric object type ID. This object type ID is required by
% the file BA_OBJ.m to compute the object ID.
BAObjTypeIds = {'AVAL' 2;'BVAL' 5;'MVAL' 19;'LGTOA' 260;'LGTOB' 261;...
    'AI' 0;'AO' 1;'BI' 3;'BO' 4;'MI' 13;'MO' 14; 'MTrgVal' 19;...
    'LGTI' 262; 'BLSI' 259; 'BLSO' 258;'PINTVAL' 48; 'STR_VIEW' 29;...
    'GRPMBR' 256; 'GRPMASTER' 257};

% Adapted IPA code by Simon Marty
% Initialize mapping from XFB type to ObjTypeNr and ProtoType
% First entry of cell field: XFB type
% Second entry of cell field: numeric array, [ObjTypeNr; ProtoType]
BAObjTypeNames = {'R_A' [2;2]; 'R_B' [5;5]; 'R_M' [19;8]; 'R_UNSG' [48;17];...
    'R_LGTCMD' [260;NaN];'R_BLSCMD' [258;NaN]; 'R_AX' [2;2];...
    'R_BX' [5;5]; 'R_MX' [19;8]; 'R_LGTX' [262;NaN]; 'R_BLSX' [259;NaN];...
    'W_A' [2;12]; 'W_B' [5;14]; 'W_M' [19;16]; 'CMD_A' [2;2]; 'CMD_B' [5;5];...
    'CMD_M' [19;8]; 'CMD_LGT' [260;NaN]; 'CMD_BLS' [258;NaN]; 'CMD_AX' [2;2]; 'CMD_BX' [5;5];...
    'CMD_MX' [19;8]};

% Adapted IPA code by Simon Marty
% Initialize default mapping from ObjTypeNr to Prototype
% First array entry of cell field: ObjTypeNr
% Second array entry of cell field: ProtoType
DefaultBAObjTypeNames = {[0;1]; [1;3]; [2;2]; [3;4]; [4;6]; [5;5]; [259;NaN]; [258;NaN];...
    [260;NaN]; [261;NaN]; [262;NaN]};

return;

end

