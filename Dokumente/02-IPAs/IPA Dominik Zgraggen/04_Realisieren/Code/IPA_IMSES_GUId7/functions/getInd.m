function [xInd,yInd]=getInd(txt,string)
% getInd  
%      getInd  searches 'txt' for 'string' and returns its x and y coordinates.
%      If the text appears more than once, every coordinate pair will be
%      returned.
%
%      INPUTS:
%      txt                  txt import of an excel testcase sheet
%      string               string which has to be found
%
%      OUTPUTS:
%      xInd                 x coordinate of string
%      yInd                 y coordinate of string 
%       
%      This function is called by "tsnet_test_v1" when used with the TSNet
%      Gui.
%
% Changes:
%
% 14-01-2015 Wolfgang Schneider: Clearer Error Handling
%
% 11-12-2014 Wolfgang Schneider: merge Joonas, Johan, Michael, Wolfgangs
% work to one TSNet-Gui
% 13-12-2013 Michael Lüthy
% Anpassen der Funktion alle Indexes ausgegeben werten mit diesen Werten

% search txt for string
try
    if iscell(string)
        match =   ~cellfun(@isempty,strfind(txt,string{1}));
        str=string{1};
    else
        match =   ~cellfun(@isempty,strfind(txt,string));
        str=string;
    end
    
    [yInd,xInd] = find(match);
    
    %Make sure, only exact appearances are found
    k=0;
    for i=1:size(yInd)
        if ~strcmp(txt{yInd(i-k),xInd(i-k)},str)
            yInd(i-k)=[];
            xInd(i-k)=[];
            k=k+1;
        end
    end
catch
    % no Errordlg(needed)
end

end %of function