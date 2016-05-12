clear all;
close all;
clc;

NODE_ID_1 = 2;
NODE_ID_2 = 7;
IDs_TO_CONSIDER = []; % set this to empty to select all IDs
%IDs_TO_CONSIDER = [2,3,4,9,11];
%IDs_TO_CONSIDER = [6, 3, 129, 2, 4, 1];
%IDs_TO_CONSIDER = [ 48, 50,  52,  72, 70, 51, 53,  58, 54, 57, 62, 61, 60, 56, 55, 75, 67, 65, 64, 68, 66, 49 ];
if isempty(IDs_TO_CONSIDER) 
    AMOUNT_OF_NODE = 25;
else
    AMOUNT_OF_NODE = length(IDs_TO_CONSIDER);
end
ANDROID = 1; %set this to 1 if the log has been performed with the android app
SHOW_BATTERY_VOLTAGE = 0; %if this is set to 1 the battery voltage info are plotted (and the packet counter info are discarded)
wsize_sec = 25;
winc_sec = 5;
%filename = 'D:/Drive/CLIMB/WIRELESS/LOG/TEST_FBK/LOGS/19_02_16/log_50_10.49.29.txt';
%filename = 'D:/Drive/CLIMB/WIRELESS/LOG/SECOND_TEST_2015_12_21/APP_LOG/MASTER/log_355_15.29.53.txt';
filename = 'D:/Drive/CLIMB/WIRELESS/LOG/TEMP/5187f1cf-a6f0-4e4a-a025-cb2fe52a1061_log_132_7.37.42.txt';
delimiter = ' ';
checkForNonIncrementedPacket = 1;
%% Format string for each line of text:
%   column1: double (%f)
%	column2: double (%f)
%   column3: double (%f)
%	column4: double (%f)
%   column5: double (%f)
%	column6: double (%f)
%   column7: double (%f)
%	column8: text (%s)
%   column9: text (%s)
%	column10: text (%s)
%   column12: text (%s)
% For more information, see the TEXTSCAN documentation.
if ANDROID == 1
    formatSpec = '%f%f%f%f%f%f%f%s%s%s%*s%s%[^\n\r]';
    TICK_DURATION = 0.001;
else
    formatSpec = '%d%s%s%s%s%s%[^\n\r]';
    TICK_DURATION = 0.00001;
end

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true,  'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Allocate imported array to column variable names
if ANDROID == 1
    TIME_S_Y = dataArray{:, 1};
    TIME_S_M = dataArray{:, 2};
    TIME_S_D = dataArray{:, 3};
    TIME_S_H = dataArray{:, 4};
    TIME_S_MIN = dataArray{:, 5};
    TIME_S_S = dataArray{:, 6};
    TIME_S_TICKS = dataArray{:, 7};
    SOURCE_ADD = dataArray{:, 8};
    SOURCE_NAME = dataArray{:, 9};
    DATA_TYPE = dataArray{:, 10};
    RAW_DATA = dataArray{:, 11};
else
    TIME_S_TICKS = dataArray{:, 1};
    SOURCE_ADD = dataArray{:, 2};
    SOURCE_NAME = dataArray{:, 3};
    DATA_TYPE = dataArray{:, 4};
    RAW_DATA = dataArray{:, 6};
end

%% Clear temporary variables
clearvars filename delimiter formatSpec fileID dataArray ans;


%% DATA ANALYSIS
GATT_DATA_TYPE = 'GATT';
ADV_DATA_TYPE = 'ADV';
TAG_DATA_TYPE = 'TAG';

% EXTRACT GATT RELATED DATA -- NOT USED
GATT_DATA.TIMESTAMP.TIME_S_Y = TIME_S_Y(strcmp(DATA_TYPE,GATT_DATA_TYPE));
GATT_DATA.TIMESTAMP.TIME_S_M = TIME_S_M(strcmp(DATA_TYPE,GATT_DATA_TYPE));
GATT_DATA.TIMESTAMP.TIME_S_D = TIME_S_D(strcmp(DATA_TYPE,GATT_DATA_TYPE));
GATT_DATA.TIMESTAMP.TIME_S_H = TIME_S_H(strcmp(DATA_TYPE,GATT_DATA_TYPE));
GATT_DATA.TIMESTAMP.TIME_S_MIN = TIME_S_MIN(strcmp(DATA_TYPE,GATT_DATA_TYPE));
GATT_DATA.TIMESTAMP.TIME_S_S = TIME_S_S(strcmp(DATA_TYPE,GATT_DATA_TYPE));
GATT_DATA.TIMESTAMP.TIME_S_TICKS = TIME_S_TICKS(strcmp(DATA_TYPE,GATT_DATA_TYPE));
GATT_DATA.SOURCE.ADDRESS = SOURCE_ADD(strcmp(DATA_TYPE,GATT_DATA_TYPE));
GATT_DATA.SOURCE.NAME = SOURCE_NAME(strcmp(DATA_TYPE,GATT_DATA_TYPE));
GATT_DATA.DATA = RAW_DATA(strcmp(DATA_TYPE,GATT_DATA_TYPE));

