function [ResultName,ResultValues,ResultFailedNames,ResultFailedValues,ResultFailedSteps]= read_tsneteval(xlsfilename,testcasename)
% read_tsneteval  
%      read_tsneteval reads a generated excel report for a tsnet test and
%      fills the data into containers which are then read and displayed
%      by GUITSNet_Evaluation_final.m.
%
%      INPUTS:
%      xlsfilename          name of the xls(x)-file, where the report is
%                           stored
%      testcasename         name of the xls(x)-sheet, where the report is
%                           stored
%
%      OUTPUTS:
%      ResultName                   ObjectID/PropID of the output objects
%      ResultValues                 Cellarray with data for each testsept
%                                   (conttime,waittime, expected value, measured value, pass/failed string)
%      ResultFailedNames            Name of failed objects
%      ResultFailedValues           failed values
%      ResultFailedSteps            steps which are failed 
%       
%      This function is called by "GUITSNet_Evaluation_final.m" when used with the TSNet
%      Gui.
%
% Changes:
%
% 26-01-2015 Wolfgang Schneider: rewritten for new excel report


clc

%% getting testcase data from xls-file
[num, txt, raw]=xlsread(xlsfilename,testcasename);


%%  Die ObjectID aller Signale holen, die im AuswertungsExcel vorhanden sind
% % Die ObjectID der Signale müssen dabei in der gleichen Zeile sein, wie das
% % Schlüsselwort Results
[XResult,YResult]=getInd(txt,'Results:');                % Index der Zelle mit Inhalt "Results:" holen, auf dieser Zeie sind alle ObjectIDs vermerkt
ResultObjId=raw(YResult,:);                              % Auslesen dieser Zeile
e = cellfun(@(x) strcmp(num2str(x),'NaN'), ResultObjId); % Leere Zellen finden
ResultObjId(e) = [];                                     % Leere Zellen löschen
f = cellfun(@(x) strcmp(x,'Results:'), ResultObjId);     % Results string finden
ResultObjId(f) = [];                                     % Results string flöschen
g = cellfun(@(x) strcmp(x,'ObjectID:'), ResultObjId);    % ObjectID string finden
ResultObjId(g) = [];                                     % ObjectID string löschen

ResultPropID=raw(YResult+1,:);                              % Auslesen dieser Zeile
e = cellfun(@(x) strcmp(num2str(x),'NaN'), ResultPropID);    % Leere Zellen finden
ResultPropID(e) = [];                                        % Leere Zellen löschen
f = cellfun(@(x) strcmp(x,'Property-ID'), ResultPropID);     % Property-ID string finden
ResultPropID(f) = [];                                        % Property-ID string flöschen
  
%% Get time vector
[indXWT,indYWT]=getInd(txt,'Waitingtime'); 

% get maximum y-coordinate
[YMAX,~]=size(raw);

% pre-allocation of waiting time vector
waitTime=zeros(YMAX-indYWT,1);    

for i=1:(YMAX-indYWT)
    % the waiting time vector is a row of numbers in the y-direction, terminated
    % with the first NaN (NaN in the raw of an excel inputs corresponds to
    % an empty cell)

    if isnan(cell2mat(raw(indYWT+i,indXWT)));       
        break;
    end

    waitTime(i,1)=cell2mat(raw(indYWT+i,indXWT));

end

% crop the needed zeros
waitTime(waitTime==0)=[];                           

% convert the waiting time vector to continous time; eventually add catch
% if time isn't a multiplier from 0.1

contTime = zeros(length(waitTime)+1,1);
for i = 2:length(waitTime)+1  
    contTime(i)=contTime(i-1)+waitTime(i-1);
end

contTime=contTime(2:length(contTime));                      %Abschneiden des Wertes 0 - notwendig da sonst die Daten von der Länge und vom Inhalt her nicht übereinstimmen 

for i = 1:length(ResultObjId)
    ResultName{i} = [num2str(ResultObjId{i}),'/',num2str(ResultPropID{i})];
    ExpRes=raw([(YResult+3):(YResult+3)+length(waitTime)-1],(1+i*4));
    Res = raw([(YResult+3):(YResult+3)+length(waitTime)-1],(2+i*4));
    PF = raw([(YResult+3):(YResult+3)+length(waitTime)-1],(3+i*4));
    ResultValues{i}= [num2cell(contTime),num2cell(waitTime),ExpRes,Res,PF];
end

%% Indexieren aller Signale die gefailte Schritte haben
% %Durchsuchen jedes Arrays mit den Values drin nach dem Wert "Failed"
% %Überall wo "Failed" drin steht, wir eine 1 geschrieben, sonst eine 0
% %Über die Summenberechnung wird so festgestellt ob alle Schritte ein
% %Passed haben oder nicht
% %Alle Signale, bei welchen "Failed" gefunden wurde, werden in ein

% % Dient der Unterscheidung im GUI, wo FailedSignals separat angezeigt
% % werden.
index_failed=1;                                         
ResultFailedValues={};
ResultFailedNames={};
for i=1:length(ResultObjId);
    sumtest=sum(sum(strcmp(ResultValues{i},'Failed')));
    if(sumtest>=1);
        ResultFailedValues{index_failed}=ResultValues{i};
        ResultFailedNames{index_failed}=ResultName{i};
        index_failed=index_failed+1;
    end
   
end


%% Ausortieren der gefailten Steps -> Im GUI sollen nur noch die einzelnen Schritte mit einem "Failed"
% %angezeigt werden und nicht mehr alle Schritte eines Signales welches ein
% %Failed enthält
% %ResultFailedValues{i}(YFailedStep,:) holt die entsprechende Zeile raus
ResultFailedSteps={};

for i=1:length(ResultFailedValues)
    [XFailedStep,YFailedStep]=getInd( ResultFailedValues{i}(:,end),'Failed')
    for j=1:1:length(YFailedStep)
        ResultFailedSteps{i}=ResultFailedValues{i}(YFailedStep(j),:);
    end
end



end   % Ende der Funktion
        
        
        
        
        
        
        