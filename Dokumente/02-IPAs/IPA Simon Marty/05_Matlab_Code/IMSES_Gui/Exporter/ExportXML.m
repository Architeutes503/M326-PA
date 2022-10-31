function [Errors] = ExportXML (xmlFile, system, h,FirmwareLib)
% ExportXML Converts Simulink model to a "Step7"-chart
% Declaration	
%    [Errors] = ExportXML (xmlFile, system, h)
%
% Inputs:
%    xmlFile      - Step7 XML output file
%    system       - source simulink model
%    h            - handle for GUI communication 
%
% Outputs:
%    Errors	 	   - true in case of error

% Version: v0.9
%    Date: 20-Feb-2012
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    global CFC_X_Rasterweite CFC_Y_Rasterweite;

    CFC_X_Rasterweite = 10;
    CFC_Y_Rasterweite = 14;    
    
    % selecting the status box Handle
    h.status = h.edit_2_2;
    %
    Send2GUI([' === Start export XML-file : ' xmlFile ' ==='],h.status)
    Errors = false;

    % load and determine all block names from the Simulink TRA Library
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %libName = 'ApplFwS1v1_LIB';
    % Firmware Library
    [~,libName,~] = fileparts(FirmwareLib);
    load_system(libName);
    libTRA = find_system(libName,'BlockType','SubSystem');

    %
    % Create FB
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    allBlocks = find_system(system,'SearchDepth',1,'LookUnderMasks','on','BlockType','SubSystem');
    allBlocks = setxor(allBlocks,system);

    %
    % Find out SubCharts (more than one S-Function block inside)
    chart = [];
    for blk = allBlocks'
        %Type
        Typ = find_system(blk,'FindAll','on','FollowLinks','on','LookUnderMasks','on','BlockType','S-Function');
        Typ = get(Typ,'FunctionName');
        Typ = cellstr(strrep(strrep(Typ,'_S1_SL',''),'_SL',''));
        %
        if numel(Typ) > 1
            chart = [chart;blk];
            Send2GUI([' Subchart detected: [' char(blk) ']'],h.status);
        end
        %
    end% for
    
    allBlocks = setxor(allBlocks,chart);
    
    binBlocks = find_system(system,'SearchDepth',1,'BlockType','Logic');
    binBlocks = [binBlocks;find_system(system,'SearchDepth',1,'BlockType','Abs')];

    Send2GUI([' FunctionBlocks: ' num2str(numel(allBlocks))],h.status);
    chartNames = get_param(chart,'Name');
    
    pos = get_param([allBlocks;binBlocks],'Position');
    pos = cell2mat(pos);
    x2max = max(pos(:,3));
    y2max = max(pos(:,4));
    out = InitializeXMLHeader (system, x2max, y2max);
    
    %
    for blk = allBlocks'
        % Determine all necessary attributes
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        pos = get_param(char(blk),'Position');
        [PointY, PointX] = calcPos(pos);
        %
        % Name
        Name = get_param(char(blk),'Name');
        %
        %ItemID & Type
        Typ = find_system(blk,'FindAll','on','FollowLinks','on','LookUnderMasks','on','BlockType','S-Function');    
        if isempty(Typ)
            % obviously a simulink block (ABS)
            ItemID = [];
        else
            [ItemID Typ] = getItemID (Typ, libTRA);
        end
        %
        % BlockName
        BlockName = get_param(char(blk),'Name');
        %
        % BlockNameTextRef
        BlockNameTextRef = '';
        %
        out = [out sprintf('    <FB PointX="%d" PointY="%d" Typ="%s" Name="%s" Comment="" ItemID="%d" BlockName="%s" BlockNameTextRef="%s" >\r\n', ...
                            PointX,PointY,Typ,Name,ItemID,BlockName,BlockNameTextRef)];
   
        % determine all IN- & OUT- ports
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        prt = get_param(char(blk),'PortConnectivity');
   
   
        % invisible inports
        %%%%%%%%%%%%%%%%%%%%
        maskVariables = get_param(char(blk),'MaskWSVariables');
        ind = arrayfun(@(x) strncmp(x.Name,'Invisible_',10),maskVariables);
        InvPorts = cell(1,sum(ind));
        
        if ~isempty(maskVariables)
            portNames = get_param(char(blk),'MaskPrompts');
            maskValues = get_param(char(blk),'MaskValues');

            for nInvPrt = 1 : sum(ind)
                portName = regexp(portNames{nInvPrt},'(.*):','tokens');
                portName = char(portName{1});
                % Inport behandlung
                if strcmp('Constant',get_param([char(blk) '/' portName],'BlockType')) && strcmp('on',char(maskValues(nInvPrt)))
                    Value = eval(get_param([char(blk) '/' portName],'Value'));
                    %out = [out sprintf('      <Param Name="%s" Value="%d" Invisible="true" ForTest="false" Comment="" />\r\n',portName,Value)];
                    InvPorts{nInvPrt}.out = sprintf('      <Param Name="%s" Value="%d" Unit="" Invisible="true" ForTest="false" Comment="" />\r\n',portName,Value);
                    InvPorts{nInvPrt}.type = 1;                    
                else % Outport behandlung
                    if strcmp('Terminator',get_param([char(blk) '/' portName],'BlockType')) && ...
                        strcmp('on',char(maskValues(nInvPrt)))
                        %out = [out sprintf('      <Param Name="%s" Value="0" Invisible="true" ForTest="false" Comment="" />\r\n',portName)];
                        InvPorts{nInvPrt}.out = sprintf('      <Param Name="%s" Value="0" Invisible="true" ForTest="false" Comment="" />\r\n',portName);
                        InvPorts{nInvPrt}.type = 2;
                    end% if                
                end% if
            end% for
        end
        
        % add "EN"-line
        out = [out sprintf('      <Param Name="EN" Value="1" Unit="" Invisible="true" ForTest="false" Comment="" />\r\n')];
        firstOutput = false;
        nPrt = 1;
        for nind = 1 : sum(ind)
            
            if (~isempty(InvPorts{nind}))
                if ((InvPorts{nind}.type == 2) && (firstOutput == false))
                    firstOutput = true;
                    
                    % BaObjRef
                    %%%%%%%%%%%%%%
                    if ItemID > 0
                        out = [out sprintf('      <Param Name="BaObjRef" Value="" Invisible="true" ForTest="false" Comment="" />\r\n')];
                    end% if        

                    % OUTPORT
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    out = [out sprintf('      <Param Name="ENO" Value="1" Unit="" Invisible="true" ForTest="false" Comment="" />\r\n')];
                end
                out = [out InvPorts{nind}.out];                
            else
                % INPORT
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                    
                if ~isempty(prt(nPrt).SrcBlock)
                    portNumber = prt(nPrt).Type;
                    port = find_system(blk,'LookUnderMasks','on','FollowLinks','on','BlockType','Inport','Port',portNumber);
                    portName = char(get_param(port,'Name'));
                    %
                    if prt(nPrt).SrcBlock == -1
                        fprintf(2,'\t ERROR: Block [%s] has unconnected Inport: [%s]\r\n',char(blk),portName);
                        Errors = true;
                    else
                        switch get(prt(nPrt).SrcBlock,'BlockType')
                        % Inport-Block
                        case 'Inport'
                            % INTERCHARTCONNECTION
                            outportName = get_param(prt(nPrt).SrcBlock,'Name');
                            outportName = strrep(outportName, 'ICC_', '');
                            if (strcmp(portName, 'FmHigher') || strcmp(portName, 'FmLower'))
                                % Struct/Member
                                out = [out sprintf('      <Struct Name="%s" Invisible="false" ForTest="false" Comment="">\r\n',portName)];
                                    out = [out sprintf('        <Member Name="CtlMod" Unit="" Invisible="false" ForTest="false" Comment="" />\r\n')];
                                    out = [out sprintf('        <Member Name="Crdn" Unit="" Invisible="false" ForTest="false" Comment="" />\r\n')];
                                    out = [out sprintf('        <Member Name="Ctkn" Unit="" Invisible="false" ForTest="false" Comment="" />\r\n')];
                                    out = [out sprintf('        <Member Name="IsInt" Unit="" Invisible="false" ForTest="false" Comment="" />\r\n')];
                                    out = [out sprintf('        <Member Name="DeltaE" Unit="" Invisible="false" ForTest="false" Comment="" />\r\n')];
                                out = [out sprintf('      </Struct>\r\n')];                           
                            else
                                out = [out sprintf('      <Param Name="%s" Unit="" Invisible="false" ForTest="false" Comment="" />\r\n',portName)];
                            end% if
                            out = [out sprintf('      <InterChartConnection Pin="%s" Name="%s" />\r\n',portName,outportName)];
                                
                            %
                            % CONSTANT-Block
                        case 'Constant'
                            if ~isempty (strfind(get(prt(nPrt).SrcBlock,'Value'), '*'))
                                % Param
                                Value = get(prt(nPrt).SrcBlock,'Value');
                                Value = strrep(Value, '+', '_');
                                Value = strrep(Value, '[', '');
                                Value = strrep(Value, ']', '');
                                Value = strrep(Value, '*0.001', 'ms');
                                Value = strrep(Value, '*1', 's');
                                Value = strrep(Value, '*60', 'm');
                                Value = strrep(Value, '*3600', 'h');
                                out = [out sprintf('      <Param Name="%s" Value="%s" Unit="" Invisible="false" ForTest="false" Comment="" />\r\n',portName,Value)];
                            else
                                Value = eval(get(prt(nPrt).SrcBlock,'Value'));
                                if numel(Value)==1
                                    % Param
                                    out = [out sprintf('      <Param Name="%s" Value="%d" Unit="" Invisible="false" ForTest="false" Comment="" />\r\n',portName,Value)];
                                else
                                    % Struct/Member
                                    out = [out sprintf('      <Struct Name="%s" Value="" Invisible="false" ForTest="false" Comment="" />\r\n',portName)];
                                    for nMember = 1 : numel(Value)
                                        out = [out sprintf('        <Member Name="In%d" Value="%d" Invisible="false" ForTest="false" Comment="" />\r\n',nMember,Value(nMember))];
                                    end% for
                                    out = [out sprintf('      </Struct>\r\n',portName)];
                                end% if
                            end
                        %
                        % GROUND-Block
                        case 'Ground'
                            out = [out sprintf('      <Param Name="%s" Value="0" Invisible="false" ForTest="false" Comment="" />\r\n',portName)];
                            %
                        case 'SubSystem'
                            % check if SubSystem is a chart
                            if strcmp(get(prt(nPrt).SrcBlock,'Name'),chartNames)
                                out = [out sprintf('      <Param Name="%s" Value="" Invisible="false" ForTest="false" Comment="" />\r\n',portName)];
                                outportName = find_system(prt(nPrt).SrcBlock, ...
                                                            'LookUnderMasks','on','SearchDepth',1,'FollowLinks','on', ...
                                                            'BlockType','Outport', ...
                                                            'Port',sprintf('%d',prt(nPrt).SrcPort+1));
                                outportName = get(outportName,'Name');
                                out = [out sprintf('      <InterChartConnection Pin="%s" Name="%s" />\r\n',portName,outportName)];
                            else
                                out = [out sprintf('      <Param Name="%s" Unit="" Invisible="false" ForTest="false" Comment="" />\r\n',portName)];
                            end
                        otherwise
                            out = [out sprintf('      <Param Name="%s" Unit="" Invisible="false" ForTest="false" Comment="" />\r\n',portName)];
                            %
                        end% switch
                    end
                else
                    % OUTPORT
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                     
                    if ~isempty(prt(nPrt).DstBlock)
                        if ((firstOutput == false))
                            firstOutput = true;

                            % BaObjRef
                            %%%%%%%%%%%%%%
                            if ItemID > 0
                                out = [out sprintf('      <Param Name="BaObjRef" Value="" Invisible="true" ForTest="false" Comment="" />\r\n')];
                            end% if        

                            % OUTPORT
                            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            out = [out sprintf('      <Param Name="ENO" Value="1" Unit="" Invisible="true" ForTest="false" Comment="" />\r\n')];
                        end
                        %
                        % determin portname
                        portNumber = prt(nPrt).Type;
                        port = find_system(blk,'LookUnderMasks','on','FollowLinks','on','BlockType','Outport','Port',portNumber);
                        portName = char(get_param(port,'Name'));
                        %
                        if isempty(prt(nPrt).DstBlock)
                            fprintf(2,'\t ERROR: Block [%s] has unconnected Outport: [%s]\r\n',char(blk),portName);
                            Errors = true;
                        else
                            
                            if (strcmp(portName, 'ToHigher') || strcmp(portName, 'ToLower'))
                                % Struct/Member
                                out = [out sprintf('      <Struct Name="%s" Value="" Invisible="false" ForTest="false" Comment="">\r\n',portName)];
                                    out = [out sprintf('        <Member Name="CtlMod" Value="" Unit="" Invisible="false" ForTest="false" Comment="" />\r\n')];
                                    out = [out sprintf('        <Member Name="Crdn" Value="" Unit="" Invisible="false" ForTest="false" Comment="" />\r\n')];
                                    out = [out sprintf('        <Member Name="Ctkn" Value="" Unit="" Invisible="false" ForTest="false" Comment="" />\r\n')];
                                    out = [out sprintf('        <Member Name="IsInt" Value="" Unit="" Invisible="false" ForTest="false" Comment="" />\r\n')];
                                    out = [out sprintf('        <Member Name="DeltaE" Value="" Unit="" Invisible="false" ForTest="false" Comment="" />\r\n')];
                                out = [out sprintf('      </Struct>\r\n')];                           
                            else
                                out = [out sprintf('      <Param Name="%s" Value="0" Unit="" Invisible="false" ForTest="false" Comment="" />\r\n',portName)];
                            end% if
                            
                            indOutport = strcmp(get(prt(nPrt).DstBlock,'BlockType'),'Outport');
                            if any(indOutport)
                                prt(nPrt).DstBlock(indOutport);
                                for outportName = cellstr(get_param(prt(nPrt).DstBlock(indOutport),'Name'))';
                                    out = [out sprintf('      <InterChartConnection Pin="%s" Name="%s" />\r\n',portName,char(outportName))];
                                end% for
                            end% if
                            %
                            if ~isempty(chartNames) && any(strcmp(get(prt(nPrt).DstBlock,'Name'),chartNames))
                                outportName = find_system(prt(nPrt).DstBlock, ...
                                                        'LookUnderMasks','on','SearchDepth',1,'FollowLinks','on', ...
                                                        'BlockType','Inport', ...
                                                        'Port',sprintf('%d',prt(nPrt).DstPort+1));
                                outportName = get(outportName,'Name');
                                out = [out sprintf('      <InterChartConnection Pin="%s" Name="%s" />\r\n',portName,outportName)];         
                            end
                        end% if
                    end                    
                end
                nPrt = nPrt + 1;
            end% if
        end% for
        
        % close FB
        out = [out sprintf('      <Tasks MainTaskMode="Default" />\r\n')];
        out = [out sprintf('    </FB>\r\n')];
    end

