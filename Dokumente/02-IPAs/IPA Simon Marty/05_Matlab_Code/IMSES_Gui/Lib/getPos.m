function [pos] = getPos(ObjectName)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   (C) Copyright by Siemens Schweiz AG, Building Technologies Group,
%       HVAC Products, 2012
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Project                     : IMSES
%   Target Hardware             : PC 
%   Target Operating System     : WinXP Console
%   Language/Compiler           : Matlab 2010 and higher 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Workfile                    : getPos.m
%   Author                      : Thomas Rohr
%   Version                     : v1.0
%   Date                        : 20-Feb-2012
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Matlab Informations
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:
%   getPos Calculates the coordinates dependent on the block address 
%   The function scans the blocks that are already positioned
%   and calculates the coordinates of the next free space .
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function/Interface:
%	  
% Declaration:
%    [pos] = getPos(ObjectName)
%
% Inputs:
%    ObjectName   - The Blockadress
%
% Outputs:
%    pos	 	  - The calculatet coordinates as a vector [x1 y1 x2 y2]
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
%		----TopMargin-------
%		|                  |
%		|                  |
%   leftMargin        rightMargin
%		|                  |
%		|                  |
%		----BottomMargin----
%
%% Configurations  (unit = pixel)
    xMargin=50;
    yMargin=20;
    TopMargin       = 0;
    BottomMargin    = 600;
    % initialising xMaxPos=0;
    leftMargin      = 0;
    rightMargin     = 0;
       
    xBlockSize      = 170;
    yBlockSize      = 120;
    
    % initialising xColumnOffset
    xColumnOffset = 0;
    % initialising yRowOffset
    yRowOffset = 1;
   
    % left X-Margin
    xMargin=5;
    % upper Y-Margin
    yMargin=0;
    
%% Scaling Down
    ScalingFactor=10;
    
    TopMargin       = fix(    TopMargin/ScalingFactor);
    BottomMargin    = fix( BottomMargin/ScalingFactor);
    leftMargin      = fix(   leftMargin/ScalingFactor);
    rightMargin     = fix(  rightMargin/ScalingFactor);
    
    xBlockSize      = fix(   xBlockSize/ScalingFactor);
    yBlockSize      = fix(   yBlockSize/ScalingFactor);
    
%% Positioning    
    % delete the last position (example: 'R_2/BA/Rad01/Rad01' --> 'R_2/BA/Rad01')
    ObjectName = ObjectName(1:find(ObjectName=='/',1,'last')-1);
    %% find all Blocks inside the given System or Subsystem
    BlockList=find_system(ObjectName,'SearchDepth',1);
    %% define an array that is big enough
    % find the biggest x coordinate
    if length(BlockList)>=2
        for nBlockL=2:length(BlockList)
            temppos=get_param(BlockList{nBlockL},'position');
            rightMargin=max(rightMargin, fix(temppos(3)/ScalingFactor));
        end
    end
    BlockMap(BottomMargin+1,rightMargin+50+1)=0;
    %% map the Blocks to the BlockMap array        
    if length(BlockList)>=2
        for nBlockL=2:length(BlockList) 
            temppos=get_param(BlockList{nBlockL},'position');
            % scale down the raster
            temppos=fix(temppos/ScalingFactor);
             x1Map=temppos(1);x2Map=temppos(3);
             y1Map=temppos(2);y2Map=temppos(4);
            % map the blocks to the BlockMap array 
            % shifted by one position (+1)
            if y2Map < size(BlockMap,1)
                BlockMap(y1Map+1:y2Map+1,x1Map+1:x2Map+1)=1;
            end
        end
    end
    %% find the next free space were the block is fitting inside
    % (BlockOffset = upper left coordinate were is enough space and no other block)
    for xBlockOffset=1:size(BlockMap,2)
        for yBlockOffset=1:size(BlockMap,1)
            % define the array borders that will be proofed
            x1=xMargin+xColumnOffset;
            x2=x1+xBlockSize;
            y1=yMargin+yBlockOffset;
            y2=y1+yBlockSize;
            % if y2 is exceeding the border
            if (y2+yRowOffset) >= size(BlockMap,1)
                xColumnOffset=xColumnOffset+xBlockSize+5;
                break;
            end
            BlockMeanVal = mean(mean(BlockMap(y1:y2,x1:x2)));
            % if there is no other block in the array
            if BlockMeanVal == 0
                break; % jump out when Position is found 
            end
        end
        if BlockMeanVal == 0
           % add the RowOffset 
           y1=y1+yRowOffset; y2=y2+yRowOffset;             
           break; % jump out when Position is found 
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % calculating x2 and y2
    x2=x1+xBlockSize; y2=y1+yBlockSize;
    % scaling up the raster again 
    pos = [x1 y1 x2 y2]*ScalingFactor;
end

