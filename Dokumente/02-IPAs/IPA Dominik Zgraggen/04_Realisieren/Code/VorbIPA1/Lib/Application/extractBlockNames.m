function [xmllink] = extractBlockNames(xmllink,curChartAddress,topChartAddress)
% //-----------------------------------------------------------------------
% //	(C) Copyright Siemens Building Technologies, Inc.  2014
% //-----------------------------------------------------------------------
% //  Project             :  IMSES
% //  Author              :  Stefan Boetschi, stefan.boetschi@siemens.com
% //  Date of creation    :  15-Jul-2014
% //  Workfile            :  extractBlockNames.m
% //-----------------------------------------------------------------------
% //  Description:
% //  M-Function which extracts the actual block names from the link
% //  elements provided in the MP1.2 ABT export.
% //-----------------------------------------------------------------------
% //  Revisions:
% //
% //  - 2014-07-21, Stefan Boetschi:
% //    Bugfix in the handling of ToFBName
% //
% //  - 2014-07-15, Stefan Boetschi:
% //    Initial creation
% //-----------------------------------------------------------------------

for nLNK = 1:numel(xmllink)
    % Check if there is only one link
    if numel(xmllink) == 1
        lnk = xmllink.Attributes;
    else
        lnk = xmllink{nLNK}.Attributes;
    end
    % Prepare FROM block name
    lnk.FromFBName = strrep(lnk.FromFBName,curChartAddress,'');
    % Exception for the top chart
    if ~strcmp(curChartAddress,topChartAddress)
        % Take substring until the first apostrophe as FBName
        lnk.FromFBName = strtok(lnk.FromFBName,'''');
    end
    % If there is an @ delimiter left in the string, take the
    % string part AFTER the @ delimiter as FBName
    if ~isempty(strfind(lnk.FromFBName,'@'))
        tempFromFBName = textscan(lnk.FromFBName,'%s','Delimiter','@');
        lnk.FromFBName = tempFromFBName{1}{end};
    end
    % Exception for the top chart
    if strcmp(curChartAddress,topChartAddress)
        % Take substring until the first apostrophe as FBName
        lnk.FromFBName = strtok(lnk.FromFBName,'''');
    end
    % Prepare TO block name
    % Exception for the top chart
    if ~strcmp(curChartAddress,topChartAddress)
        % Take substring until the first apostrophe as FBName
        lnk.ToFBName = strtok(lnk.ToFBName,'''');
    else
       lnk.ToFBName = strrep(lnk.ToFBName,curChartAddress,''); 
    end
    % If there is an @ delimiter left in the string, take the
    % string part AFTER the @ delimiter as FBName
    if ~isempty(strfind(lnk.ToFBName,'@'))
        tempToFBName = textscan(lnk.ToFBName,'%s','Delimiter','@');
        lnk.ToFBName = tempToFBName{1}{end};
    end
    % Exception for the top chart
    if strcmp(curChartAddress,topChartAddress)
        % Take substring until the first apostrophe as FBName
        lnk.ToFBName = strtok(lnk.ToFBName,'''');
    end
    % Write back to the link structure
    if numel(xmllink) == 1
        xmllink.Attributes.FromFBName = lnk.FromFBName;
        xmllink.Attributes.ToFBName = lnk.ToFBName;
    else
        xmllink{nLNK}.Attributes.FromFBName = lnk.FromFBName;
        xmllink{nLNK}.Attributes.ToFBName = lnk.ToFBName;
    end % END IF
end % END FOR

return;

end % END OF FUNCTION