% EXTRACT TAG RELATED DATA -- NOT USED
TAG_DATA.TIMESTAMP.TIME_S_Y = TIME_S_Y(strcmp(DATA_TYPE,TAG_DATA_TYPE));
TAG_DATA.TIMESTAMP.TIME_S_M = TIME_S_M(strcmp(DATA_TYPE,TAG_DATA_TYPE));
TAG_DATA.TIMESTAMP.TIME_S_D = TIME_S_D(strcmp(DATA_TYPE,TAG_DATA_TYPE));
TAG_DATA.TIMESTAMP.TIME_S_H = TIME_S_H(strcmp(DATA_TYPE,TAG_DATA_TYPE));
TAG_DATA.TIMESTAMP.TIME_S_MIN = TIME_S_MIN(strcmp(DATA_TYPE,TAG_DATA_TYPE));
TAG_DATA.TIMESTAMP.TIME_S_S = TIME_S_S(strcmp(DATA_TYPE,TAG_DATA_TYPE));
TAG_DATA.TIMESTAMP.TIME_TICKS = TIME_S_TICKS(strcmp(DATA_TYPE,TAG_DATA_TYPE));
TAG_DATA.SOURCE.ADDRESS = SOURCE_ADD(strcmp(DATA_TYPE,TAG_DATA_TYPE));
TAG_DATA.SOURCE.NAME = SOURCE_NAME(strcmp(DATA_TYPE,TAG_DATA_TYPE));
TAG_DATA.DATA = RAW_DATA(strcmp(DATA_TYPE,TAG_DATA_TYPE));

% EXTRACT ADV RELATED DATA
% EXTRACT ADV RELATED DATA
if ANDROID == 1
    ADV_DATA.TIMESTAMP.TIME_TICKS = TIME_S_TICKS(strcmp(DATA_TYPE,ADV_DATA_TYPE));
    ADV_DATA.TIMESTAMP.TIME_S_S = TIME_S_S(strcmp(DATA_TYPE,ADV_DATA_TYPE));
    ADV_DATA.TIMESTAMP.TIME_S_MIN = TIME_S_MIN(strcmp(DATA_TYPE,ADV_DATA_TYPE));
    ADV_DATA.TIMESTAMP.TIME_S_H = TIME_S_H(strcmp(DATA_TYPE,ADV_DATA_TYPE));
    ADV_DATA.TIMESTAMP.TIME_S_D = TIME_S_D(strcmp(DATA_TYPE,ADV_DATA_TYPE));
    ADV_DATA.TIMESTAMP.TIME_S_M = TIME_S_M(strcmp(DATA_TYPE,ADV_DATA_TYPE));
    
else
    ADV_DATA.TIMESTAMP.TIME_TICKS = TIME_S_TICKS(strcmp(DATA_TYPE,ADV_DATA_TYPE));
end
ADV_DATA.SOURCE.ADDRESS = SOURCE_ADD(strcmp(DATA_TYPE,ADV_DATA_TYPE));
ADV_DATA.SOURCE.NAME = SOURCE_NAME(strcmp(DATA_TYPE,ADV_DATA_TYPE));
ADV_DATA.DATA = RAW_DATA(strcmp(DATA_TYPE,ADV_DATA_TYPE));

%% CREATE RSSI_MATRIX
RSSI_MATRIX = -Inf*double(ones(AMOUNT_OF_NODE+1,AMOUNT_OF_NODE+1,8900));%0;%uint32(0);
str = '';
timeSampleNo=1;

initialOffset = TAG_DATA.TIMESTAMP.TIME_TICKS(1);

