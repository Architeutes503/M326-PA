function [TSNetTestStruct, ErrState] = TSNet_Import(TSNetTestStruct)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TSNet_Import  
%      TSNet_Import extracts all Information which is needed for
%      simulation and evaluation of a TSNet Test from an Excel Test sheet
%
%      INPUTS
%      XLSName              Name of the excel file with the TSnet test
%      SheetName            Name of the excel sheet with the testcase
%
%      OUTPUTS:
%      TSNetTest            Struct with TSNet Test Information
%
%      This function is called by "TSNet_Test" when called
%      through the TSNet Gui.
%
% CHANGES:
% 14-01-2015 // Created by Wolfgang Schneider (rework of tsnet_test_v1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
NULLCONSTANT= 32767;
ALLCONSTANT = 18; % constant to write if prio is All


%% Read Excel Sheet 
% txt: only text information. raw: everything, blank cells are converted
% to "NaN"

    
try
    % Read the testcase sheet to txt (only txt data) and raw (everything)
    % for changing cell names 
    [~, txt, raw]=xlsread(TSNetTestStruct.XLSName,TSNetTestStruct.SheetName);
    ErrState = 0;
catch 
    ErrState = GuiConstants.TsNet_ReadErr;
    return
end


%% Find coordinates of keywords
try 
        % template version 0.7, adjust this for newer template versions 

        [indXWT,indYWT]=getInd(txt,{['Waitingtime' char(10) 'after Inputs'];});
        [indXIn,~]=getInd(txt,{'In';});
        [indXOut,~]=getInd(txt,{'Out';});
        [indXEnd,~]=getInd(txt,{'End';});
        [~,indYPrio]=getInd(txt,{'Priority (Number / All / empty)';});
        [~,indYPropID]=getInd(txt,{'Property-ID';});
        [~,indYObjID]=getInd(txt,{'Object-ID';});
        [~,indYObjType]=getInd(txt,{'Objecttype';});
        [indXStep, indYStep]=getInd(txt, {['Action', char(10),'*Comment is mandatory*'];});
        indYTSD=3; % Test step description
        ErrState = 0;        
catch 
   ErrState = GuiConstants.TsNet_Keywords;
   return
end

%% Get time vector

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
TSNetTestStruct.RWTime = zeros(length(waitTime)+1,1);               

for i = 2:length(waitTime)+1  
    TSNetTestStruct.RWTime(i)=TSNetTestStruct.RWTime(i-1)+waitTime(i-1);
end

%% Extract Input Objects Info

TL=length(TSNetTestStruct.RWTime); % Length of the time vector

for i=1:(indXOut-indXIn-1)
    
    % Extract Identification Information
    TSNetTestStruct.InputObj(i).Name      =        cell2mat(raw(indYTSD,indXIn+i));
    TSNetTestStruct.InputObj(i).ObjTypeNr =        cell2mat(raw(indYObjType,indXIn+i));
    TSNetTestStruct.InputObj(i).ObjID     =        cell2mat(raw(indYObjID,indXIn+i));
    TSNetTestStruct.InputObj(i).PropID    =        cell2mat(raw(indYPropID,indXIn+i));
    
    % Extract Priority of the Column
    prioval=cell2mat(raw(indYPrio,indXIn+i));
        
    if (strcmpi(prioval,'all')|| strcmpi(prioval,'All'))
        prioval = ALLCONSTANT; 
    end % IF
    
    TSNetTestStruct.InputObj(i).Prio = ones(TL-1,1)*prioval;
    
    % Extract Values
    
    tmp = raw((indYWT+1):(indYWT+TL-1),indXIn+i);
    TSNetTestStruct.InputObj(i).Dimension = 1;
    
    for j=1:TL-1;
        
        if isnan(tmp{j}) % Empty Cell
            
            TSNetTestStruct.InputObj(i).EnableT(j) = -1;
            TSNetTestStruct.InputObj(i).Value(:,j)   = -1*ones(TSNetTestStruct.InputObj(i).Dimension,1);
        
        elseif  isnumeric(tmp{j}) % Numerical Value
            
            TSNetTestStruct.InputObj(i).EnableT(j) = TSNetTestStruct.RWTime(j);
            TSNetTestStruct.InputObj(i).Value(j)   = tmp{j};

            
        elseif  ischar(tmp{j}) % Char Value
            
            if ((strcmp(tmp{j},'Null')|| strcmp(tmp{j},'NULL')) || strcmp(tmp{j},'null')) % Null Value
                
                TSNetTestStruct.InputObj(i).EnableT(j) = TSNetTestStruct.RWTime(j);
                TSNetTestStruct.InputObj(i).Value(:,j)   = NULLCONSTANT*ones(TSNetTestStruct.InputObj(i).Dimension,1); 
                
            elseif ~isempty(textscan(tmp{j},'%s')) % Values in vector format
                
                    TSNetTestStruct.InputObj(i).EnableT(j) = TSNetTestStruct.RWTime(j);
                    
                    elements=textscan(tmp{j},'%s'); % Searches for whitespaces and split text
                    str=elements{1,1}; 
               
                   for k=1:length(str)
                        TSNetTestStruct.InputObj(i).Value(k,j)=str2num(str{k}); 
                   end
                   
                   if TSNetTestStruct.InputObj(i).Dimension== 1
                       TSNetTestStruct.InputObj(i).Dimension=length(str);
                   end
                
            elseif ((strcmp(tmp{j},'true')) || (strcmp(tmp{j},'WAHR')))  % BOOL True
                
                TSNetTestStruct.InputObj(i).EnableT(j) = TSNetTestStruct.RWTime(j);
                TSNetTestStruct.InputObj(i).Value(j)   = 1;                
                
            elseif ((strcmp(tmp{j},'false')) || (strcmp(tmp{j},'FALSCH')))  % BOOL False
                
                TSNetTestStruct.InputObj(i).EnableT(j) = TSNetTestStruct.RWTime(j);
                TSNetTestStruct.InputObj(i).Value(j)   = 0;     
                
            else
                
                % Shouldn't go here
                disp('Char Value couldn''t be parsed');                
            end % IF     
        else            
            % Shouldn't go here
            disp('Value couldn''t be parsed');                
        end % IF            
    end  %FOR     