% Export Simulink built-In Blocks
% LOGIC, ABS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
for blk = binBlocks'
   
   % Determine all necessary attributes
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   pos = get_param(char(blk),'Position');
   [PointY, PointX] = calcPos(pos);   
   %
   % Name
   Name = get_param(char(blk),'Name');
   % Remove whitespaces if necessary
   Name(regexp(Name,'\s'))=' ';
   %
   % ItemID
   ItemID = 0;
   %
   % BlockName
   BlockName = get_param(char(blk),'Name');
   % Remove whitespaces if necessary
   BlockName(regexp(BlockName,'\s'))=' ';   
   %
   % BlockNameTextRef
   BlockNameTextRef = '';
   %
   switch get_param(char(blk),'BlockType')
        case 'Abs'      , Typ = 'ABS_R' ;
        case 'Constant' , Typ = 'PAR_R' ;
        case 'Logic'
            switch get_param(char(blk),'operator')
                case 'OR'  , Typ = 'OR'    ;
                case 'AND' , Typ = 'AND'   ;
                otherwise  , Typ = ''      ;
            end
       otherwise , Typ = '';
   end% switch
   
   if (~isempty (Typ))
       %
       out = [out sprintf('    <FB PointX="%d" PointY="%d" Typ="%s" Name="%s" Comment="" ItemID="%d" BlockName="%s" BlockNameTextRef="%s" >\r\n', ...
          PointX,PointY,Typ,Name,ItemID,BlockName,BlockNameTextRef)];
       %
       % determine all IN- & OUT- ports
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       prt = get_param(char(blk),'PortConnectivity');
       %
       % INPORT
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % add "EN"-line
       out = [out sprintf('      <Param Name="EN" Value="1" Unit="" Invisible="true" ForTest="false" Comment="" />\r\n')];
       %
       nOutport = 1:max(find(strcmp({prt.Type},'1')))-1;
       for nPrt = nOutport
          if isempty(prt(nPrt).DstPort)
             if prt(nPrt).SrcBlock == -1
                fprintf(2,'\t ERROR: Block [%s] has unconnected Inport [In%s]\r\n',char(blk),prt(nPrt).Type);
                Errors = true;
             else
                switch get(prt(nPrt).SrcBlock,'BlockType')         
                    % Inport-Block
                    case 'Inport'
                       % INTERCHARTCONNECTION
                       outportName = get_param(prt(nPrt).SrcBlock,'Name');
                       portName = sprintf('IN%d',nPrt);
                       out = [out sprintf('      <Param Name="%s" Value="" Invisible="false" ForTest="false" Comment="" />\r\n',portName)];
                       out = [out sprintf('      <InterChartConnection Pin="In%s" Name="%s" />\r\n',prt(nPrt).Type,outportName)];            
                    % CONSTANT-Block
                    case 'Constant'
                       Value = eval(get(prt(nPrt).SrcBlock,'Value'));
                       portName = sprintf('IN%d',nPrt);                       
                       % Param
                       out = [out sprintf('      <Param Name="In%s" Value="%d" Invisible="false" ForTest="false" Comment="" />\r\n',portName,Value)];
                   % SubSystem
                    case 'SubSystem'
                       portName = sprintf('IN%d',nPrt);
                       out = [out sprintf('      <Param Name="%s" Value="" Invisible="false" ForTest="false" Comment="" />\r\n',portName)];
                    otherwise
                        portName = sprintf('IN%d',nPrt);
                        out = [out sprintf('      <Param Name="%s" Value="" Invisible="false" ForTest="false" Comment="" />\r\n',portName)];
                end
             end
          end
       end

       % OUTPORT
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       % add "ENO"-line
       out = [out sprintf('      <Param Name="ENO" Value="1" Unit="" Invisible="true" ForTest="false" Comment="" />\r\n')];
       %
       nOutport = max(find(strcmp({prt.Type},'1'))):numel(prt);
       for nPrt = nOutport   
          if isempty(prt(nPrt).SrcPort)
             if isempty(prt(nPrt).DstBlock)
                fprintf(2,'\t ERROR: Block [%s] has unconnected Outport [Out%s]\r\n',char(blk),prt(nPrt).Type);
                Errors = true;            
             else
             out = [out sprintf('      <Param Name="OUT" Value="" Invisible="false" ForTest="false" Comment="" />\r\n')];
             end% if
          end
       end
       %
       % close FB
       out = [out sprintf('    </FB>\r\n')];   
   end