for lineNo = 1:1:length(ADV_DATA.TIMESTAMP.TIME_TICKS)
    if strcmp(ADV_DATA.SOURCE.NAME{lineNo},'CLIMBC'); %ONLY CHILD NODES ADV DATA IS ANALYZED HERE
        if ~isempty(ADV_DATA.DATA{lineNo})
            RECEIVER_ID = sscanf(ADV_DATA.DATA{lineNo}(1:2),'%x'); %EXTRACT RECEIVER ID, RECEIVER IS INTENDED TO BE THE NODE THAT RECEIVES OTHER NODES ADV AND RETRANSMIT THEIR RSSI INFORMATION
            if sum(IDs_TO_CONSIDER == RECEIVER_ID) >= 1 || isempty(IDs_TO_CONSIDER);
                i = findNodeIndex(RSSI_MATRIX, RECEIVER_ID );
                if i > size(RSSI_MATRIX,1) %IF RECEIVER_ID IS NOT ALREADY IN THE MATRIX ADD IT
                    RSSI_MATRIX = addIDtoMatrix(RSSI_MATRIX,RECEIVER_ID);  %THIS RESIZES RSSI_MATRIX ADDING ONE LINE AND ONE COLUMN
                else
                    if(RSSI_MATRIX(i,1,1) == -Inf)
                        RSSI_MATRIX(i,1,:) = RECEIVER_ID.*ones(size(RSSI_MATRIX(i,1,:)));
                        RSSI_MATRIX(1,i,:) = RECEIVER_ID.*ones(size(RSSI_MATRIX(1,i,:)));
                    end
                end
                if(lineNo ~= 1 && timeSampleNo > size(RSSI_MATRIX,3))
                    RSSI_MATRIX = addTimeSample(RSSI_MATRIX); %EACH ADV PACKET IS TREATED AS A NEW SAMPLE, THEN ADD A NEW TIME SAMPLE (WHICH IS A TWO DIMENSION MATRIX)
                end
                %RSSI_MATRIX = addTimeSample(RSSI_MATRIX); %EACH ADV PACKET IS TREATED AS A NEW SAMPLE, THEN ADD A NEW TIME SAMPLE (WHICH IS A TWO DIMENSION MATRIX)
                RSSI_MATRIX(1,1,timeSampleNo) = ADV_DATA.TIMESTAMP.TIME_TICKS(lineNo) - initialOffset; %THE TIMESTAMP OF EACH SAMPLE IS ALWAYS STORED IN CELL RSSI_MATRIX(1,1,:). ITS UNIT IS MILLISECONDS
                if SHOW_BATTERY_VOLTAGE == 1 %TODO
                    RSSI_MATRIX(i,i,timeSampleNo) = uint32( sscanf(ADV_DATA.DATA{lineNo}(end-5:end-2),'%x')); %BATTERY VOLTAGE IS ALWAYS STORED IN THE DIAGONAL RSSI_MATRIX(index_of_RECEIVER_ID,index_of_RECEIVER_ID,: )
                else
                    RSSI_MATRIX(i,i,timeSampleNo) = uint8( sscanf(ADV_DATA.DATA{lineNo}(end-1:end),'%x')); %ADV PKT COUNTER IS ALWAYS STORED IN THE DIAGONAL RSSI_MATRIX(index_of_RECEIVER_ID,index_of_RECEIVER_ID,: )
                end
                for advDataIdx = 5:4:(numel(ADV_DATA.DATA{lineNo})-6) %FIND ALL SENDERS HEARED BY THIS NODE

                    SENDER_ID = sscanf(ADV_DATA.DATA{lineNo}(advDataIdx:advDataIdx+1),'%x');
                    if (SENDER_ID ~= 0) && ( sum(IDs_TO_CONSIDER == SENDER_ID) >= 1 || isempty(IDs_TO_CONSIDER))%ZERO ID IS NOT VALID!
                             j = findNodeIndex(RSSI_MATRIX, SENDER_ID );
                        if j > size(RSSI_MATRIX,1) %IF SENDER_ID IS NOT ALREADY IN THE MATRIX ADD IT
                            RSSI_MATRIX = addIDtoMatrix(RSSI_MATRIX,SENDER_ID); %THIS RESIZES RSSI_MATRIX ADDING ONE LINE AND ONE COLUMN
                        else
                            if(RSSI_MATRIX(j,1,1) == -Inf)
                                RSSI_MATRIX(j,1,:) = SENDER_ID.*ones(size(RSSI_MATRIX(j,1,:)));
                                RSSI_MATRIX(1,j,:) = SENDER_ID.*ones(size(RSSI_MATRIX(1,j,:)));
                            end
                        end
                        RSSI_MATRIX(i,j,timeSampleNo) =  double( typecast( uint8(sscanf(ADV_DATA.DATA{lineNo}(advDataIdx+2:advDataIdx+3),'%x')) ,'int8') ); %STORE RSSI VALUE IN THE PROPPER POSITION
                    end
                end
                timeSampleNo = timeSampleNo + 1 ;
            end
       end
    end
end
%delete unused part of RSSI_MATRIX
RSSI_MATRIX = RSSI_MATRIX(RSSI_MATRIX(:,1,1) ~= -Inf,RSSI_MATRIX(1,:,1) ~= -Inf,:);
AVAILABLE_IDs = RSSI_MATRIX(2:end,1,1);

fprintf('RSSI Matrix created!\n');


if SHOW_BATTERY_VOLTAGE == 1
    %% BATTERY CHECK (TODO)
