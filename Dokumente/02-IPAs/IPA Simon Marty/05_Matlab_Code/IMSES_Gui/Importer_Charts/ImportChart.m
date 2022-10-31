function [Errors] = ImportChart (xml, system, libTRA, h, BaObjRef)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   (C) Copyright by Siemens Schweiz AG, Building Technologies Group,
%       HVAC Products, 2012
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Project                     : IMSES
%   Target Hardware             : PC 
%   Target Operating System     : WinXP Console
%   Language/Compiler           : Matlab 2010 and higher 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Workfile                    : ImportChart.m
%   Author                      : Thomas Weiss, 
%                                 Thomas Rohr, 
%                                 Maximilian von Gellhorn
%   Version                     : v1.5
%   Date                        : 2012-03-20
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Matlab Informations
%   Ensure you have successfully downloaded the "XMl2STRUCT" function 
%   from MATLAB File Exchange:
%   http://www.mathworks.com/matlabcentral/fileexchange/28518-xml2struct
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:
%   ImportXML Converts "Step7"-chart into Simulink subsystem
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function/Interface:
%
% Declaration:
%   [CntOfInputs, CntOfOutputs, Errors] = 
%                   ImportXML(xmlFile, system, BaObjRef)
%
% Inputs:
%   xmlFile         - Step7 XML import file
%   mdlFile         - System in which the Charts will be placed
%   BaObjRef        - structure with the field "DeviceID"
%   h               - handle for GUI communication 
%
% Outputs:
%   CntOfInputs     - number of inputs (InterChartConnection).
%   CntOfOutputs	- number of outputs (InterChartConnection).
%   Errors	 	    - true in case of error
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Revision History 
% 	(Put meaningful comments in SourceSafe for log below!)
% 	(Please remove blank lines and very old comments!)
% 	
% 	2012-03-20 14:00 Thomas Rohr
%	Header comment was attached
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% selecting the status box Handle

%_
% Start a for loop over all blocks that should be created
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch xml.Attributes.PageSize
	case 'A3'
        CFC_X_PageSize = 212;
        %CFC_Y_PageSize = 100;
        %Max_MarginSize = 53;
    case 'A4'
        CFC_X_PageSize = 150;
        %CFC_Y_PageSize = 70;
        %Max_MarginSize = 37;
    case 'A5'
        CFC_X_PageSize = 106;
        %CFC_Y_PageSize = 50;
        %Max_MarginSize = 26;
    otherwise
        CFC_X_PageSize = 212;
        %CFC_Y_PageSize = 100;
        %Max_MarginSize = 53;        
end% switch
CFC_X_Rasterweite = 10;
CFC_Y_Rasterweite = 14;
MarginSize  = str2double(xml.Attributes.MarginSize);

% add NestedCharts 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isfield(xml,'NestedCharts')

    for nNestChart = 1 : numel(xml.NestedCharts)
        NestChart = xml.NestedCharts{nNestChart};
        ChartAddress  = regexp(NestChart.Attributes.Name,'(.*)@(.*)','tokens');
        if (isempty(ChartAddress))
            ObjName = strcat ([system, '/'], NestChart.Attributes.Name);
        else
            ObjName = char(strcat ([system, '/'], ChartAddress{1}(1,2)));
        end
        
       % Place created Block due to position and count of in-/outputs
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       PointX = str2double(NestChart.Attributes.PointX);
       PointY = str2double(NestChart.Attributes.PointY);
       width = 170;
       x1 = (PointX - (((floor(PointX / CFC_X_PageSize)) * 2) + 1) * MarginSize) * CFC_X_Rasterweite;
       x2 = x1 + width;
       y1 = (PointY * CFC_Y_Rasterweite);
       y2 = y1 + (18 * numel(NestChart.Interface));
        
       add_block('built-in/SubSystem',ObjName, 'Position', [x1 y1 x2 y2]);
    
       %% configure Chart subsystem
       set_param (ObjName,...
            'MaskDisplay', sprintf('disp (''Chart'');'),...
            'Mask','off',...
            'BackgroundColor','lightblue',...
            'MaskIconOpaque', 'on',...
            'MaskIconUnits','Autoscale',...
            'MaskIconRotate','off');
       
       if isfield(NestChart.Attributes, 'ObjectId')
           BaObjRef.ObjectId = NestChart.Attributes.ObjectId;
       end
        
       stepin = ['     ' char (45 * ones (1, (length (strfind (ObjName, '/')) - 2) * 2 )) '> '];
       Send2GUI([stepin 'Import SubSystem [' ObjName '] START'],h.status);
       ImportChart (NestChart, ObjName, libTRA, h, BaObjRef);
       stepin = ['     ' char (45 * ones (1, (length (strfind (ObjName, '/')) - 2) * 2 )) '> '];
       Send2GUI([stepin 'Import SubSystem [' ObjName '] END'],h.status);
   
   end

end

stepin = ['     ' char (45 * ones (1, (length (strfind (system, '/')) - 2) * 2 )) '> '];