end

% Export of comments and annotation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Notes = find_system(system,'findall','on','SearchDepth',1,'Type','annotation');
for nNote = Notes'
   pos = get_param(nNote,'Position');
   [PointY, PointX] = calcPos(pos);  
   
   txt = get_param(nNote,'Text');
   nLine = findstr(txt, char(10));
   
   SizeHeight = length(nLine) + 1;
   SizeWidth = max(nLine);
   
   if (SizeHeight == 1)
       SizeWidth = ceil(length(txt)/2)+1;
   else
       tLine = [0 nLine];
       nLine = [nLine length(txt)];
       res = nLine(1:length(nLine)) - tLine(1:length(nLine));
       SizeWidth = ceil(max(res)/2)+1;
   end
   
   c = get_param(nNote, 'BackgroundColor');
   c = round(str2num(c) * 255);
   c = c(3) + c(2)*256 + c(1)*256*256;
   c = c - 16777216;
   
   FontSize = get_param(nNote,'FontSize');
   if (FontSize == -1)
       FontSize = 10;
   end
   
   out = [out sprintf(['    <TextBlock Font="" FontSize="%d" TextColor="0" ' ...
      'Background="false" BackColor="%d" LineWidth="0" LineColor="0" ' ...
      'Autowrap="true" PointX="%d" PointY="%d" SizeHeight="%d" SizeWidth="%d" ' ...
      'Wallpaper="" WallpaperGamma="100">\r\n'], ...
      FontSize, c, PointX,PointY, SizeHeight, SizeWidth)];
   % replace control character
   out = [out sprintf('      <CDataComment><![CDATA[%s]]></CDataComment>\r\n',txt)];
   out = [out sprintf('    </TextBlock>\r\n')];
