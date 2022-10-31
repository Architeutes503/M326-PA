function [propList] = generateImporterPropertyList( )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   (C) Copyright by Siemens Schweiz AG, Building Technologies Group,
%       R&D Zug, Comfort Systems, System Applications, 2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Project                     : IMSES
%   Target Hardware             : PC 
%   Target Operating System     : Win7
%   Language/Compiler           : Matlab 2011b and higher 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Workfile                    : generateImporterPropertyList.m
%   Author                      : Stefan Boetschi
%   Version                     : v1.0
%   Date                        : 09.07.2014
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
%   2014-07-16 11:45 Stefan Boetschi
%   Switch to the MP1.2 document version
%   SDU_BAObjectsAndProperties_S1-Room-Ctl_20140704.xls
%
%   2014-07-11 08:00 Stefan Boetschi
%   Transformed code into a function and renamed as
%   generaterImporterPropertyList.m
%
%   2014-07-09 16:30 Stefan Boetschi
%   Initial creation
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Read list of BACnet property ids and corresponding property descriptions
% from the file SDU_BAObjectsAndProperties_S1-Room-Ctl_20140704.xls
% IMPORTANT NOTE: the functionality implemented below possibly requires
% adaptation if a more recent document version (.xls) is to be used.
% The most recent document version (.xls) can be found under the following
% link: \\CH021013.ww020.siemens.net\LIBSETS\Templates and others\
% SDU Export System ONE\SDU_BAObjectsAndProperties_S1-Room-Ctl_<DATESTAMP>.xls


if (exist('propList.mat','file'))
    load('propList.mat');
else
    % Source file name (.xls)
    propList.sourceFile =...
        'SDU_BAObjectsAndProperties_S1-Room-Ctl_20140704.xls';
    % Read the columns "BACnet Property-ID" and "BA-Property Description" from
    % the source file
    if (exist(propList.sourceFile,'file'))
        [propList.rawPropIds,~,~,] = xlsread(propList.sourceFile,'Data','H:H');
        [~,propList.rawPropDescr,~] = xlsread(propList.sourceFile,'Data','K:K');
        propList.rawPropDescr = propList.rawPropDescr(2:end); % Remove column header

        % Select only the unique entries
        [~,uniqueInd,~] = unique(propList.rawPropIds);
        propList.propIds = propList.rawPropIds(uniqueInd);
        propList.propDescr = propList.rawPropDescr(uniqueInd);

        % Prepare the folder path in order to save the data
        savePath = which(propList.sourceFile);
        pathInd = strfind(savePath,'\');
        pathInd = pathInd(end);
        savePath = savePath(1:pathInd-1);

        % Remove raw data from the structure
        propList = rmfield(propList,{'rawPropIds' 'rawPropDescr' 'sourceFile'});

        % Save the data in a .mat file
        save([savePath '\propList.mat'],'propList');
    else
        % Error: could not find the Excel file containing the property list
        % -> Return an empty array
        propList = [];
    end
end

return;

end