else
    %% PACKET CHECK
    packetStat = zeros(size(RSSI_MATRIX,1)-1,4); %column 1: ID, column 2: received packets, column 3: missing packets, column 4: double received packets
    packetStat(:,1) = RSSI_MATRIX(2:end,1,end);
    isFirst = 1;
    sampleNo = 1;
    
    for lineNo = 2:1:size(RSSI_MATRIX,1) %SELECT A LINE, THAT MEANS: SELECT A RECEIVER ID
        if RSSI_MATRIX(lineNo,1,1) ~= -Inf
            while sampleNo <= size(RSSI_MATRIX,3) %ANALYZE ALL TIMESAMPLES
                if RSSI_MATRIX(lineNo,lineNo,sampleNo) ~= -Inf %IF ADV PKT COUNTER IS inf IT MEANS THAT THIS TIMESAMPLE IS RELATED TO ANOTHER RECEIVER, THEN DISCARD IT
                    
                    if isFirst == 1 %IF IT IS THE FIRST SAMPLE FOR THIS RECEIVER STORE THE ACTUAL ADV PKT COUNTER, THE NEXT ONE SHOULD BE ACTUAL ADV PKT INDEX + 1
                        packetStat(lineNo-1,2) = packetStat(lineNo-1,2) + 1; %INCREMENT TOTAL PACKETS COUNTER
                        nextExpected = RSSI_MATRIX(lineNo,lineNo,sampleNo) + 1;
                        sampleNo = sampleNo + 1;
                        isFirst = 0;
                    else
                        if RSSI_MATRIX(lineNo,lineNo,sampleNo) == nextExpected %THE COUNTER IS WHAT IS EXPECTED
                            %nextExpected = RSSI_MATRIX(lineNo,lineNo,sampleNo) + 1; %SET THE NEW EXPECTED VALUE
                            packetStat(lineNo-1,2) = packetStat(lineNo-1,2) + 1; %INCREMENT TOTAL PACKETS COUNTER
                            sampleNo = sampleNo + 1;
                            nextExpected = nextExpected + 1;
                        elseif RSSI_MATRIX(lineNo,lineNo,sampleNo) == nextExpected-1 %NB: SOMETIMES ADV PKT COUNTER IS NOT INCREMENTED BY THE NODE, DON'T KNOW WHY...
                            
                            if checkForNonIncrementedPacket %%ALLOW NON INCREMENTED PACKET CHECK
                                %if RSSI_MATRIX(1,1,sampleNo)-RSSI_MATRIX(1,1,sampleNo-1) < 500%1000 % 1000 = 10ms (the same packet can be received on two different adv channels only if they have very similar timestamp)
                                    packetStat(lineNo-1,4) = packetStat(lineNo-1,4) + 1;
                                    sampleNo = sampleNo + 1;
                                %else
                                %    error('Two identical packets, too close to each other, has been found!!!');
                                %end
                            else %%DON'T ALLOW NON INCREMENTED PACKET
                                packetStat(lineNo-1,3) = packetStat(lineNo-1,3) + 1; %IF COUNTER IS DIFFERENT FROM WHAT IS EXPECTED, INCREMENT ERROR COUNTER
                            end
                            
                        else % THE COUNTER IS NOT WHAT IS EXPECTED
                            packetStat(lineNo-1,3) = packetStat(lineNo-1,3) + 1; %IF COUNTER IS DIFFERENT FROM WHAT IS EXPECTED, INCREMENT ERROR COUNTER
                            nextExpected = nextExpected + 1;
                        end
                    end
                    
                    if nextExpected == 256 %REMEMBER THAT EACH FIELD IN ADV PKT IS 8 BIT UNSIGNED INTEGER
                        nextExpected = 0;
                    end
                    
                else
                    sampleNo = sampleNo + 1; %IF THE SAMPLE IS NOT VALID GO TO THE NEXT ONE
                end
            end
        end
        sampleNo = 1;
        isFirst = 1;
    end
    
    fprintf('Packet check statistics:\n');
    fprintf('Node ID | received packets | missing packets | PEr\n');
    for nodeNo = 1 : length(packetStat)
        fprintf('%02X      | %d               | %d              | %.2f %%\n',packetStat(nodeNo,1), packetStat(nodeNo,2), packetStat(nodeNo,3) ,  packetStat(nodeNo,3) / (packetStat(nodeNo,2) + packetStat(nodeNo,3))*100 );
    end
end

%% EXTRACT TAG DATA CREATING A TIME ARRAY AND A DATA ARRAY
T_TAG = double.empty;
DATA_TAG = double.empty;
for lineNo = 1:1:length(TAG_DATA.TIMESTAMP.TIME_S_Y) 
    
    T_TAG = cat(1,T_TAG,TAG_DATA.TIMESTAMP.TIME_TICKS(lineNo));
    DATA_TAG = cat(1,DATA_TAG,TAG_DATA.DATA(lineNo));

end
T_TAG = T_TAG - initialOffset;

%% ANALYZE RELATIONS BETWEEN NODES
graphEdeges_RSSI = double.empty;
links=double.empty;
t_w=double.empty;

% graphEdeges_RSSI_2to1 = double.empty;
% graphEdeges_RSSI_1to2 = double.empty;
% t_2to1=double.empty;
% t_1to2=double.empty;
% relations2to1=double.empty;
% relations1to2=double.empty;