end% for

% Create LINK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hLine = find_system(system, ...
   'findall','on', ...
   'SearchDepth',1, ...
   'Type','Line', ...
   'LineChildren',[], ...
   'Connected','on');

% Export links between SubSystems
for nLine = 1:numel(hLine)
   SrcBlock = get(hLine(nLine),'SrcBlockHandle');
   DstBlock = get(hLine(nLine),'DstBlockHandle');
   %
   % Do not create links for subchart
   if isempty(chartNames) || ~any(strcmp(chartNames,get_param([DstBlock SrcBlock],'Name')))
      %
      % jump over if Src- or DstBlock is a NOT-Block
      if isempty(find_system([SrcBlock DstBlock],'Operator','NOT','BlockType','Logic'))
         if all(ismember(get_param([SrcBlock DstBlock],'BlockType'), ...
               {'Abs' 'Logic' 'SubSystem'}))
            %
            % Source
            % ------
            portNumber = get(get(hLine(nLine),'SrcPortHandle'),'PortNumber');
            outPort = find_system(SrcBlock, ...
               'FollowLinks','on','LookUnderMasks','on', ...
               'SearchDepth',1, ...
               'BlockType','Outport','Port',sprintf('%d',portNumber));
            StrSrcBlock = get(SrcBlock,'Name');
            StrSrcPin = get(outPort,'Name');
            if isempty(StrSrcPin)
               StrSrcPin = sprintf('OUT');
            end% if
            %
            % Destination
            % -----------
            portNumber = get(get(hLine(nLine),'DstPortHandle'),'PortNumber');
            inPort = find_system(DstBlock, ...
               'FollowLinks','on','LookUnderMasks','on', ...
               'SearchDepth',1, ...
               'BlockType','Inport','Port',sprintf('%d',portNumber));
            %
            StrDstBlock = get(DstBlock,'Name');
            StrDstPin = get(inPort,'Name');
            if isempty(StrDstPin)
               StrDstPin = sprintf('IN%d',portNumber);
            end% if
            %
            % Remove whitespaces if necessary
            StrSrcBlock(regexp(StrSrcBlock,'\s'))=' ';
            % Remove whitespaces if necessary
            StrDstBlock(regexp(StrDstBlock,'\s'))=' ';
            %
            out = [out sprintf('    <Link FromFBName="%s" FromPin="%s" ToFBName="%s" ToPin="%s" Negate="false" />\r\n', ...
               StrSrcBlock,StrSrcPin,StrDstBlock,StrDstPin)];
         end% if
      end% if
   end% if
