function [xmllink] = removeInterChartLinks(xmllink,xmlinterface)
% //-----------------------------------------------------------------------
% //	(C) Copyright Siemens Building Technologies, Inc.  2014
% //-----------------------------------------------------------------------
% //  Project             :  IMSES
% //  Author              :  Stefan Boetschi, stefan.boetschi@siemens.com
% //  Date of creation    :  15-Jul-2014
% //  Workfile            :  removeInterChartLinks.m
% //-----------------------------------------------------------------------
% //  Description:
% //  M-Function which removes interchart links from the link structure
% //  parsed from the chart file (.xml). These interchart links are not
% //  taken into account when dissolving algebraic loop.
% //-----------------------------------------------------------------------
% //  Revisions:
% //
% //  - 2014-07-15, Stefan Boetschi:
% //    Initial creation
% //-----------------------------------------------------------------------

% Initialize array containing link indices to be deleted
delLinkNum = [];
% Iterate over all the links
for nLNK = 1:numel(xmllink)
    % Check if there is only one link
    if numel(xmllink) == 1
        lnk = xmllink.Attributes;
    else
        lnk = xmllink{nLNK}.Attributes;
    end
    % Iterate over the chart interface
    for nINT = 1:numel(xmlinterface)
        % Check if there is only one interface pin
        if numel(xmlinterface) == 1
            int = xmlinterface.Attributes;
        else
            int = xmlinterface{nINT}.Attributes;
        end
        % Compare name of interface pin and link TO/FROM pin
        if (strcmp(int.Name,lnk.FromPin) || ...
                strcmp(int.Name,lnk.ToPin))
            delLinkNum = [delLinkNum;nLNK];
            break;
        end
    end % END FOR
end % END FOR
% Delete interchart links from the xmllink structure
delInd = ismember(1:1:numel(xmllink),delLinkNum);
xmllink(delInd) = [];

return;

end % END OF FUNCTION