wsize = wsize_sec / TICK_DURATION;
winc = winc_sec / TICK_DURATION;
colorlist=hsv( (size(RSSI_MATRIX,1)^2-2*(size(RSSI_MATRIX,1)-1)-size(RSSI_MATRIX,1))/2 );
i=1;
focusId1 = findNodeIndex(RSSI_MATRIX, NODE_ID_1 );
focusId2 = findNodeIndex(RSSI_MATRIX, NODE_ID_2 );
emptySignalsCount = 0;
signalsCount = 0;
for i_id_1 = 2:1:size(RSSI_MATRIX,1)
    for i_id_2 = i_id_1+1:size(RSSI_MATRIX,2)
                
        T_2to1 = double.empty;
        T_1to2 = double.empty;
        RSSI_Signal_2to1 = double.empty;
        RSSI_Signal_1to2 = double.empty;
        for sampleIndex = 1:1:size(RSSI_MATRIX,3)
            
            if RSSI_MATRIX(i_id_1,i_id_2,sampleIndex) ~= -Inf
                RSSI_Signal_2to1 = cat(1,RSSI_Signal_2to1,RSSI_MATRIX(i_id_1,i_id_2,sampleIndex));
                T_2to1 = cat(1,T_2to1,RSSI_MATRIX(1,1,sampleIndex));
            end
            
            if RSSI_MATRIX(i_id_2,i_id_1,sampleIndex) ~= -Inf
                RSSI_Signal_1to2 = cat(1,RSSI_Signal_1to2,RSSI_MATRIX(i_id_2,i_id_1,sampleIndex));
                T_1to2 = cat(1,T_1to2,RSSI_MATRIX(1,1,sampleIndex));
            end
            
        end
        
        if (size(T_2to1,1) > 1) || (size(T_1to2,1) > 1) %let's try with 'or'
            RSSI_Signal_W = timeBasedTwoDirectionsMerge(T_2to1, RSSI_Signal_2to1, T_1to2, RSSI_Signal_1to2, wsize, winc);
            if size(T_2to1,1) <= 1
                T_W = ( (1:1:size(RSSI_Signal_W,1))*winc + double(T_1to2(1)) )';
            elseif size(T_1to2,1) <= 1
                T_W = ( (1:1:size(RSSI_Signal_W,1))*winc + double(T_2to1(1)) )';
            else
                T_W = ( (1:1:size(RSSI_Signal_W,1))*winc + double(min(T_2to1(1),T_1to2(1))) )';
            end
            if(focusId1 == i_id_1 && focusId2 == i_id_2) || (focusId1 == i_id_2 && focusId2 == i_id_1)
                figure;
                plot(T_W*TICK_DURATION,RSSI_Signal_W,T_2to1*TICK_DURATION,RSSI_Signal_2to1,'-.',T_1to2*TICK_DURATION,RSSI_Signal_1to2,'-.');
                legend('merged-filtered-resampled','2to1','1to2');
                xlabel('Time [s]');
                ylabel('RSSI [dBm]');
                grid on;
                title('RSSI between FOCUS ID1 and FOCUS ID2')
                
            end
            
            if isempty(t_w) %% this is run only once at the first iteration of the nested loops
                graphEdeges_RSSI = RSSI_Signal_W;
                t_w = T_W;
                links = [RSSI_MATRIX(1,i_id_1,1); RSSI_MATRIX(1,i_id_2,1)];
            else
                if ((t_w(1) - winc) >= T_W(1)) || (T_W(end) > (t_w(end) )) %%the T_W values are not contained within t_w
                    if (t_w(1) - winc) >= T_W(1) %%the current T_2to1_W array starts before t_2to1 array
                        %%RESIZE t VECTOR
                        t_temp = t_w(1):-winc:T_W(1);
                        t_w = cat(1,t_temp',t_w);
                        
                        graphEdeges_RSSI_temp = ones(size(t_w,1),size(graphEdeges_RSSI,2)+1) * (-Inf);
                        graphEdeges_RSSI_temp( size(t_temp,1)+1:end,1:size(graphEdeges_RSSI,2) ) = graphEdeges_RSSI;
                        
                        %%if the new data array starts before and ends
                        %%after the old data copy only the first part, the
                        %%remaining part will be copied in the next 'if'
                        if( size(RSSI_Signal_W,1) <= size(graphEdeges_RSSI_temp,1) )
                            graphEdeges_RSSI_temp(1:size(RSSI_Signal_W,1),end) = RSSI_Signal_W;
                        else
                            graphEdeges_RSSI_temp(1:end,end) = RSSI_Signal_W(1:size(graphEdeges_RSSI_temp,1));
                        end
                        graphEdeges_RSSI = graphEdeges_RSSI_temp;
                    end
                    
                    if T_W(end) > (t_w(end) ) %%the current T_2to1_W array finishes after t_2to1 array
                        %%RESIZE t VECTOR
                        t_temp = t_w(end):winc:T_W(end);
                        t_w = cat(1,t_w,t_temp');
                        
                        graphEdeges_RSSI_temp = ones(size(t_w,1),size(graphEdeges_RSSI,2)+1) * (-Inf);
                        %graphEdeges_RSSI_temp( 1:(size(t_w,1)-size(t_temp,1)) ,1:size(graphEdeges_RSSI,2) ) = graphEdeges_RSSI;
                        graphEdeges_RSSI_temp( 1:size(graphEdeges_RSSI,1) ,1:size(graphEdeges_RSSI,2) ) = graphEdeges_RSSI;
                        graphEdeges_RSSI_temp(end-size(RSSI_Signal_W,1)+1 : end,end) = RSSI_Signal_W;
                        graphEdeges_RSSI = graphEdeges_RSSI_temp;
                        
                    end
                else
                    graphEdeges_RSSI_temp = ones(size(t_w,1),size(graphEdeges_RSSI,2)+1) * (-Inf);
                    graphEdeges_RSSI_temp(1:end,1:end-1) = graphEdeges_RSSI;
                    tmp = abs(t_w-T_W(1));
                    [ ~ , startingindex] = min(tmp);
                    graphEdeges_RSSI_temp(startingindex:startingindex+length(RSSI_Signal_W)-1,end) = RSSI_Signal_W;
                    graphEdeges_RSSI = graphEdeges_RSSI_temp;
                end
                links = cat(2,links, [RSSI_MATRIX(1,i_id_1,1); RSSI_MATRIX(1,i_id_2,1)]);
            end
            
            figure(100)
            plot(t_w*TICK_DURATION,graphEdeges_RSSI(:,end),'col',colorlist(i,:))
            hold on;
            signalsCount = signalsCount + 1;
        else
            emptySignalsCount = emptySignalsCount + 1;
        end
%         %% rssi data for packets sent from node 2 to node 1
%         if length(T_2to1) > 1
%             
%             RSSI_Signal_2to1_W = timeBasedSlidingAvg(T_2to1, RSSI_Signal_2to1, wsize, winc);
%             T_2to1_W = ((1:1:size(RSSI_Signal_2to1_W,1))*winc + T_2to1(1))';
%             
%             if(focusId1 == i_id_1 && focusId2 == i_id_2)
%                 figure;
%                 plot(T_2to1_W,RSSI_Signal_2to1_W);
%                 grid on;
%                 title('Filtered RSSI for packets sent by FOCUS ID2 and received by FOCUS ID1')
%                 
%                 figure;
%                 plot(T_2to1,RSSI_Signal_2to1);
%                 grid on;
%                 title('Raw RSSI for packets sent by FOCUS ID2 and received by FOCUS ID1')
%                 
%                 output = timeBasedSlidingAvg2dim(T_2to1, RSSI_Signal_2to1, T_1to2, RSSI_Signal_1to2, wsize, winc);
%                 T_output = ((1:1:size(output,1))*winc + min(T_2to1(1),T_1to2(1)))';
%                  
%                 figure;
%                 plot(T_output,output);
%                 grid on;
%                 title('timeBasedSlidingAvg2dim')
%             end
%             
%             if isempty(t_2to1) %% this is run only once at the first iteration of the nested loops
%                 graphEdeges_RSSI_2to1 = RSSI_Signal_2to1_W;
%                 t_2to1 = T_2to1_W;
%                 relations2to1 = [RSSI_MATRIX(1,i_id_1,1); RSSI_MATRIX(1,i_id_2,1)];
%             else
%                 if ((t_2to1(1) - winc) >= T_2to1_W(1)) || (T_2to1_W(end) > (t_2to1(end) )) %%the T_2to1_W values are not contained within t_2to1 boundaries
%                     if (t_2to1(1) - winc) >= T_2to1_W(1) %%the current T_2to1_W array starts before t_2to1 array
%                         %%RESIZE t VECTOR
%                         t_temp = t_2to1(1):-winc:T_2to1_W(1);
%                         t_2to1 = cat(1,t_temp',t_2to1);
%                         
%                         graphEdeges_RSSI_temp = ones(size(t_2to1,1),size(graphEdeges_RSSI_2to1,2)+1) * (-inf);
%                         graphEdeges_RSSI_temp( size(t_temp,1)+1:end,1:size(graphEdeges_RSSI_2to1,2) ) = graphEdeges_RSSI_2to1;
%                         
%                         %%if the new data array starts before and ends
%                         %%after the old data copy only the first part, the
%                         %%remaining part will be copied in the next 'if'
%                         if( size(RSSI_Signal_2to1_W,1) <= size(graphEdeges_RSSI_temp,1) )
%                             graphEdeges_RSSI_temp(1:size(RSSI_Signal_2to1_W,1),end) = RSSI_Signal_2to1_W;
%                         else
%                             graphEdeges_RSSI_temp(1:end,end) = RSSI_Signal_2to1_W(1:size(graphEdeges_RSSI_temp,1));
%                         end
%                         graphEdeges_RSSI_2to1 = graphEdeges_RSSI_temp;
%                     end
%                     
%                     if T_2to1_W(end) > (t_2to1(end) ) %%the current T_2to1_W array finishes after t_2to1 array
%                         %%RESIZE t VECTOR
%                         t_temp = t_2to1(end):winc:T_2to1_W(end) ;
%                         t_2to1 = cat(1,t_2to1,t_temp');
%                         
%                         graphEdeges_RSSI_temp = ones(size(t_2to1,1),size(graphEdeges_RSSI_2to1,2)+1) * (-inf);
%                         graphEdeges_RSSI_temp( 1:(size(t_2to1,1)-size(t_temp,1)) ,1:size(graphEdeges_RSSI_2to1,2) ) = graphEdeges_RSSI_2to1;
%                         graphEdeges_RSSI_temp(end-size(RSSI_Signal_2to1_W,1)+1 : end,end) = RSSI_Signal_2to1_W;
%                         graphEdeges_RSSI_2to1 = graphEdeges_RSSI_temp;
%                         
%                     end
%                 else
%                     graphEdeges_RSSI_temp = ones(size(t_2to1,1),size(graphEdeges_RSSI_2to1,2)+1) * (-inf);
%                     graphEdeges_RSSI_temp(1:end,1:end-1) = graphEdeges_RSSI_2to1;
%                     tmp = abs(t_2to1-T_2to1_W(1));
%                     [ ~ , startingindex] = min(tmp);
%                     graphEdeges_RSSI_temp(startingindex:startingindex+length(RSSI_Signal_2to1_W)-1,end) = RSSI_Signal_2to1_W;
%                     graphEdeges_RSSI_2to1 = graphEdeges_RSSI_temp;
%                 end
%                 relations2to1 = cat(2,relations2to1, [RSSI_MATRIX(1,i_id_1,1); RSSI_MATRIX(1,i_id_2,1)]);
%             end
%             
%             figure(100)
%             plot(t_2to1,graphEdeges_RSSI_2to1(:,end),'col',colorlist(i,:))
%             hold on;
%         end
%         
%         
%        %% rssi data for packets sent from node 1 to node 2 
%         if length(T_1to2) > 1
%             
%             RSSI_Signal_1to2_W = timeBasedSlidingAvg(T_1to2, RSSI_Signal_1to2, wsize, winc);
%             T_1to2_W = ((1:1:size(RSSI_Signal_1to2_W,1))*winc + T_1to2(1))';
%             
%             if(focusId1 == i_id_1 && focusId2 == i_id_2)
%                 figure;
%                 plot(T_1to2_W,RSSI_Signal_1to2_W);
%                 grid on;
%                 title('Filtered RSSI for packets sent by FOCUS ID1 and received by FOCUS ID2')
%                 
%                 figure;
%                 plot(T_1to2,RSSI_Signal_1to2);
%                 grid on;
%                 title('Raw RSSI for packets sent by FOCUS ID1 and received by FOCUS ID2')
%             end
%             
%             if isempty(t_1to2) %% this is run only once at the first iteration of the nested loops
%                 graphEdeges_RSSI_1to2 = RSSI_Signal_1to2_W;
%                 t_1to2 = T_1to2_W;
%                 relations1to2 = [RSSI_MATRIX(1,i_id_1,1); RSSI_MATRIX(1,i_id_2,1)];
%             else
%                 if ((t_1to2(1) - winc) >= T_1to2_W(1)) || (T_1to2_W(end) > (t_1to2(end) )) %%the T_1to2_W values are not contained within t_1to2 boundaries
%                     if (t_1to2(1) - winc) >= T_1to2_W(1) %%the current T_1to2_W array starts before t_1to2 array
%                         %%RESIZE t VECTOR
%                         t_temp = t_1to2(1):-winc:T_1to2_W(1);
%                         t_1to2 = cat(1,t_temp',t_1to2);
%                         
%                         graphEdeges_RSSI_temp = ones(size(t_1to2,1),size(graphEdeges_RSSI_1to2,2)+1) * (-inf);
%                         graphEdeges_RSSI_temp( size(t_temp,1)+1:end,1:size(graphEdeges_RSSI_1to2,2) ) = graphEdeges_RSSI_1to2;
%                         
%                         %%if the new data array starts before and ends
%                         %%after the old data copy only the first part, the
%                         %%remaining part will be copied in the next 'if'
%                         if( size(RSSI_Signal_1to2_W,1) <= size(graphEdeges_RSSI_temp,1) )
%                             graphEdeges_RSSI_temp(1:size(RSSI_Signal_1to2_W,1),end) = RSSI_Signal_1to2_W;
%                         else
%                             graphEdeges_RSSI_temp(1:end,end) = RSSI_Signal_1to2_W(1:size(graphEdeges_RSSI_temp,1));
%                         end
%                         graphEdeges_RSSI_1to2 = graphEdeges_RSSI_temp;
%                     end
%                     
%                     if T_1to2_W(end) > (t_1to2(end) ) %%the current T_1to2_W array finishes after t_1to2 array
%                         %%RESIZE t VECTOR
%                         t_temp = t_1to2(end):winc:T_1to2_W(end) ;
%                         t_1to2 = cat(1,t_1to2,t_temp');
%                         
%                         graphEdeges_RSSI_temp = ones(size(t_1to2,1),size(graphEdeges_RSSI_1to2,2)+1) * (-inf);
%                         graphEdeges_RSSI_temp( 1:(size(t_1to2,1)-size(t_temp,1)) ,1:size(graphEdeges_RSSI_1to2,2) ) = graphEdeges_RSSI_1to2;
%                         graphEdeges_RSSI_temp(end-size(RSSI_Signal_1to2_W,1)+1 : end,end) = RSSI_Signal_1to2_W;
%                         graphEdeges_RSSI_1to2 = graphEdeges_RSSI_temp;
%                         
%                     end
%                 else
%                     graphEdeges_RSSI_temp = ones(size(t_1to2,1),size(graphEdeges_RSSI_1to2,2)+1) * (-inf);
%                     graphEdeges_RSSI_temp(1:end,1:end-1) = graphEdeges_RSSI_1to2;
%                     tmp = abs(t_1to2-T_1to2_W(1));
%                     [ ~ , startingindex] = min(tmp);
%                     graphEdeges_RSSI_temp(startingindex:startingindex+length(RSSI_Signal_1to2_W)-1,end) = RSSI_Signal_1to2_W;
%                     graphEdeges_RSSI_1to2 = graphEdeges_RSSI_temp;
%                 end
%                 relations1to2 = cat(2,relations1to2, [RSSI_MATRIX(1,i_id_1,1); RSSI_MATRIX(1,i_id_2,1)]);
%             end
%             
%             figure(101)
%             plot(t_1to2,graphEdeges_RSSI_1to2(:,end),'col',colorlist(i,:))
%             hold on;
%         end
        
       i = i+1;
    end
end

figure(100)
grid on;
plot(T_TAG*TICK_DURATION,ones(size(T_TAG))*(-100),'ro');
xlabel('Time [s]');
ylabel('RSSI [dBm]');
title('All links');
hold off;


% t_w = double(t_w)/(60);
% T_TAG = double(T_TAG)/(60);

t_zero = T_TAG(2);%min([T_TAG(15);T_id_1]);
T_TAG = T_TAG - t_zero;
t_w = t_w - double(t_zero);

% NOTE: graphEdeges_RSSI is already filtered with sliding window 
graphEdeges_m = RSSI_to_m(graphEdeges_RSSI);

figure(200)
plot(T_TAG*TICK_DURATION,zeros(size(T_TAG)),'ro', t_w*TICK_DURATION, graphEdeges_m);
xlabel('Time [s]');
ylabel('distance [m]');
legend('TAGs','distance');
title('All links');
grid on;
hold off;

fprintf('Click on the analysis bounds!\n');
[x1,~] = ginput(1);
[x2,~] = ginput(1);
if x1 > x2 
    xstop = x1/TICK_DURATION;
    xstart = x2/TICK_DURATION;
else
    xstop = x2/TICK_DURATION;
    xstart = x1/TICK_DURATION;
end

tmp = abs(t_w - xstart);
[ ~ , xstart_index] = min(tmp);
tmp = abs(t_w - xstop);
[ ~ , xstop_index] = min(tmp);
 
% xstart_index = 1;
% xstop_index = length(graphEdeges_m)-1;


nodePositionXY = zeros(length(AVAILABLE_IDs),3,xstop_index-xstart_index);
nodePositionIndex = 1;
for timeIndexNo = xstart_index : xstop_index
    createDOTdescriptionFile( graphEdeges_m(timeIndexNo,:), links , '../output/output_m.dot');
    [status,cmdout] = dos('neato -Tplain ../output/output_m.dot');
    if status == 0
        textLines = textscan(cmdout, '%s','delimiter', '\n');
        
        for textLineNo = 2:length(textLines{1})
            tLine = sscanf( char(textLines{1}(textLineNo)),'%s %d %f %f');
            if( tLine(1) == 'n' && tLine(2) == 'o' && tLine(3) == 'd' && tLine(4) == 'e')
                k = findNodeIndex(RSSI_MATRIX(:,:,1), tLine(5) );
                nodePositionXY(k-1,:,nodePositionIndex) = tLine(5:7)';
            end
        end
        
        nodePositionIndex = nodePositionIndex + 1;
        
    end
end

figure(205)
filename = '../output/output_Animation.gif';
fps = 1/winc_sec*10;
colorlist2 = hsv( size(nodePositionXY,1) );
for timeIndexNo = 1 : size(nodePositionXY,3)
    nodePositionXY_temp = nodePositionXY(nodePositionXY(:,1,timeIndexNo) ~= 0,:, timeIndexNo);
    plot(nodePositionXY_temp(:,2),nodePositionXY_temp(:,3),'o','LineWidth',3);
    xlabel('[m]?');
    ylabel('[m]?');
    grid on;
    for nodeNo = 1 : length(nodePositionXY_temp)
        str = sprintf('%d',nodePositionXY_temp(nodeNo,1));
        text(nodePositionXY_temp(nodeNo,2)+3,nodePositionXY_temp(nodeNo,3),str,'Color',colorlist2(nodeNo,:),'FontSize',14,'FontWeight','bold');
    end
    str = sprintf('Time = %d, showed %d nodes',xstart_index+timeIndexNo*winc_sec,nodeNo);
    text(-90,90,str,'FontSize',15,'FontWeight','bold');
    axis([-100 100 -100 100]);
    
    drawnow
    frame = getframe(205);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if timeIndexNo == 1;
        imwrite(imind,cm,filename,'gif', 'Loopcount',Inf,'delaytime',1/fps);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append','delaytime',1/fps);
    end
end