end% for

% Export links between SubSystems with NOT-Operator in the line
hNot = find_system(system, ...
   'findall','on', ...
   'SearchDepth',1, ...
   'BlockType','Logic', ...
   'Operator','NOT');
for nNot = 1 : numel(hNot)
   ports = get_param(hNot(nNot),'PortConnectivity');
   SrcBlock = ports(1).SrcBlock;
   DstBlock = ports(2).DstBlock;
   if all(ismember(get_param([SrcBlock DstBlock],'BlockType'),{'Logic' 'SubSystem'}))
      % Source
      % ------
      outPort = find_system(SrcBlock, ...
         'FollowLinks','on','LookUnderMasks','on', ...
         'SearchDepth',1, ...
         'BlockType','Outport','Port',sprintf('%d',ports(1).SrcPort + 1));
      StrSrcBlock = get(SrcBlock,'Name');
      StrSrcPin = get(outPort,'Name');
      % Destination
      % -----------
      InPort = find_system(DstBlock, ...
         'FollowLinks','on','LookUnderMasks','on', ...
         'SearchDepth',1, ...
         'BlockType','Inport','Port',sprintf('%d',ports(2).DstPort + 1));
      StrDstBlock = get(DstBlock,'Name');
      StrDstPin = get(InPort,'Name');
      %
      out = [out sprintf('    <Link FromFBName="%s" FromPin="%s" ToFBName="%s" ToPin="%s" Negate="true" />\r\n', ...
         StrSrcBlock,StrSrcPin,StrDstBlock,StrDstPin)];
   end