end % FOR

% Merge vectors for same ObjID/PropID but different Priorities
for i=1:length(TSNetTestStruct.InputObj) 
    
        count=0; % Variable for working with reduced size of BAObj struct array
        
        for j=(i+1):(length(TSNetTestStruct.InputObj)) %all remaining BAObjects

            % If two objects have identical object and property ID, they can be merged
            if TSNetTestStruct.InputObj(i).ObjID == TSNetTestStruct.InputObj(j-count).ObjID && TSNetTestStruct.InputObj(i).PropID == TSNetTestStruct.InputObj(j-count).PropID 

                for k=1:TL-1 % Iterate over Values vector of BAObject

                    if TSNetTestStruct.InputObj(i).Prio(k) > TSNetTestStruct.InputObj(j-count).Prio(k) && ~(TSNetTestStruct.InputObj(j-count).EnableT(k)==-1); % If priority of second object is lower and writing is enabled, overwrite... 
                        TSNetTestStruct.InputObj(i).Value(:,k) = TSNetTestStruct.InputObj(j-count).Value(:,k);  % (k,:) for vector support
                        TSNetTestStruct.InputObj(i).Prio(k)   = TSNetTestStruct.InputObj(j-count).Prio(k);
                        TSNetTestStruct.InputObj(i).EnableT(k) = TSNetTestStruct.InputObj(j-count).EnableT(k);
                    elseif ~((TSNetTestStruct.InputObj(j-count).EnableT(k)==-1)) && (TSNetTestStruct.InputObj(i).EnableT(k)==-1) % If other object has higher prio, but is enabled and this object is not enabled, overwrite...
                        TSNetTestStruct.InputObj(i).Value(:,k) = TSNetTestStruct.InputObj(j-count).Value(:,k);
                        TSNetTestStruct.InputObj(i).Prio(k)   = TSNetTestStruct.InputObj(j-count).Prio(k);
                        TSNetTestStruct.InputObj(i).EnableT(k) = TSNetTestStruct.InputObj(j-count).EnableT(k);
                    end

                end

                TSNetTestStruct.InputObj(j-count)=[]; % delete of struct array j, which is included now in struct array i
                count=count+1; %+1 of t, to account for the now shorter struct (if we delete element 5, we have to compare to the "new" element 5 in the next iteration. j changes to 6, so we need to have a j-t=6-1..

            end

        end

        if length(TSNetTestStruct.InputObj)==i
            break;
        end

end % Merge Vectors

% Replace Null Values, add Null-Flag to its values
for i = 1:length(TSNetTestStruct.InputObj) 
	for j=1:TL-1
		for k=1:TSNetTestStruct.InputObj(i).Dimension
			if TSNetTestStruct.InputObj(i).Value(k,j) == 32767
				TSNetTestStruct.InputObj(i).Value(k,j) = 0; 
				TSNetTestStruct.InputObj(i).Prio(j) = bitor(TSNetTestStruct.InputObj(i).Prio(j), 256); % 256 = 0x100, this is Null-Flag
				break;
			end
		end
	end
end

%% Extract Output Objects Info

for i=1:(indXEnd-indXOut-1)
    
    % Extract Identification Information
    TSNetTestStruct.OutputObj(i).Name      =        raw(indYTSD,indXOut+i);
    TSNetTestStruct.OutputObj(i).ObjTypeNr =        cell2mat(raw(indYObjType,indXOut+i));
    TSNetTestStruct.OutputObj(i).ObjID     =        cell2mat(raw(indYObjID,indXOut+i));
    TSNetTestStruct.OutputObj(i).PropID    =        cell2mat(raw(indYPropID,indXOut+i));
    
    % Extract Values
    
    tmp = raw(indYWT+1:(indYWT+TL-1),indXOut+i);
    TSNetTestStruct.OutputObj(i).Dimension = 1;
    
    for j=1:TL-1;
        
        if isnan(tmp{j}) % Empty Cell
            TSNetTestStruct.OutputObj(i).EnableT(j) = -1;
            TSNetTestStruct.OutputObj(i).LowerValue(:,j)   = -1*ones(TSNetTestStruct.OutputObj(i).Dimension,1);
            TSNetTestStruct.OutputObj(i).UpperValue(:,j)   = -1*ones(TSNetTestStruct.OutputObj(i).Dimension,1);   
        
        elseif  isnumeric(tmp{j}) % Numerical Value
            
            TSNetTestStruct.OutputObj(i).EnableT(j) = TSNetTestStruct.RWTime(j+1)-0.2; % Read is done WTtime(i)-0.2 seconds after input is written
            TSNetTestStruct.OutputObj(i).LowerValue(j)   = tmp{j};
            TSNetTestStruct.OutputObj(i).UpperValue(j)   = tmp{j};
            
        elseif  ischar(tmp{j}) % Char Value
            
            if strcmp(tmp{j},'Null') % Null Value
                
                TSNetTestStruct.OutputObj(i).EnableT(j) = TSNetTestStruct.RWTime(j+1)-0.2; % Read is done WTtime(i)-0.2 seconds after input is written
                TSNetTestStruct.OutputObj(i).LowerValue(:,j)   = NULLCONSTANT*ones(TSNetTestStruct.OutputObj(i).Dimension,1);
                TSNetTestStruct.OutputObj(i).UpperValue(:,j)   = NULLCONSTANT*ones(TSNetTestStruct.OutputObj(i).Dimension,1);   
                
            elseif ~isempty(textscan(tmp{j},'%s')) % Values in vector format
                
                TSNetTestStruct.OutputObj(i).EnableT(j) = TSNetTestStruct.RWTime(j+1)-0.2; % Read is done WTtime(i)-0.2 seconds after input is written
                    
                if ~isempty(strfind(tmp{j},'.')) % Vector with intervall
                    elements=textscan(tmp{j},'%s'); % Searches for whitespaces and split text
                    str=elements{1,1};                     
                    for k=1:length(str)
                        nums=textscan(str{k},'%f %*[..] %f');
                        TSNetTestStruct.OutputObj(i).LowerValue(k,j)=nums{1};
                        TSNetTestStruct.OutputObj(i).UpperValue(k,j)=nums{2};                        
                    end 
                    
                   if TSNetTestStruct.OutputObj(i).Dimension== 1
                       TSNetTestStruct.OutputObj(i).Dimension=length(str);
                   end
                    
                else % Normal Vector
                    elements=textscan(tmp{j},'%s'); % Searches for whitespaces and split text
                    str=elements{1,1}; 
               
                   for k=1:length(str)
                        TSNetTestStruct.OutputObj(i).LowerValue(k,j)=str2num(str{k}); 
                        TSNetTestStruct.OutputObj(i).UpperValues(k,j)=str2num(str{k});  
                   end
                   
                   if TSNetTestStruct.OutputObj(i).Dimension == 1
                       TSNetTestStruct.OutputObj(i).Dimension=length(str);
                   end
                end
                
            elseif ~isempty(strfind(tmp{j},'.')) % Intervall format
                
                TSNetTestStruct.OutputObj(i).EnableT(j) = TSNetTestStruct.RWTime(j+1)-0.2; % Read is done WTtime(i)-0.2 seconds after input is written
                nums=textscan(tmp{j},'%f %*[..] %f');
                TSNetTestStruct.OutputObj(i).LowerValue(j)=nums{1};
                TSNetTestStruct.OutputObj(i).UpperValue(j)=nums{2};                     
                
            elseif ((strcmp(tmp{j},'true')) || (strcmp(tmp{j},'WAHR')))  % BOOL True
                
                TSNetTestStruct.OutputObj(i).EnableT(j) = TSNetTestStruct.RWTime(j+1)-0.2; % Read is done WTtime(i)-0.2 seconds after input is written
                TSNetTestStruct.OutputObj(i).LowerValue(j)=1;
                TSNetTestStruct.OutputObj(i).UpperValue(j)=1;                
                
            elseif ((strcmp(tmp{j},'false')) || (strcmp(tmp{j},'FALSCH')))  % BOOL False
                
                TSNetTestStruct.OutputObj(i).EnableT(j) = TSNetTestStruct.RWTime(j+1)-0.2; % Read is done WTtime(i)-0.2 seconds after input is written
                TSNetTestStruct.OutputObj(i).LowerValue(j)=0;
                TSNetTestStruct.OutputObj(i).UpperValue(j)=0;           
                
            else                      
                disp('Char Value couldn''t be parsed');                
            end % IF     
        else            
            % Shouldn't go here
            disp('Value couldn''t be parsed');                
        end % IF            
    end  %FOR     
end % FOR


%% Get Teststepdescription

TSNetTestStruct.TestStepDesc=cell(TL-1,1);

for i=1:(TL-1)
    TSNetTestStruct.TestStepDesc{i}=cell2mat(raw(indYStep+i,indXStep));
end

% Save to folder
save('TSNetTestStruct.mat','TSNetTestStruct');


end % FUNCTION