if isfield(xml,'FB')
    for nFB = 1 : numel(xml.FB)
       blk = xml.FB{nFB};
       %
       % get the X and X position
       PointX = str2double(blk.Attributes.PointX);
       PointY = str2double(blk.Attributes.PointY);
       %
       flag = [];
       % 0 - TRA library
       % 1 - logical operator (built-in)
       %
       % Create Block
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       switch upper(blk.Attributes.Typ)
          case {'AND' 'OR' 'NOT' 'XOR'}
             flag = 1;
             width = 30;
             %
             simFB = add_block('built-in/Logical Operator', ...
                [system '/' blk.Attributes.Name ], ...
                'Operator',blk.Attributes.Typ, ...
                'ShowName','off');
             %

          case {'ABS_R' 'ABS_I' 'ABS_DI'}            % TOM 05.01.2012 ABS_R Block hinzugefügt. Lorenzo 28.02.12 I und DI hinzugefügt, es wird neu ein Libraryblock benutzt

             ind = cellfun(@(x) ~isempty(strfind(x,['/' blk.Attributes.Typ '_'])),libTRA); 

             flag = 2;
             width = 30;
             %
             % Copy block from the TRA library
             simFB = add_block(libTRA{ind},[system '/' blk.Attributes.Typ], ...
               'Name',blk.Attributes.Name);

          case {'CMP_I' 'CMP_DI' 'CMP_T'}                    % Thomas 12-02-22 CMP_I Block hinzugefügt; Lorenzo 28.2.12 CMP_DI und CMP_T

             ind = cellfun(@(x) ~isempty(strfind(x,['/' blk.Attributes.Typ '_'])),libTRA); 

             flag = 2;
             width = 100;
             %
             % Copy block from the TRA library
             simFB = add_block(libTRA{ind},[system '/' blk.Attributes.Typ], ...
               'Name',blk.Attributes.Name);

           case {'MAX_I', 'MIN_I', 'MAX_DI', 'MIN_DI'}      % Lorenzo 28.2.12 MAX und MIN hinzugefügt

             ind = cellfun(@(x) ~isempty(strfind(x,['/' blk.Attributes.Typ '_'])),libTRA);

             flag = 3;
             width = 100;
             %
             % Copy block from the TRA library
             simFB = add_block(libTRA{ind},[system '/' blk.Attributes.Typ], ...
               'Name',blk.Attributes.Name);

           case {'BO_BY', 'BO_DW', 'BO_W', 'BY_BO', 'BY_DW', 'BY_W', 'DI_DW', 'DI_I', 'DI_R', 'DW_BO', ...
                 'DW_DI', 'DW_R', 'DW_W', 'I_DI', 'I_DW', 'I_R', 'I_W', 'W_BO', 'W_BY', 'W_DW', 'W_I'} %28.02.12 Data Type Conversion hinzugefügt

             ind = cellfun(@(x) ~isempty(strfind(x,'/CONV_')),libTRA); 

              flag = 4;
              width = 100;
              %
              % Copy block from the TRA library
              simFB = add_block(libTRA{ind},[system '/' blk.Attributes.Typ], ...
               'Name',blk.Attributes.Name);
           
           %set the ConvType
           set_param(gcb, 'ConvType', upper(blk.Attributes.Typ));
           switch get_param(gcb, 'ConvType')
                case {'BY_DW', 'DI_DW', 'DI_I', 'DI_R', 'DW_DI', 'DW_R', 'DW_W', 'I_DI', 'I_DW', 'I_R', 'I_W', 'W_BY', 'W_DW', 'W_I'}
                    inputnmbr=1;
                    outputnmbr=1;
                case {'BO_BY'}
                    inputnmbr=8;
                    outputnmbr=1;
                case {'BO_DW'}
                    inputnmbr=32;
                    outputnmbr=1;
                case {'BO_W'}
                    inputnmbr=16;
                    outputnmbr=1;
                case {'BY_BO'}
                    inputnmbr=1;
                    outputnmbr=8;
                case {'DW_BO'}
                    inputnmbr=1;
                    outputnmbr=32;
                case {'W_BO'}
                    inputnmbr=1;
                    outputnmbr=16;
           end
            
            input=zeros(1,32);     
            output=zeros(1,32);

            for i=1:inputnmbr
                input(i)=1;     %set the first entry to the #inputs needed to 1
            end

            for i=1:outputnmbr
                output(i)=1;    %set the first entry to the #output needed to 1
            end

            for i=1:32
                if input(i)==0
                    set_param(gcb,['Invisible_' num2str(i-1)],'on');
                    eval (['Callback(' sprintf('%d', i) ',simFB);']);
                end

                if input(i)==1
                    set_param(gcb,['Invisible_' num2str(i-1)],'off');
                    eval (['Callback(' sprintf('%d', i) ',simFB);']);
                end

                j=i+32;

                if output(i)==0
                    set_param(gcb,['Invisible_' num2str(j-1)],'on');
                    eval (['Callback(' sprintf('%d', j) ',simFB);']);
                end

                if output(i)==1
                    set_param(gcb,['Invisible_' num2str(j-1)],'off');
                    eval (['Callback(' sprintf('%d', j) ',simFB);']);
                end
            end
            
            % change Portnames from IN0 to IN and OUT0 to OUT, if # of inputs ==1
            % or # number of outputs  == 1
            % this convention comes from TIA
            
            if inputnmbr == 1
                set_param([gcb '/IN0'],'Name','IN');
                MskPrmpts = get_param(gcb,'MaskPrompts');
                MskPrmpts{1}='IN: Invisible'; %for proper functionality of callback
                MskPrmpts{65}='IN: Invisible';
                set_param(gcb,'MaskPrompts',MskPrmpts);
            end
            
            if outputnmbr == 1
                set_param([gcb '/OUT0'],'Name','OUT');
                MskPrmpts = get_param(gcb,'MaskPrompts');
                MskPrmpts{33}='OUT: Invisible'; %for proper functionality of callback
                set_param(gcb,'MaskPrompts',MskPrmpts);
            end

            
            
          otherwise % probably from the TRA library
             % creating a Mask - Thomas Rohr 
             ind = cellfun(@(x) ~isempty(strfind(x,['/' blk.Attributes.Typ '_'])),libTRA);
             if any(ind)
                flag = 0;
                width = 100;
                %
                % Copy block from the TRA library
                dummy = libTRA{ind};
                simFB = add_block(dummy,[system '/' blk.Attributes.Typ], 'Name',blk.Attributes.Name);
                %
             else
                Send2GUI([stepin 'ERROR : Unknown block (' blk.Attributes.Typ ')'],h.status)
                Errors = true;
                flag = 255;  % TOM 05.01.2012 flag auf 255 gesetzt damit unbekannte Blöcke nicht parametriert werden.
                continue;
                %
             end% switch
       end% if
       %
       value = [];
       if isfield(blk,'Param')
          nInOut = [0 0];
          InputCount = 0; %Lorenzo 29.02.12
          for nPR = 1 : numel(blk.Param)
             switch flag
                case 0
                   % TRA Block
                   switch blk.Param{nPR}.Attributes.Name
                      case 'EN' , ind = 1;
                      case 'ENO', ind = 2;
                      case 'BaObjRef'
                         set_param(simFB,'DeviceID',sprintf('%d',str2double(BaObjRef.DeviceId)))
                         set_param(simFB,'ObjectID',sprintf('%d',str2double(BaObjRef.ObjectId)))
                         set_param(simFB,'ItemID'  ,sprintf('%d',str2double(blk.Attributes.ItemID)))
                      otherwise
                         switch blk.Param{nPR}.Attributes.Invisible
                            case 'false' % In- or Output is visible
                               nInOut(ind) = nInOut(ind) + 1;
                               switch ind
                                  case 1
                                     if isfield(blk.Param{nPR}.Attributes,'Value')
                                        tmp = str2double(blk.Param{nPR}.Attributes.Value);
                                        if isnan(tmp)

                                           test = blk.Param{nPR}.Attributes.Value;
                                           if (strncmp ( test, '16#', 3) == 1)
                                               test = strrep ( test, '16#', '');
                                               test = num2str(hex2dec(test));
                                           else
                                               test = strrep(test, '_', '+');
                                               test = strrep(test, 'ms', '*0.001');
                                               test = strrep(test, 's',  '*1');
                                               test = strrep(test, 'm',  '*60');
                                               test = strrep(test, 'h',  '*3600');
											   test = strrep(test, 'd',  '*86400');
                                           end
                                           tmp = test;
                                        end% if
                                        value.in.(blk.Param{nPR}.Attributes.Name) = tmp;                                    
                                     end% if
                                     %
                                  case 2
                                     % Output value
                                     % ------------
                               end
                            case 'true' 
                               % In- or Output is invisible
                               %
                               % set current block as "gcb"
                               set_param(0,'CurrentSystem',system);
                               set_param(system,'currentBlock',blk.Attributes.Name)
                               %
                               % determine certain mask value and callback and execute it
                               maskPrompts = get_param(simFB,'maskPrompts');
                               portName = char(blk.Param{nPR}.Attributes.Name);
                               
                               id = find(strncmp(maskPrompts,portName,length(portName)));
                                   
                               maskNames = get_param(simFB,'maskNames');
                               set_param(simFB,maskNames{id(1)},'on');

                               %maskCallback = get_param(simFB,'maskCallbacks');
                               %eval(maskCallback{id(1)})
                               eval (['Callback(' sprintf('%d', id(1)) ',simFB);']);                           

                               id = find(strcmp (['Default_' portName], maskNames));
                               if (id > 0)
                                   tmp = blk.Param{nPR}.Attributes.Value;
                                   if isnan(str2double(tmp))
                                       test = blk.Param{nPR}.Attributes.Value;
                                       test = strrep(test, '_', '+');
                                       test = strrep(test, 'ms', '*0.001');
                                       test = strrep(test, 's',  '*1');
                                       test = strrep(test, 'm',  '*60');
                                       test = strrep(test, 'h',  '*3600');
									   test = strrep(test, 'd',  '*86400');
                                       tmp = test;                                   
                                   end
                                   set_param(simFB,maskNames{id(1)}, tmp);
                                   %eval (maskCallback{id(1)});                               
                                   eval (['Callback(' sprintf('%d', id(1)) ',simFB);']);    
                               end %
           

                               %
                         end% switch
                   end% switch
                case 1
                   % Logical Operator (built-In)
                   switch lower(blk.Param{nPR}.Attributes.Name(1:2))
                      case 'in'
                         nInOut(1) = nInOut(1) + 1;
                         set_param(simFB,'Inputs',sprintf('%d',nInOut(1)))

                         if isfield(blk.Param{nPR}.Attributes,'Value')
                            tmp = str2double(blk.Param{nPR}.Attributes.Value);
                            if isnan(tmp)
                              Send2GUI([stepin 'WARNING : Value ' blk.Param{nPR}.Attributes.Value ' can not be evaluated.'],h)
                            end% if
                            value.in.(blk.Param{nPR}.Attributes.Name) = tmp;                                    
                         end% if                     

                      case 'ou'
                         nInOut(2) = nInOut(2) + 1;
                   end% switch

                case 2
                  % Inline Functions (CMP, ABS)
                   switch lower(blk.Param{nPR}.Attributes.Name(1:2))
                      case 'in'
                         if isfield(blk.Param{nPR}.Attributes,'Value')
                            tmp = str2double(blk.Param{nPR}.Attributes.Value);
                            if isnan(tmp)
                               tmp = str2double(regexp(blk.Param{nPR}.Attributes.Value,'\d*','match'));
                               switch char(regexp(blk.Param{nPR}.Attributes.Value,'\D*','match'))
                                  case 'ms'
                                     tmp = tmp * 0.001;
                                  case 's'
                                     % nothing to do
                                  case 'm'
                                     tmp = tmp * 60;
                                   otherwise
                                     Send2GUI([stepin 'WARNING : Value ' blk.Param{nPR}.Attributes.Value ' can not be evaluated.'],h)
                               end% switch
                            end% if
                            value.in.(blk.Param{nPR}.Attributes.Name) = tmp;                                    
                         end% if                      
                         nInOut(1) = nInOut(1) + 1;
                      case 'ou'
                         nInOut(2) = nInOut(2) + 1;
                   end% switch

                case 3
                  % MAX/MIN

                  switch lower(blk.Param{nPR}.Attributes.Name(1:2))
                      case 'in'
                         InputCount = InputCount+1;
                         if (strcmp(blk.Param{nPR}.Attributes.Invisible, 'false'))
                            nInOut(1) = nInOut(1) + 1;
                         end
                      case 'ou'
                         nInOut(2) = nInOut(2) + 1;
                  end% switch

                  set_param(simFB, 'NumOfInputs', sprintf('%d',InputCount));
                  set_param (simFB, 'LinkStatus', 'inactive');

                  if (nPR== numel(blk.Param))
                      NumberOfInputs();

                      % set current block as "gcb"
                      set_param(0,'CurrentSystem',system);
                      set_param(system,'currentBlock',blk.Attributes.Name)
                      %
                      maskNames = get_param(simFB,'maskNames');
                      for i=2:numel(blk.Param)-2
                           if strcmp(blk.Param{i}.Attributes.Invisible, 'true')
                              set_param(simFB, maskNames{i-1}, 'on');
                              %maskCallback = get_param(simFB,'maskCallbacks');
                              %eval(maskCallback{i-1})
                              eval (['Callback(' sprintf('%d', i-1) ',simFB);']);     
                           end
                      end
                  end
                  %
                  %
                case 4
                  % Data Type Conversion
                  switch lower(blk.Param{nPR}.Attributes.Name(1:2))
                      case 'in'
                         nInOut(1) = nInOut(1) + 1;
                      case 'ou'
                         nInOut(2) = nInOut(2) + 1;
                   end% switch
                     set_param(simFB, 'ConvType', blk.Attributes.Typ );

                     maskCallback = get_param(simFB, 'maskCallbacks');
                     set_param (simFB, 'LinkStatus', 'inactive');
                     eval(maskCallback{length(maskCallback)});
                   %
                   % 
             end% switch
          end% for
       end% if

       % Struct
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       if isfield(blk,'Struct') && (flag ~= 255 )
          maskNames = get_param(simFB,'maskPrompts');
          for nStr = 1 : numel(blk.Struct)
              if (numel(blk.Struct) == 1)
                actblk = blk.Struct(nStr);    
              else
                actblk = blk.Struct{nStr};
              end
              StrName = actblk.Attributes.Name;
              try 
                  BlkType = get_param([system '/' blk.Attributes.Name '/' StrName],'BlockType');
                  blknotfound = 0;
              catch
                  blknotfound = 1;
              end

              if (blknotfound == 0)
                  switch BlkType
                    case 'Inport'
                        ind = 1;
                        value.in.(StrName) = [];
                    case 'Outport'
                        ind = 2;
                        value.out.(StrName) = [];
                  end% switch

                  switch actblk.Attributes.Invisible
                    case 'false'
                       %
                       nInOut(ind) = nInOut(ind) + 1;               
                       for nMbr = 1 : numel(actblk.Member)
                          %switch blk.Struct{nStr}.Member{nMbr}.Attributes.Invisible
                            % case 'false'
                                if isfield(actblk.Member{nMbr}.Attributes,'Value')
                                   switch ind
                                      case 1
                                         value.in.(StrName)(nMbr) = str2double(actblk.Member{nMbr}.Attributes.Value);
                                      case 2
                                         value.out.(StrName)(nMbr) = str2double(actblk.Member{nMbr}.Attributes.Value);
                                   end% switch
                                else
                                   % "Value" not available
                                   % ---------------------
                                end% if
                             %case 'true'
                                % "Member" invisible
                                % ------------------
                          %end% switch
                       end% for
                       %
                    case 'true'
                       % "Struct" invisible
                       % ------------------

                               %
                               % set current block as "gcb"
                               set_param(0,'CurrentSystem',system);
                               set_param(system,'currentBlock',blk.Attributes.Name)
                               %
                               % determine certain mask value and callback and execute it
                               maskPrompts = get_param(simFB,'maskPrompts');
                               portName = char(actblk.Attributes.Name);
                               id = find(strncmp(maskPrompts,portName,length(portName)));
                               %
                               maskNames = get_param(simFB,'maskNames');
                               set_param(simFB,maskNames{id(1)},'on');
                               eval (['Callback(' sprintf('%d', id(1)) ',simFB);']);

                               id = find(strcmp (['Default_' portName], maskNames));
                               tmp = '[';
                               if (id > 0)
                                   for nMbr = 1 : numel(actblk.Member)
                                       if (isfield (actblk.Member{nMbr}, 'ChildObject') == 0)
                                          tmp = [tmp ' ' actblk.Member{nMbr}.Attributes.Value];
                                       else
                                          for nChild = 1 : numel (actblk.Member{nMbr}.ChildObject)
                                              tmp = [tmp ' ' actblk.Member{nMbr}.ChildObject{nChild}.Attributes.Value];
                                          end
                                       end
                                   end
                                   tmp = [tmp ' ]'];
                                   set_param(simFB,maskNames{id(1)}, tmp);
                                   eval (['Callback(' sprintf('%d', id(1)) ',simFB);']);
                               end               

                 end% switch
              end%if
          end% for
       end% if

       % Place created Block due to position and count of in-/outputs
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       x1 = (PointX - (((floor(PointX / CFC_X_PageSize)) * 2) + 1) * MarginSize) * CFC_X_Rasterweite;
       x2 = x1 + width;
       y1 = (PointY * CFC_Y_Rasterweite);
       y2 = y1 + (18 * max (nInOut));
       set(simFB,'position',[x1 y1 x2 y2])

      % Create Const-Blocks for input values if necessary
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       if ~isempty(value)
          pos = get_param(simFB,'Inport');
          for nSgn = fieldnames(value.in)'
             if ~isempty(value.in.(char(nSgn)))
                %
                if (flag == 1)
                    indPort = sscanf( strrep(nSgn{1}, 'IN', ''), '%d');
                    if isempty(indPort)
                        indPort = 1;
                    end
                else
                    tmp = find_system(simFB,'followLinks','on','LookUnderMasks','on','BlockType','Inport','Name',char(nSgn));
                    indPort = str2double(get_param(tmp,'Port'));
                end
                simConst = 0;

                %
                try
                    if ischar(value.in.(char(nSgn)))
                        simConst = add_block(...
                            'built-in/Constant', ...
                            [system '/Const'], ...
                            'MakeNameUnique','on', ...
                            'Value',['[' value.in.(char(nSgn)) ']'], ...
                            'Position',[pos(indPort,1)-100 pos(indPort,2)-7 pos(indPort,1)+15-80 pos(indPort,2)+15-7], ...
                            'ShowName','off', ...
                            'SampleTime', '-1');                    
                    else
                        simConst = add_block(...
                            'built-in/Constant', ...
                            [system '/Const'], ...
                            'MakeNameUnique','on', ...
                            'Value',['[' sprintf('%d ',value.in.(char(nSgn))) ']'], ...
                            'Position',[pos(indPort,1)-100 pos(indPort,2)-7 pos(indPort,1)+15-80 pos(indPort,2)+15-7], ...
                            'ShowName','off', ...
                            'SampleTime', '-1');
                    end
                portConst = get_param(simConst,'PortHandles');
                portFB    = get_param(simFB,'PortHandles');
                add_line(system,portConst.Outport(1),portFB.Inport(indPort));
                catch
                    if (simConst ~= 0)
                        delete_block(simConst)
                    end
                end
                %
             end% if
          end% for
       end% if   

        % InterChartConnection
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if isfield(blk,'InterChartConnection')
            posOut = get_param(simFB,'Outport');
            posIn  = get_param(simFB,'Inport');
            %
            if numel(blk.InterChartConnection) == 1
                icc = [];
                icc{1} = blk.InterChartConnection;
            else
                icc = blk.InterChartConnection;
            end% if
            %
            for nICC = 1 : numel(icc)
                switch flag
                    case {1 2} % Simulink Block
                        indPort = str2double(regexp(icc{nICC}.Attributes.Pin,'\d*','match'));
                        if isempty(indPort)
                            indPort = 1;
                        end% if
                        pc = get_param(simFB,'PortConnectivity');
                        switch upper(char(regexp(icc{nICC}.Attributes.Pin,'\D*','match')))
                            case 'IN'
                                icc{nICC}.Attributes.Name = ['ICC_' icc{nICC}.Attributes.Name];
                                posIn = pc(indPort).Position;
                                if isempty(find_system(system,'Name',icc{nICC}.Attributes.Name,'BlockType','Inport'))
                                    simInport = add_block( ...
                                        'built-in/Inport', ...
                                        [system '/Inport' ], ...
                                        'MakeNameUnique','on', ...
                                        'Position',[posIn(1)-100 posIn(2)-7 posIn(1)+15-70 posIn(2)+15-7], ...
                                        'Name',icc{nICC}.Attributes.Name);
                                end% if
                                
                                try
                                    add_line(system,[icc{nICC}.Attributes.Name '/1'], ...
                                        [blk.Attributes.Name '/' sprintf('%d',indPort)], ...
                                        'autorouting','on');
                                catch
                                    delete_block(simInport);
                                end
                            case 'OUT'
                                posOut = pc(end-1+indPort).Position;
                                icc{nICC}.Attributes.Name = ['ICC_' icc{nICC}.Attributes.Name];
                                % Check if the Outport already exists
                                if isempty(find_system(system,'Name',icc{nICC}.Attributes.Name,'BlockType','Outport'))
                                    % Create if necessary
                                    add_block(...
                                        'built-in/Outport', ...
                                        [system '/Outport'], ...
                                        'MakeNameUnique','on', ...
                                        'Position',[posOut(indPort,1)+20 posOut(indPort,2)-7 posOut(indPort,1)+65 posOut(indPort,2)-7+15], ...
                                        'Name',[icc{nICC}.Attributes.Name]);
                                end% if
                                % connect
                                add_line(system,[blk.Attributes.Name '/' sprintf('%d',indPort)], [icc{nICC}.Attributes.Name '/1'],'autorouting','on');
                        end% switch
                        
                    case 0 % TRA
                        % Determine if an in- or outport should be used
                        switch get_param([system '/' blk.Attributes.Name '/' icc{nICC}.Attributes.Pin],'BlockType')
                            case 'Inport'
                                tmp = find_system(simFB,'followLinks','on','LookUnderMasks','on','BlockType','Inport','Name',icc{nICC}.Attributes.Pin);
                                indPort = str2double(get_param(tmp,'Port'));
                                icc{nICC}.Attributes.Name = ['ICC_' icc{nICC}.Attributes.Name];
                                % Check if the Inport already exists
                                if isempty(find_system(system,'Name',icc{nICC}.Attributes.Name,'BlockType','Inport'))
                                    % Create if necessary
                                    simInport = add_block( ...
                                        'built-in/Inport', ...
                                        [system '/Inport' ], ...
                                        'MakeNameUnique','on', ...
                                        'Position',[posIn(indPort,1)-100 posIn(indPort,2)-7 posIn(indPort,1)+15-70 posIn(indPort,2)+15-7], ...
                                        'Name',icc{nICC}.Attributes.Name);
                                end% if
                                % connect
                                try
                                    add_line(system,[icc{nICC}.Attributes.Name '/1'], ...
                                        [blk.Attributes.Name '/' sprintf('%d',indPort)], ...
                                        'autorouting','on');
                                catch
                                    delete_block(simInport);
                                end
                            case 'Outport'
                                tmp = find_system(simFB,'followLinks','on','LookUnderMasks','on','BlockType','Outport','Name',icc{nICC}.Attributes.Pin);
                                indPort = str2double(get_param(tmp,'Port'));
                                icc{nICC}.Attributes.Name = ['ICC_' icc{nICC}.Attributes.Name];
                                % Check if the Outport already exists
                                if isempty(find_system(system,'Name',icc{nICC}.Attributes.Name,'BlockType','Outport'))
                                    % Create if necessary
                                    add_block(...
                                        'built-in/Outport', ...
                                        [system '/Outport'], ...
                                        'MakeNameUnique','on', ...
                                        'Position',[posOut(indPort,1)+20 posOut(indPort,2)-7 posOut(indPort,1)+65 posOut(indPort,2)-7+15], ...
                                        'Name',[icc{nICC}.Attributes.Name]);
                                end% if
                                % connect
                                add_line(system,[blk.Attributes.Name '/' sprintf('%d',indPort)], [icc{nICC}.Attributes.Name '/1'],'autorouting','on');
                        end% switch
                end% switch
            end% for
        end% if
    end% for