end% for
%
out = [out sprintf('  </Chart>\r\n')];
out = [out sprintf('</AutomatedBuild>\r\n')];
%
% write XML file
fid = fopen(xmlFile,'w', 'l', 'UTF-8');
fwrite(fid,out);
fclose(fid);
%
%
% Import done
Send2GUI([' ^^^ Export done... ^^^'],h.status);
%
% catch me
%    Errors = true;
% end
end

function out = InitializeXMLHeader (system, x2max, y2max)
    global CFC_X_Rasterweite CFC_Y_Rasterweite;
    global VerticalChartPages HorizontalChartPages;
    global CFC_Y_PageSize CFC_X_PageSize MarginSize;

    ExpName = system;
    ExpName(max(find(ExpName=='/')))='@';
    ExpName(find(ExpName=='/'))='''';
    try 
        ObjectId    = get_param(system, 'ObjectId');
    catch
        ObjectId = '0';
    end
    
    try
        Task = get_param(system, 'Task');
        Task(max(find(Task=='''')))='';
        Task(min(find(Task=='''')))='';
    catch
        Task = 'OB1';
    end
    
    try
        Comment = get_param(system, 'Comment');
        Comment(max(find(Comment=='''')))='';
        Comment(min(find(Comment=='''')))='';
    catch
        Comment = '-';
    end   
    
    try
        Author = get_param(system, 'Author');
        Author(max(find(Author=='''')))='';
        Author(min(find(Author=='''')))='';        
    catch
        Author = '-';
    end
    
    try
        MarginSize = get_param(system, 'MarginSize');
    catch
        MarginSize = '15';
    end       
    
    try
        PageSize = get_param(system, 'PageSize');
        PageSize(max(find(PageSize=='''')))='';
        PageSize(min(find(PageSize=='''')))='';          
    catch
        PageSize = 'A3';
    end      
    
    % HorizontalChartPages
    switch PageSize
        case 'A5'
            CFC_X_PageSize = 106;
        case 'A4'
            CFC_X_PageSize = 150;
        otherwise
            CFC_X_PageSize = 212;
    end
    HorizontalChartPages = ceil(x2max / ((CFC_X_PageSize - (2*str2double(MarginSize)))*CFC_X_Rasterweite));
    HorizontalChartPages =  sprintf('%d', HorizontalChartPages);

    %VerticalChartPages
    switch PageSize
        case 'A5'
            CFC_Y_PageSize = 50;
        case 'A4'
            CFC_Y_PageSize = 70;
        otherwise
            CFC_Y_PageSize = 100;
    end
    VerticalChartPages = ceil(y2max / (CFC_Y_PageSize * CFC_Y_Rasterweite));
    VerticalChartPages =  sprintf('%d', VerticalChartPages);    
    
    try
        MarginLines = get_param(system, 'MarginLines');
    catch
        MarginLines = '1';
    end        

    try
        MarginMode = get_param(system, 'MarginMode');
        MarginMode(max(find(MarginMode=='''')))='';
        MarginMode(min(find(MarginMode=='''')))='';          
    catch
        MarginMode = 'FloatingMargins';
    end
    
    try
        Version = get_param(system, 'Version');
        Version(max(find(Version=='''')))='';
        Version(min(find(Version=='''')))='';          
    catch
        Version     = '0.1';
    end     
    
    out = sprintf( [ ...
                   '<?xml version="1.0" encoding="utf-16"?>\r\n' ...
                   '<AutomatedBuild xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ' ...
                   'xmlns:xsd="http://www.w3.org/2001/XMLSchema" SchemaVersion="1002">\r\n' ...
                   '  <Chart ObjectId="%s" Task="%s" Name="%s" Comment="%s" Author="%s" ' ...
                   'VerticalChartPages="%s" HorizontalChartPages="%s" MarginLines="%s" ' ...
                   'MarginMode="%s" MarginSize="%s" PageSize="%s" Version="%s" Option="false" Variant="false">\r\n' ...
                   ],ObjectId,Task,ExpName,Comment,Author,VerticalChartPages,HorizontalChartPages,MarginLines,MarginMode,MarginSize,PageSize,Version);
end

function [ItemID Typ] = getItemID (h, libTRA)
     
    Typ = get(h,'FunctionName');
    Typ = strrep(strrep(Typ,'_S1_SL',''),'_SL','');

    if any(cellfun(@(x) ~isempty(strfind(x,['/' Typ '_'])),libTRA))
        try
            ItemID = str2double(get_param (get_param (h, 'Parent'), 'ItemId'));
        catch
            ItemID = 0;
        end
    else
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TBD %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Send2GUI([' Block not found in TRA-library: [' char(blk) ']'],h.status);
        ItemID = 0;
    end% if
end

function [PointY PointX] = calcPos (pos)
    global CFC_Y_PageSize CFC_X_PageSize CFC_X_Rasterweite CFC_Y_Rasterweite MarginSize;
    
    if (length(pos) > 2)
        y1 = ceil(pos(2)/CFC_Y_Rasterweite);
        y2 = ceil(pos(4)/CFC_Y_Rasterweite);
        
        if (mod(y1, CFC_Y_PageSize) > mod(y2, CFC_Y_PageSize))
            PointY = y2 - mod(y2, CFC_Y_PageSize);
        else
            PointY = y1;
        end
    
        x1 = (ceil( pos(1) / CFC_X_Rasterweite) + str2double(MarginSize));
        x2 = (ceil( pos(3) / CFC_X_Rasterweite) + str2double(MarginSize));
    
        Page1 = (floor(x1 / CFC_X_PageSize)) * 2 * str2double(MarginSize);
        Page2 = (floor(x2 / CFC_X_PageSize)) * 2 * str2double(MarginSize);
        if (Page2 > Page1)
            PointX = Page2 + x1;
        else
            PointX = Page1 + x1;
        end
    else
        y1 = ceil(pos(2)/CFC_Y_Rasterweite);
        PointY = y1;
        x1 = (ceil( pos(1) / CFC_X_Rasterweite) + str2double(MarginSize));
        Page1 = (floor(x1 / CFC_X_PageSize)) * 2 * str2double(MarginSize);
        PointX = Page1 + x1 + 1;
    end
   
   
end