end% if


%
% Start a for loop over all interfaces that should be created
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if isfield(xml, 'Interface')
%     for nInterface = 1 : numel(xml.Interface)
%         if numel (xml.Interface) == 1
%             interface = xml.Interface.Attributes;
%         else
%             interface = xml.Interface{nInterface}.Attributes;
%         end
%         
%         if strcmp (interface.SectionType, 'VarInput')
%             if ~strcmp (interface.Name, 'EN')
%                 add_block( ...
%                     'built-in/Inport', ...
%                     [system '/Inport' ], ...
%                     'MakeNameUnique','on', ...
%                     ... %'Position',[posIn(indPort,1)-100 posIn(indPort,2)-7 posIn(indPort,1)+15-70 posIn(indPort,2)+15-7], ...
%                     'Name',interface.Name);            
%             end
%         elseif strcmp (interface.SectionType, 'VarOutput')
%             add_block(...
%                 'built-in/Outport', ...
%                 [system '/Outport'], ...
%                 'MakeNameUnique','on', ...
%                 ... %'Position',[posOut(indPort,1)+20 posOut(indPort,2)-7 posOut(indPort,1)+65 posOut(indPort,2)-7+15], ...
%                 'Name',interface.Name);            
%         end
%     end
% end


%
% Start a for loop over all links that should be created
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isfield(xml,'Link')
    for nLNK = 1 : numel(xml.Link)
       % proof if only one link is existing
       % Thomas Rohr 12-02-21
       if numel(xml.Link) == 1
            % only one Link --> no Array
            lnk = xml.Link.Attributes;   
       else 
            % more than one Links --> Array
            lnk = xml.Link{nLNK}.Attributes;
       end

        try
            SubsystemName = regexp(system,'(.*)/(.*)','tokens');
            SubsystemName = SubsystemName{1}(2);
            
            if ~isempty (strfind(lnk.FromFBName, '@'))
                lnk.FromFBName = regexp(lnk.FromFBName,'(.*)@(.*)','tokens');
                lnk.FromFBName = lnk.FromFBName{1}{2};
            end
          
            if strcmp (SubsystemName, lnk.FromFBName)
                try 
                    pos = get_param ([system '/' lnk.ToFBName], 'Position');
                    
                    if strcmp (get_param([system '/' lnk.ToFBName], 'BlockType'), 'Logic')
                        fr = char(regexp(lnk.ToPin,'(\d*)','match'));
                        if isempty(fr)
                            port = 0;
                        else
                            port = str2double(fr) - 1;
                        end
                    else
                        port = (str2double(get_param ([system '/' lnk.ToFBName '/' lnk.ToPin],'port')) - 1);
                    end
                    
                    add_block( ...
                        'built-in/Inport', ...
                        [system '/Inport' ], ...
                        'MakeNameUnique','on', ...
                        'Position', [pos(1)-100 pos(2)+(port*20) pos(1)-70 pos(2)+(port*20)+14], ...
                        'Name',lnk.FromPin);                        
                catch
                end
                lnk.FromFBName = lnk.FromPin;
                fr = '1';
            else
                switch get_param([system '/' lnk.FromFBName], 'BlockType')    % TOM: 05.01.2012: Abfrage auf AND, OR, NOT nicht vom Blocknamen sondern vom BlockType abhängig gemacht.
                    case 'Logic'
                        fr = char(regexp(lnk.FromPin,'(\d*)','match'));
                        if isempty(fr)
                            fr = '1';
                        end% if
                    otherwise
                        fr = get_param([system '/' lnk.FromFBName '/' lnk.FromPin],'port');
                end% switch
            end
            
            if ~isempty (strfind(lnk.ToFBName, '@'))
                lnk.ToFBName = regexp(lnk.ToFBName,'(.*)@(.*)','tokens');
                lnk.ToFBName = lnk.ToFBName{1}{2};
            end            
            
            if strcmp (SubsystemName, lnk.ToFBName)
                try
                    pos = get_param ([system '/' lnk.FromFBName], 'Position');
                    
                    if strcmp (get_param([system '/' lnk.FromFBName], 'BlockType'), 'Logic')
                         port = 1;
                    else
                         port = (str2double(get_param ([system '/' lnk.FromFBName '/' lnk.FromPin],'port')) - 1);
                    end                    
                    
                    add_block( ...
                        'built-in/Outport', ...
                        [system '/Outport' ], ...
                        'MakeNameUnique', 'on', ...
                        'Position', [pos(3)+100 pos(2)+13+(port*45) pos(3)+130 pos(2)+27+(port*45)], ...
                        'Name', lnk.ToPin);
                catch
                end
                lnk.ToFBName = lnk.ToPin;
                to = '1';
            else
                switch get_param([system '/' lnk.ToFBName],'BlockType')     % TOM: 05.01.2012: Abfrage auf AND, OR, NOT nicht vom Blocknamen sondern vom BlockType abhängig gemacht.
                    case 'Logic'
                        to = char(regexp(lnk.ToPin,'(\d*)','match'));
                        if isempty(to)
                            to = '1';
                        end% if
                    otherwise
                        to = get_param([system '/' lnk.ToFBName '/' lnk.ToPin],'port');
                end% switch
            end
          %


          % Insert Memory Module to dissolve Algebraic Loop
          if isfield(lnk, 'MemoryModule') &&   strcmp(lnk.MemoryModule,'true')
             indPort = str2double(get_param([system '/' lnk.FromFBName '/' lnk.FromPin],'Port'));
             %
             blkPos = get_param([system '/' lnk.FromFBName],'Position');
            % UDpos  = [blkPos(1)+round((blkPos(3)-blkPos(1)-25)/2) blkPos(4)+50 ...
            %          blkPos(1)+round((blkPos(3)-blkPos(1)-25)/2)+25 blkPos(4)+50+15];
            UDpos  = [blkPos(3)+10 blkPos(4)+round((blkPos(4)-blkPos(2)-25)/2) ...
                     blkPos(3)+20  blkPos(3)+round((blkPos(4)-blkPos(2))/2)];
             unitDelay = add_block(...
                'built-in/Unit Delay', ...
                [system '/Unit Delay'], ...
                'MakeNameUnique','on', ...
                'Orientation','left', ...
                'Position',[blkPos(3)+40 ...
                            blkPos(2)+20 ...
                            blkPos(3)+55 ...
                            blkPos(2)+35], ...
                'ShowName','off', ...
                'SampleTime', '-1');         
             add_line(system,[lnk.FromFBName '/' sprintf('%d',indPort)],[get_param(unitDelay,'Name') '/1'],'autorouting','on');
             %add_line(system,[get_param(unitDelay,'Name') '/1'],[lnk.ToFBName '/' to],'autorouting','on');
             lnk.FromFBName = [get_param(unitDelay,'Name')];
             fr = '1';
             Send2GUI([stepin 'Memory module is inserted after  (' lnk.FromFBName  '/'  lnk.FromPin  ' )'],h.status)
          end% if

          % Algebraich Loop check (for current block only)
          if strcmp(lnk.FromFBName,lnk.ToFBName)
             Send2GUI([stepin 'HINT : Algebraic Loop detected (' lnk.FromFBName ')'],h.status)
             indPort = str2double(get_param([system '/' lnk.FromFBName '/' lnk.FromPin],'Port'));
             %
             blkPos = get_param([system '/' lnk.FromFBName],'Position');
             UDpos  = [blkPos(1)+round((blkPos(3)-blkPos(1)-25)/2) blkPos(4)+50 ...
                      blkPos(1)+round((blkPos(3)-blkPos(1)-25)/2)+25 blkPos(4)+50+15];
             unitDelay = add_block(...
                'built-in/Unit Delay', ...
                [system '/Unit Delay'], ...
                'MakeNameUnique','on', ...
                'Orientation','left', ...
                'Position',[blkPos(1)+round((blkPos(3)-blkPos(1)-25)/2) ...
                            blkPos(4)+50 ...
                            blkPos(1)+round((blkPos(3)-blkPos(1)-25)/2)+25 ...
                            blkPos(4)+50+15], ...
                'ShowName','off', ...
                'SampleTime', '-1');

             add_line(system,[lnk.FromFBName '/' sprintf('%d',indPort)],[get_param(unitDelay,'Name') '/1'],'autorouting','on');
             %add_line(system,[get_param(unitDelay,'Name') '/1'],[lnk.ToFBName '/' to],'autorouting','on');
             lnk.FromFBName = [get_param(unitDelay,'Name')];
             fr = '1';
          end% if

          switch lnk.Negate
             case 'false'
                add_line(system,[lnk.FromFBName '/' fr],[lnk.ToFBName '/' to],'autorouting','on');
             case 'true'
                nto = str2double(to);
                posInport = get_param([system '/' lnk.ToFBName],'Inport');
                simFB = add_block(...
                   'built-in/Logical Operator', ...
                   [system '/Logical Operator' ], ...
                   'MakeNameUnique','on', ...
                   'Operator','NOT', ...
                   'Position',[posInport(nto,1)-35 posInport(nto,2)-7 posInport(nto,1)+15-25 posInport(nto,2)+15-7], ...
                   'ShowName','off');
                add_line(system,[get_param(simFB,'Name') '/1'],[lnk.ToFBName '/' to],'autorouting','on');
                add_line(system,[lnk.FromFBName '/' fr],[get_param(simFB,'Name') '/1'],'autorouting','on');
          end% switch
       catch
          Errors = true;
          Send2GUI([stepin 'ERROR : Not connected/Block not found  [' lnk.FromFBName ']>' lnk.FromPin ' -/- ' lnk.ToPin '<[' lnk.ToFBName ']'],h.status)
       end
    end% for
end%if

% Terminatoren an nicht verbundenen Ausgängen setzen
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
blk = find_system(system,'FindAll','on','LookUnderMasks','on','SearchDepth',1,'Line',-1,'PortType','outport');
for nBlk = 1:numel(blk)
   if ~strcmp(system,get_param(blk(nBlk),'Parent'))
      pos = get_param(get_param(blk(nBlk),'Parent'),'Outport');
      nto = get_param(blk(nBlk),'PortNumber');
      h.block = add_block(...
         'built-in/Terminator', ...
         [system '/Terminator' ], ...
         'MakeNameUnique','on', ...
         'Position',[pos(nto,1)+20 pos(nto,2)-7 pos(nto,1)+35 pos(nto,2)-7+15], ...
         'ShowName','off');
      add_line(system,[get_param(get_param(blk(nBlk),'Parent'),'Name') '/' sprintf('%d',nto)],[get(h.block,'name') '/1'],'autorouting','on');
   end
end

% add TextBlock 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isfield(xml,'TextBlock')
   txt = xml.TextBlock;
   neTxt = numel(txt);
   for nTxt = 1 : neTxt
     % proof if only one node is existing  
     % Thomas Rohr 12-02-21  
     if neTxt == 1
        % only one node --> no Array 
        ContainsText=isfield(txt.CDataComment,'Text');
        wtxt = txt(nTxt);
     else
        % more than one node --> Array 
     	ContainsText=isfield(txt{nTxt}.CDataComment,'Text');
        % select the array position
        wtxt=txt{nTxt};
     end
       
      if ContainsText
         %
         x1 = str2double(wtxt.Attributes.PointX);
         y1 = str2double(wtxt.Attributes.PointY);
         Size = str2double(wtxt.Attributes.FontSize);
         BackColor = str2double(wtxt.Attributes.BackColor);
         SizeHeight = str2double(wtxt.Attributes.SizeHeight);
         SizeWidth = str2double(wtxt.Attributes.SizeWidth);
         
         Color = dec2hex(16777216+BackColor);
         Color = sprintf( '[%f %f %f]', hex2dec(Color(1:2))/255, hex2dec(Color(3:4))/255, hex2dec(Color(5:6))/255);
         
         x1 = (x1 - (((floor(x1 / CFC_X_PageSize)) * 2) + 1) * MarginSize) * CFC_X_Rasterweite;
         y1 = y1 * CFC_Y_Rasterweite;
   
         Text = wtxt.CDataComment.Text;
         while ~isempty (Text) && (strcmp(Text(length(Text)) , char(10)))
             Text = Text(1:length(Text)-1);
         end
         %
         add_block(...
            'built-in/Note', ...
            [system '/Note' ], ...
            'Position',[x1 y1], ...
            'Text',Text, ...
            'HorizontalAlignment', 'left', ...
            'FontSize', Size, ...
            'ForegroundColor','black', ...
            'BackgroundColor',Color);
      end% if
   end% for
end% if


% % Position Subsystems
% % (12-02-07 - Thomas Rohr)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % get the number of Inputs and Outputs
% CntOfInputs  = numel(find_system(system,'BlockType','Inport'));
% CntOfOutputs = numel(find_system(system,'BlockType','Outport'));
% % calculate the Blocksize due to number of inputs and outputs
% if max(CntOfOutputs,CntOfInputs) == 0
%     yBlockSize=50+15;
% end
% if max(CntOfOutputs,CntOfInputs) > 0
%     yBlockSize=50+max(CntOfOutputs,CntOfInputs)*15;
% end
% % get the SubBlock Address
% SubBlock=[get(SubBlock,'Path') '/' get(SubBlock,'Name')];
% % get the SubBlock Position
% BlockPos=getPos(SubBlock);
% % change the SubBlock Y-BlockSize due to the number of In- and Outputs
% BlockPos(4) = BlockPos(2)+yBlockSize;
% % set the Blockposition 
% set_param(SubBlock,'Position',BlockPos);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Link InterChartConnection
% Start a for loop over all links that should be created
% (12-01-31 - Thomas Rohr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Error=InterChartConnection(subsystem);
  
%
% import done


