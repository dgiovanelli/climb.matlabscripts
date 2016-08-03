clear all;
close all;
%clc;

FOCUS_ID_1 = 161;
FOCUS_ID_2 = 167;
IDs_TO_CONSIDER = [161, 162, 163, 164, 165, 166, 167];%161:1:167; % set this to empty to select all IDs
%IDs_TO_CONSIDER = [2,3,4,9,11];
%IDs_TO_CONSIDER = [6, 3, 129, 2, 4, 1];
%IDs_TO_CONSIDER = [ 48, 50,  52,  72, 70, 51, 53,  58, 54, 57, 62, 61, 60, 56, 55, 75, 67, 65, 64, 68, 66, 49 ];
if isempty(IDs_TO_CONSIDER) 
    AMOUNT_OF_NODE = 30;
else
    AMOUNT_OF_NODE = length(IDs_TO_CONSIDER);
end
ANDROID = 1; %set this to 1 if the log has been performed with the android app
SHOW_BATTERY_VOLTAGE = 0; %if this is set to 1 the battery voltage info are plotted (and the packet counter info are discarded)
PLOT_NODE_LABELS = 1; %setting this to 1 node labels are removed from plot, and the master node is plotted in red
CENTER_ON_ID = 161; %the plot will be centered on this node. Set to zero to free layouts
LAYOUT_ALGORITHM = 2; %select the algorithm to use ( 0 -> neato, 1 -> MDS, 2 -> Mesh relaxation
wsize_sec = 7;
winc_sec = 0.2;
F_filt = 0.5; %filter cut off frequency [Hz]. Set this to 0 to disable filtering
n_filt = 2;
TREAT_AS_STATIC = 1; %when this is set to 1 the link length signals are averaged over the whole test (ignoring Infs)

% RSSI to m conversion parameters
k_TF_1= [-16.0845];
txPwr_10m_1 = -57.9715;

%filename = 'D:/Drive/CLIMB/WIRELESS/LOG/TEST_FBK/LOGS/19_02_16/log_50_10.49.29.txt';
%filename = 'D:/Drive/CLIMB/WIRELESS/LOG/SECOND_TEST_2015_12_21/APP_LOG/MASTER/log_355_11.11.3.txt';
filename = 'D:/Drive/CLIMB/WIRELESS/LOG/LOCALIZATION/LOGS/log_139_18.55.27.txt';

delimiter = ' ';
CHECK_FOR_NOT_INCREMENTED_COUNTER = 1;
%% Format string for each line of text:
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
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true,  'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

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

%% DATA UNPACKING
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
if ANDROID == 1
    GATT_DATA.TIMESTAMP.TIME_TICKS = TIME_S_TICKS(strcmp(DATA_TYPE,GATT_DATA_TYPE));
    GATT_DATA.TIMESTAMP.TIME_S_S = TIME_S_S(strcmp(DATA_TYPE,GATT_DATA_TYPE));
    GATT_DATA.TIMESTAMP.TIME_S_MIN = TIME_S_MIN(strcmp(DATA_TYPE,GATT_DATA_TYPE));
    GATT_DATA.TIMESTAMP.TIME_S_H = TIME_S_H(strcmp(DATA_TYPE,GATT_DATA_TYPE));
    GATT_DATA.TIMESTAMP.TIME_S_D = TIME_S_D(strcmp(DATA_TYPE,GATT_DATA_TYPE));
    GATT_DATA.TIMESTAMP.TIME_S_M = TIME_S_M(strcmp(DATA_TYPE,GATT_DATA_TYPE));
else
    GATT_DATA.TIMESTAMP.TIME_TICKS = TIME_S_TICKS(strcmp(DATA_TYPE,GATT_DATA_TYPE));
end

% EXTRACT TAG RELATED DATA
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
fprintf('CREATING RSSI MATRIX:\n');

RSSI_MATRIX = -Inf*double(ones(AMOUNT_OF_NODE+1,AMOUNT_OF_NODE+1,length(ADV_DATA.TIMESTAMP.TIME_TICKS)+length(GATT_DATA.TIMESTAMP.TIME_TICKS)));%0;%uint32(0);
str = [];
nextPercentPlotIndex = 0;
timeSampleNo=1;
initialOffset = TAG_DATA.TIMESTAMP.TIME_TICKS(1);

%%ADV DATA
for lineNo = 1:1:length(ADV_DATA.TIMESTAMP.TIME_TICKS)
    if strcmp(ADV_DATA.SOURCE.NAME{lineNo},'CLIMBC'); %ONLY CHILD NODES ADV DATA IS ANALYZED HERE
        if ~isempty(ADV_DATA.DATA{lineNo})
            RECEIVER_ID = sscanf(ADV_DATA.DATA{lineNo}(1:2),'%x'); %EXTRACT RECEIVER ID, RECEIVER IS INTENDED TO BE THE NODE THAT RECEIVES OTHER NODES ADV AND RETRANSMIT THEIR RSSI INFORMATION
            if sum(IDs_TO_CONSIDER == RECEIVER_ID) >= 1 || isempty(IDs_TO_CONSIDER); %CHECK IF THE ID BELONGS TO IDs_TO_CONSIDER LIST (IF THAT LIST IS EMPTY ALL IDS HAVE TO BE CONSIDERED VALID)
                i = findNodeIndex(RSSI_MATRIX, RECEIVER_ID ); %TRY TO FIND ID POSITION INSIDE RSSI_MATRIX
                if i > size(RSSI_MATRIX,1) %IF THIS CONDITION IS TRUE IT MEANS THAT THE RSSI_MATRIX IS TOO SMALL TO STORE ALL IDS' DATA
                    RSSI_MATRIX = addIDtoMatrix(RSSI_MATRIX,RECEIVER_ID);  %THIS RESIZES RSSI_MATRIX ADDING ONE LINE AND ONE COLUMN
                else %ELSE, THE RSSI_MATRIX IS NOT STILL FULL
                    if(RSSI_MATRIX(i,1,1) == -Inf) %IF THIS IS TRUE, IT IS THE FIRST TIME THE ID IS MET (-Inf IS THE INITIALIZATION VALUE), THEN IT NEEDS TO BE ADDED TO RSSI_MATRIX
                        RSSI_MATRIX(i,1,:) = RECEIVER_ID.*ones(size(RSSI_MATRIX(i,1,:)));
                        RSSI_MATRIX(1,i,:) = RECEIVER_ID.*ones(size(RSSI_MATRIX(1,i,:)));
                    end
                end
                if(lineNo ~= 1 && timeSampleNo > size(RSSI_MATRIX,3)) %IF THE RSSI_MATRIX HAS TOO FEW TIMESAMPLES ADD ONE
                    RSSI_MATRIX = addTimeSample(RSSI_MATRIX); %EACH ADV PACKET IS TREATED AS A NEW SAMPLE, THEN ADD A NEW TIME SAMPLE (WHICH IS A TWO DIMENSION MATRIX)
                end
                RSSI_MATRIX(1,1,timeSampleNo) = ADV_DATA.TIMESTAMP.TIME_TICKS(lineNo) - initialOffset; %THE TIMESTAMP OF EACH SAMPLE IS ALWAYS STORED IN CELL RSSI_MATRIX(1,1,:). ITS UNIT IS MILLISECONDS
                if SHOW_BATTERY_VOLTAGE == 1 %IF THIS IS TRUE THE RSSI_MATRIX(i,i,:) CELLS ARE RESERVED FOR BATTERY DATA
                    RSSI_MATRIX(i,i,timeSampleNo) = uint32( sscanf(ADV_DATA.DATA{lineNo}(end-5:end-2),'%x')); %BATTERY VOLTAGE IS STORED IN THE DIAGONAL RSSI_MATRIX(index_of_RECEIVER_ID,index_of_RECEIVER_ID,: )
                else %OTHERWISE THEY ARE FILLED WITH PACKET COUNTER
                    RSSI_MATRIX(i,i,timeSampleNo) = uint8( sscanf(ADV_DATA.DATA{lineNo}(end-1:end),'%x')); %ADV PKT COUNTER IS STORED IN THE DIAGONAL RSSI_MATRIX(index_of_RECEIVER_ID,index_of_RECEIVER_ID,: )
                end
                for advDataIdx = 5:4:(numel(ADV_DATA.DATA{lineNo})-6) %FIND ALL SENDERS HEARED BY THIS NODE

                    SENDER_ID = sscanf(ADV_DATA.DATA{lineNo}(advDataIdx:advDataIdx+1),'%x');
                    if (SENDER_ID ~= 0) && ( sum(IDs_TO_CONSIDER == SENDER_ID) >= 1 || isempty(IDs_TO_CONSIDER)) %CHECK IF THE SENDER ID BELONGS TO IDs_TO_CONSIDER LIST (IF THAT LIST IS EMPTY ALL IDS HAVE TO BE CONSIDERED VALID)
                        j = findNodeIndex(RSSI_MATRIX, SENDER_ID ); %TRY TO FIND ID POSITION INSIDE RSSI_MATRIX
                        if j > size(RSSI_MATRIX,1) %IF THIS CONDITION IS TRUE IT MEANS THAT THE RSSI_MATRIX IS TOO SMALL TO STORE ALL IDS' DATA
                            RSSI_MATRIX = addIDtoMatrix(RSSI_MATRIX,SENDER_ID); %THIS RESIZES RSSI_MATRIX ADDING ONE LINE AND ONE COLUMN
                        else 
                            if(RSSI_MATRIX(j,1,1) == -Inf) %IF THIS IS TRUE, IT IS THE FIRST TIME THE ID IS MET (-Inf IS THE INITIALIZATION VALUE), THEN IT NEEDS TO BE ADDED TO RSSI_MATRIX
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
    %PLOT PROGRESS PERCENT DATA
    if lineNo > nextPercentPlotIndex
        nextPercentPlotIndex = nextPercentPlotIndex + length(ADV_DATA.TIMESTAMP.TIME_TICKS)/100;
        for s=1:length(str)
            fprintf('\b');
        end
        str = sprintf('%.2f percent of ADV DATA done...\n', lineNo / length(ADV_DATA.TIMESTAMP.TIME_TICKS)*100);
        fprintf(str);
    end
end

for s=1:(length(str))
    fprintf('\b');
end
fprintf('100 percent of ADV DATA done...\n');
fprintf('Done!\n\n');
str = [];
%GATT DATA
nextPercentPlotIndex = 0;
for lineNo = 1:1:length(GATT_DATA.TIMESTAMP.TIME_TICKS)
    %if strcmp(GATT_DATA.SOURCE.NAME{lineNo},'CLIMBM'); %ONLY MASTER GATT DATA IS ANALYZED HERE
        if ~isempty(GATT_DATA.DATA{lineNo})
            MASTER_ID = 254; %%254 is fixed for master ID
            if sum(IDs_TO_CONSIDER == MASTER_ID) >= 1 || isempty(IDs_TO_CONSIDER); %CHECK IF THE ID BELONGS TO IDs_TO_CONSIDER LIST (IF THAT LIST IS EMPTY ALL IDS HAVE TO BE CONSIDERED VALID)
                i = findNodeIndex(RSSI_MATRIX, MASTER_ID ); %TRY TO FIND ID POSITION INSIDE RSSI_MATRIX
                if i > size(RSSI_MATRIX,1) %IF THIS CONDITION IS TRUE IT MEANS THAT THE RSSI_MATRIX IS TOO SMALL TO STORE ALL IDS' DATA
                    RSSI_MATRIX = addIDtoMatrix(RSSI_MATRIX,MASTER_ID);  %THIS RESIZES RSSI_MATRIX ADDING ONE LINE AND ONE COLUMN
                else %ELSE, THE RSSI_MATRIX IS NOT STILL FULL
                    if(RSSI_MATRIX(i,1,1) == -Inf) %IF THIS IS TRUE, IT IS THE FIRST TIME THE ID IS MET (-Inf IS THE INITIALIZATION VALUE), THEN IT NEEDS TO BE ADDED TO RSSI_MATRIX
                        RSSI_MATRIX(i,1,:) = MASTER_ID.*ones(size(RSSI_MATRIX(i,1,:)));
                        RSSI_MATRIX(1,i,:) = MASTER_ID.*ones(size(RSSI_MATRIX(1,i,:)));
                    end
                end
                if(lineNo ~= 1 && timeSampleNo > size(RSSI_MATRIX,3)) %IF THE RSSI_MATRIX HAS TOO FEW TIMESAMPLES ADD ONE
                    RSSI_MATRIX = addTimeSample(RSSI_MATRIX); %EACH ADV PACKET IS TREATED AS A NEW SAMPLE, THEN ADD A NEW TIME SAMPLE (WHICH IS A TWO DIMENSION MATRIX)
                end
                RSSI_MATRIX(1,1,timeSampleNo) = GATT_DATA.TIMESTAMP.TIME_TICKS(lineNo) - initialOffset; %THE TIMESTAMP OF EACH SAMPLE IS ALWAYS STORED IN CELL RSSI_MATRIX(1,1,:). ITS UNIT IS MILLISECONDS
                % NO PACKET COUNTER OR BATTERY INFO IS SENT THROUGH GATT, AT LEAST FOR NOW
                for advDataIdx = 1:6:(numel(GATT_DATA.DATA{lineNo})) %FIND ALL SENDERS HEARED BY THE MASTER

                    SENDER_ID = sscanf(GATT_DATA.DATA{lineNo}(advDataIdx:advDataIdx+1),'%x');
                    if (SENDER_ID ~= 0) && ( sum(IDs_TO_CONSIDER == SENDER_ID) >= 1 || isempty(IDs_TO_CONSIDER)) %CHECK IF THE SENDER ID BELONGS TO IDs_TO_CONSIDER LIST (IF THAT LIST IS EMPTY ALL IDS HAVE TO BE CONSIDERED VALID)
                        j = findNodeIndex(RSSI_MATRIX, SENDER_ID ); %TRY TO FIND ID POSITION INSIDE RSSI_MATRIX
                        if j > size(RSSI_MATRIX,1) %IF THIS CONDITION IS TRUE IT MEANS THAT THE RSSI_MATRIX IS TOO SMALL TO STORE ALL IDS' DATA
                            RSSI_MATRIX = addIDtoMatrix(RSSI_MATRIX,SENDER_ID); %THIS RESIZES RSSI_MATRIX ADDING ONE LINE AND ONE COLUMN
                        else 
                            if(RSSI_MATRIX(j,1,1) == -Inf) %IF THIS IS TRUE, IT IS THE FIRST TIME THE ID IS MET (-Inf IS THE INITIALIZATION VALUE), THEN IT NEEDS TO BE ADDED TO RSSI_MATRIX
                                RSSI_MATRIX(j,1,:) = SENDER_ID.*ones(size(RSSI_MATRIX(j,1,:)));
                                RSSI_MATRIX(1,j,:) = SENDER_ID.*ones(size(RSSI_MATRIX(1,j,:)));
                            end
                        end
                        RSSI_MATRIX(i,j,timeSampleNo) =  double( typecast( uint8(sscanf(GATT_DATA.DATA{lineNo}(advDataIdx+4:advDataIdx+5),'%x')) ,'int8') ); %STORE RSSI VALUE IN THE PROPPER POSITION
                    end
                end
                timeSampleNo = timeSampleNo + 1 ;
            end
        end
    %end
    %PLOT PROGRESS PERCENT DATA
    if lineNo > nextPercentPlotIndex
        nextPercentPlotIndex = nextPercentPlotIndex + length(GATT_DATA.TIMESTAMP.TIME_TICKS)/100;
        for s=1:length(str)
            fprintf('\b');
        end
        str = sprintf('%.2f percent of GATT DATA done...\n', lineNo / length(GATT_DATA.TIMESTAMP.TIME_TICKS)*100);
        fprintf(str);
    end
end
%DELETE UNUSED PART OF RSSI_MATRIX
RSSI_MATRIX = RSSI_MATRIX(RSSI_MATRIX(:,1,1) ~= -Inf,RSSI_MATRIX(1,:,1) ~= -Inf, RSSI_MATRIX(1,1,:) ~= -Inf);
AVAILABLE_IDs = RSSI_MATRIX(2:end,1,1);

for s=1:(length(str))
    fprintf('\b');
end
fprintf('100 percent of GATT DATA done...\n');
fprintf('Done!\n\n');

%% EXTRACT TAG DATA CREATING A TIME ARRAY AND A DATA ARRAY
fprintf('GETTING TAGS DATA.\n');
T_TAG = double.empty;
DATA_TAG = double.empty;
for lineNo = 1:1:length(TAG_DATA.TIMESTAMP.TIME_S_Y) 
    
    T_TAG = cat(1,T_TAG,TAG_DATA.TIMESTAMP.TIME_TICKS(lineNo));
    DATA_TAG = cat(1,DATA_TAG,TAG_DATA.DATA(lineNo));

end
T_TAG = T_TAG - initialOffset;
fprintf('Done!\n\n');

%COUNTER/BATTERY CHECK
if SHOW_BATTERY_VOLTAGE == 1
    fprintf('GETTING BATTERY VOLTAGE DATA.\n');
    %% BATTERY CHECK
    colorlist=hsv(size(AVAILABLE_IDs,1));
    legendStrs = cell(size(AVAILABLE_IDs,1),1);
    nodesBatteryData = cell(size(AVAILABLE_IDs,1),1);
    for i_id = 2:1:size(AVAILABLE_IDs,1)+1
        %if RSSI_MATRIX(i_id,1,end) ~= -Inf
            BATT_Volt_milliV_temp = ones(size(RSSI_MATRIX,3),1)*(-Inf);
            T_batt_volt_temp = ones(size(RSSI_MATRIX,3),1)*(-Inf);
            storedSamples = 0;
            %scan all matrix and store battery voltage data
            for sampleIndex = 1:1:size(RSSI_MATRIX,3)
                if RSSI_MATRIX(i_id,i_id,sampleIndex) ~= -Inf
                    storedSamples = storedSamples + 1;
                    BATT_Volt_milliV_temp(storedSamples) = RSSI_MATRIX(i_id,i_id,sampleIndex);
                    T_batt_volt_temp(storedSamples) = RSSI_MATRIX(1,1,sampleIndex);
                end
            end
            %cut unused part of battery data vectors and store them in the cell array
            nodesBatteryData{i_id-1}.ID = AVAILABLE_IDs(i_id-1);
            nodesBatteryData{i_id-1}.BATT_Volt_milliV = BATT_Volt_milliV_temp(1:storedSamples);
            nodesBatteryData{i_id-1}.T_batt_volt = T_batt_volt_temp(1:storedSamples)*TICK_DURATION;
            
            if ~isempty(nodesBatteryData{i_id-1}.T_batt_volt)
                legendStrs{i_id} = sprintf('ID: %02x',nodesBatteryData{i_id-1}.ID);              
                figure(25)
                plot(nodesBatteryData{i_id-1}.T_batt_volt, nodesBatteryData{i_id-1}.BATT_Volt_milliV ,'o', 'col',colorlist(i_id-1,:) );
                axis([0 RSSI_MATRIX(1,1,end)*TICK_DURATION, 0, 3300]);
                xlabel('Time [s]');
                ylabel('battery voltage [mV]');
                grid on;
                hold on;
            end
        %end
    end
    figure(25)
    legend(legendStrs(2:end));
    hold off;
    fprintf('Done!\n\n');
else    %% PACKET CHECK
    fprintf('GETTING PACKET STATISTICS.\n');
    packetStat = zeros(size(RSSI_MATRIX,1)-1,4); %column 1: ID, column 2: received packets, column 3: missing packets, column 4: double received packets
    packetStat(:,1) = RSSI_MATRIX(2:end,1,end);
      
    for lineNo = 2:1:size(RSSI_MATRIX,1) %SELECT A LINE, THAT MEANS: SELECT A RECEIVER ID
        isFirst = 1;
        sampleNo = 1;
        if RSSI_MATRIX(lineNo,1,1) ~= -Inf
            while sampleNo <= size(RSSI_MATRIX,3) %ANALYZE ALL TIMESAMPLES
                if RSSI_MATRIX(lineNo,lineNo,sampleNo) ~= -Inf %IF ADV PKT COUNTER IS -inf IT MEANS THAT THIS TIMESAMPLE IS RELATED TO ANOTHER RECEIVER, THEN DISCARD IT
                    
                    if isFirst == 1 %IF IT IS THE FIRST SAMPLE FOR THIS RECEIVER STORE THE ACTUAL ADV PKT COUNTER, THE NEXT ONE SHOULD BE ACTUAL ADV PKT INDEX + 1
                        packetStat(lineNo-1,2) = packetStat(lineNo-1,2) + 1; %INCREMENT TOTAL PACKETS COUNTER
                        nextExpected = RSSI_MATRIX(lineNo,lineNo,sampleNo) + 1;
                        sampleNo = sampleNo + 1;
                        isFirst = 0;
                    else
                        if RSSI_MATRIX(lineNo,lineNo,sampleNo) == nextExpected %THE COUNTER IS WHAT IS EXPECTED
                            packetStat(lineNo-1,2) = packetStat(lineNo-1,2) + 1; %INCREMENT TOTAL PACKETS COUNTER
                            sampleNo = sampleNo + 1; 
                            nextExpected = nextExpected + 1; %SET THE NEW EXPECTED VALUE
                        elseif RSSI_MATRIX(lineNo,lineNo,sampleNo) == nextExpected-1 %NB: SOMETIMES ADV PKT COUNTER IS NOT INCREMENTED BY THE NODE (OR THE SAME PACKET IS RECEIVED TWICE)
                            
                            if CHECK_FOR_NOT_INCREMENTED_COUNTER %IF CHECK_FOR_NOT_INCREMENTED_COUNTER == 1 THE CHECK ALLOWS TWO OR MORE CONSECUFITVE PACKETS TO HAVE THE SAME COUNTER VALUE
                                %if RSSI_MATRIX(1,1,sampleNo)-RSSI_MATRIX(1,1,sampleNo-1)< 500%1000 % 1000 = 10ms (the same packet can be received on two different adv channels only if they have very similar timestamp)
                                    %WHEN A NON INCREMENTED PACKET IS RECEIVED IT IS NOT COUNTED IN TOTAL PACKETS COUNTER
                                    packetStat(lineNo-1,4) = packetStat(lineNo-1,4) + 1;
                                    sampleNo = sampleNo + 1;
                                %else
                                %    error('Two identical packets, too close to each other, has been found!!!');
                                %end
                            else %IF CHECK_FOR_NOT_INCREMENTED_COUNTER == 0 THE CHECK COUNTS AS 255 MISSING PACKETS WHEN TWO IDENTICAL COUNTER VALUE ARE MET IN SEQUENCE
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
    end
    fprintf('Done!\n\n');
    
    fprintf('PACKET CHECK STATISTICS:\n');
    fprintf('Node ID | received packets | missing packets | PEr\n');
    for nodeNo = 1 : size(packetStat,1)
        fprintf('%02X      | %d               | %d              | %.2f %%\n',packetStat(nodeNo,1), packetStat(nodeNo,2), packetStat(nodeNo,3) ,  packetStat(nodeNo,3) / (packetStat(nodeNo,2) + packetStat(nodeNo,3))*100 );
    end
    fprintf('\n');
end
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
focusId1 = findNodeIndex(RSSI_MATRIX, FOCUS_ID_1 );
focusId2 = findNodeIndex(RSSI_MATRIX, FOCUS_ID_2 );
emptySignalsCount = 0;
signalsCount = 0;
nextPercentPlotIndex = 0;
str = [];
fprintf('REORDERING LINKS:\n');
for i_id_1 = 2:1:(size(RSSI_MATRIX,1)-1)
    for i_id_2 = i_id_1+1:size(RSSI_MATRIX,2)
        T_2to1 = double.empty;
        T_1to2 = double.empty;
        RSSI_Signal_2to1 = double.empty;
        RSSI_Signal_1to2 = double.empty;
        RSSI_Signal_W = double.empty;

        for sampleIndex = 1:1:size(RSSI_MATRIX,3) %SCAN ALL TIMESAMPLES AND EXTRACT RSSI DATA BETWEEN i_id_1 AND i_id_2
            
            if RSSI_MATRIX(i_id_1,i_id_2,sampleIndex) ~= -Inf %IF THIS IS FALSE, THIS TIMESAMPLE DOESN'T HAVE THIS LINK (AT LEAST IN THIS DIRECTION)
                RSSI_Signal_2to1 = cat(1,RSSI_Signal_2to1,RSSI_MATRIX(i_id_1,i_id_2,sampleIndex));
                T_2to1 = cat(1,T_2to1,RSSI_MATRIX(1,1,sampleIndex));
            end
            
            if RSSI_MATRIX(i_id_2,i_id_1,sampleIndex) ~= -Inf %IF THIS IS FALSE, THIS TIMESAMPLE DOESN'T HAVE THIS LINK (AT LEAST IN THIS DIRECTION)
                RSSI_Signal_1to2 = cat(1,RSSI_Signal_1to2,RSSI_MATRIX(i_id_2,i_id_1,sampleIndex));
                T_1to2 = cat(1,T_1to2,RSSI_MATRIX(1,1,sampleIndex));
            end
            
        end
        
        %if (size(T_2to1,1) > 1) || (size(T_1to2,1) > 1) %IF AT LEAST ONE OF THE LINKS HAS DATA GO ON
        if ~isempty(T_2to1) || ~isempty(T_1to2) %IF AT LEAST ONE OF THE LINKS HAS DATA, GO ON!
            RSSI_Signal_W = timeBasedTwoDirectionsMerge(T_2to1, RSSI_Signal_2to1, T_1to2, RSSI_Signal_1to2, wsize, winc); %THIS MERGES RSSI DATA FROM BOTH DIRECTION AND RESAMPLE IT AT winc INTERVAL
            if ~isempty(RSSI_Signal_W)
                if (isempty(T_2to1) + isempty(T_1to2)) == 0 % both are non empty
                    T_W = ( (1:1:size(RSSI_Signal_W,1))*winc + double(min([ T_2to1',T_1to2' ])) )';
                    legendStrs = {'merged-filtered-resampled','raw 2to1','raw 1to2'};
                elseif isempty(T_1to2)
                    T_W = ( (1:1:size(RSSI_Signal_W,1))*winc + double(min(T_2to1)) )';
                    legendStrs = {'merged-filtered-resampled','raw 2to1'};
                else % T_2to1 is empty
                    T_W = ( (1:1:size(RSSI_Signal_W,1))*winc + double(min(T_1to2)) )';
                    legendStrs = {'merged-filtered-resampled','raw 1to2'};
                end
                % PLOT FOCUS IDS RSSI IF ANY
                if(focusId1 == i_id_1 && focusId2 == i_id_2) || (focusId1 == i_id_2 && focusId2 == i_id_1)
                    figure;
                    plot(T_W*TICK_DURATION,RSSI_Signal_W,T_2to1*TICK_DURATION,RSSI_Signal_2to1,'-.',T_1to2*TICK_DURATION,RSSI_Signal_1to2,'-.');
                    legend(legendStrs);
                    hold off;
                    xlabel('Time [s]');
                    ylabel('RSSI [dBm]');
                    grid on;
                    title('RSSI between FOCUS ID1 and FOCUS ID2');
                end
                
                if isempty(t_w) %% this is run only once at the first iteration of the nested loops
                    graphEdeges_RSSI = RSSI_Signal_W;
                    t_w = T_W;
                    %links = [RSSI_MATRIX(1,i_id_1,1); RSSI_MATRIX(1,i_id_2,1)];
                else
                    if ((min(t_w) - winc) >= min(T_W)) || (max(T_W) > (max(t_w) )) %%the T_W values are not contained within t_w
                        if (min(t_w) - winc) >= min(T_W) %%the current T_2to1_W array starts before t_2to1 array
                            % CREATE THE MISSING TIME VALUES
                            t_temp = (min(t_w):-winc:min(T_W))';
                            % APPEND THEM TO THE OLD t_w
                            t_w = cat(1,t_temp,t_w);
                            
                            % CREATE MISSING graphEdeges_RSSI SAMPLES
                            graphEdeges_RSSI_temp = ones(size(t_w,1),size(graphEdeges_RSSI,2)+1) * (-Inf);
                            graphEdeges_RSSI_temp( size(t_temp,1)+1:end,1:size(graphEdeges_RSSI,2) ) = graphEdeges_RSSI; %INSERT THE OLD VALUES OF graphEdeges_RSSI IN THE RESIZED VERSION graphEdeges_RSSI_temp
                            
                            % APPEND THE NEW DATA
                            if( size(RSSI_Signal_W,1) <= size(graphEdeges_RSSI_temp,1) )
                                graphEdeges_RSSI_temp(1:size(RSSI_Signal_W,1),end) = RSSI_Signal_W;
                            else  % if the new data array starts before and ends after the old data copy only the part that starts before, the part that ends after will be copied in the next 'if'
                                graphEdeges_RSSI_temp(1:end,end) = RSSI_Signal_W(1:size(graphEdeges_RSSI_temp,1));
                            end
                            % REPLACE THE OLD graphEdeges_RSSI VERSION WITH THE NEW ONE
                            graphEdeges_RSSI = graphEdeges_RSSI_temp;
                            
                            if max(T_W) > (max(t_w) ) %%the current T_2to1_W array also finishes after t_2to1 array
                                % CREATE THE MISSING TIME VALUES
                                t_temp = (max(t_w):winc:max(T_W))';
                                % APPEND THEM TO THE OLD t_w
                                t_w = cat(1,t_w,t_temp);
                                
                                % CREATE MISSING graphEdeges_RSSI SAMPLES
                                graphEdeges_RSSI_temp = ones(size(t_w,1),size(graphEdeges_RSSI,2)) * (-Inf);
                                graphEdeges_RSSI_temp( 1:size(graphEdeges_RSSI,1) ,1:size(graphEdeges_RSSI,2) ) = graphEdeges_RSSI;
                                graphEdeges_RSSI_temp(end-size(RSSI_Signal_W,1)+1 : end,end) = RSSI_Signal_W;
                                % REPLACE THE OLD graphEdeges_RSSI VERSION WITH THE NEW ONE
                                graphEdeges_RSSI = graphEdeges_RSSI_temp;
                            end
                        elseif max(T_W) > (max(t_w) ) %%the current T_2to1_W array finishes after t_2to1 array
                            % CREATE THE MISSING TIME VALUES
                            t_temp = (max(t_w):winc:max(T_W))';
                            % APPEND THEM TO THE OLD t_w
                            t_w = cat(1,t_w,t_temp);
                            
                            % CREATE MISSING graphEdeges_RSSI SAMPLES
                            graphEdeges_RSSI_temp = ones(size(t_w,1),size(graphEdeges_RSSI,2)+1) * (-Inf);
                            graphEdeges_RSSI_temp( 1:size(graphEdeges_RSSI,1) ,1:size(graphEdeges_RSSI,2) ) = graphEdeges_RSSI;
                            graphEdeges_RSSI_temp(end-size(RSSI_Signal_W,1)+1 : end,end) = RSSI_Signal_W;
                            % REPLACE THE OLD graphEdeges_RSSI VERSION WITH THE NEW ONE
                            graphEdeges_RSSI = graphEdeges_RSSI_temp;
                        end
                    else % THE T_W ARE CONTAINED WITHIN t_w
                        % CREATE MISSING graphEdeges_RSSI SAMPLES
                        graphEdeges_RSSI_temp = ones(size(t_w,1),size(graphEdeges_RSSI,2)+1) * (-Inf);
                        graphEdeges_RSSI_temp(1:end,1:end-1) = graphEdeges_RSSI;
                        tmp = abs(t_w-min(T_W));
                        [ ~ , startingindex] = min(tmp);
                        graphEdeges_RSSI_temp(startingindex:startingindex+length(RSSI_Signal_W)-1,end) = RSSI_Signal_W;
                        % REPLACE THE OLD graphEdeges_RSSI VERSION WITH THE NEW ONE
                        graphEdeges_RSSI = graphEdeges_RSSI_temp;
                    end
                end
%                 figure(100)
%                 plot(t_w*TICK_DURATION,graphEdeges_RSSI(:,end),'col',colorlist(i,:))
%                 hold on;
                signalsCount = signalsCount + 1;
                if size(graphEdeges_RSSI) ~= signalsCount + emptySignalsCount
                    error('something wrong appened');
                end
            else %create an -Inf signal that replace the missing edge
                graphEdeges_RSSI_temp = ones(size(t_w,1),size(graphEdeges_RSSI,2)+1) * (-Inf);
                graphEdeges_RSSI_temp( 1:size(graphEdeges_RSSI,1) ,1:size(graphEdeges_RSSI,2) ) = graphEdeges_RSSI;
                % REPLACE THE OLD graphEdeges_RSSI VERSION WITH THE NEW ONE
                graphEdeges_RSSI = graphEdeges_RSSI_temp;
                emptySignalsCount = emptySignalsCount + 1;
            end
            
            links = cat(2,links, [RSSI_MATRIX(1,i_id_1,1); RSSI_MATRIX(1,i_id_2,1)]);
            
            if i > nextPercentPlotIndex
                nextPercentPlotIndex = nextPercentPlotIndex + 5;
                for s=1:(length(str))
                    fprintf('\b');
                end
                str = sprintf('%.2f percent done...\n',i/((size(RSSI_MATRIX,1)^2-2*(size(RSSI_MATRIX,1)-1)-size(RSSI_MATRIX,1))/2)*100);
                fprintf(str);
            end          
            i = i+1;
        end
    end
end
for s=1:(length(str))
    fprintf('\b');
end
fprintf('100 percent done...\n');
fprintf('Done!\n\n');

t_zero = T_TAG(2);%min([T_TAG(15);T_id_1]);
T_TAG = T_TAG - t_zero;
t_w = t_w - double(t_zero);

% NOTE: graphEdeges_RSSI is already filtered with sliding window
graphEdeges_m = RSSI_to_m(graphEdeges_RSSI,k_TF_1 , txPwr_10m_1);

%LINK CHECK/RECONSTRUCTION
%NOTE: graphEdeges_RSSI == -Inf (or graphEdeges_m == Inf) are usually
%associated with devices not in range, instead graphEdeges_RSSI == NaN are
%more associated with missing packets (devices that have been seen at least once).
% warning('ATTENTION: the link recostruction is not working well, CHECK IT!!');
% fprintf('LINKS RECONSTRUCTION CHECK:\n');
% for edgeNo=1:size(graphEdeges_m,2)
%     nanIndexes = find(isnan(graphEdeges_m(:,edgeNo)));
%     if ~isempty(nanIndexes)
%         lastKnownRSSI = graphEdeges_m(nanIndexes(1)-1,edgeNo); %TODO:  check for overflow on graphEdeges_RSSI( nanIndexes(1)-1,edgeNo );, may be very rare (if the first sample is missing it should be -Inf and not NaN)
%         lastKnownRSSIIndex = nanIndexes(1)-1;
%         for indexNo=1:length(nanIndexes)
%             if isempty(find(nanIndexes(indexNo)+1 == nanIndexes,1)) %end of NaN block found
%                 nextKnownRSSI = graphEdeges_m( nanIndexes(indexNo)+1 ,edgeNo); %TODO:  check for overflow on graphEdeges_RSSI( nanIndexes(indexNo)+1 ,edgeNo);
%                 nextKnownRSSIIndex = nanIndexes(indexNo)+1;
%                 nanBlockLength = nextKnownRSSIIndex - lastKnownRSSIIndex - 1;
%                 predictionSlope = (nextKnownRSSI - lastKnownRSSI)/(nanBlockLength+2);
%                 graphEdeges_m(lastKnownRSSIIndex + 1:nextKnownRSSIIndex - 1, edgeNo) = lastKnownRSSI+((1:nanBlockLength).*predictionSlope);
%                 %reset state for the new NaN block
%                 if indexNo ~= length(nanIndexes)
%                     lastKnownRSSI = graphEdeges_m(nanIndexes(indexNo+1)-1,edgeNo);
%                     lastKnownRSSIIndex = nanIndexes(indexNo+1)-1;
%                 end
%             end
%         end
%     end
% end
% fprintf('Done!\n\n');

%FILTERING: TO CHECK, RECREATE SAMPLES IF MISSING, IT IS WRONG TO SET IT TO
%250 METERS
if TREAT_AS_STATIC == 1
if F_filt ~= 0
    fs = 1/(2*winc_sec);
    [b,a] = butter(n_filt,F_filt / fs,'low');  %create filter
    graphEdeges_m(graphEdeges_m == Inf) = 300; %This sets the maximum edge length (used for filtering) to 400 meters, if this is removed the filter output could be NaN. To see this simply remove this line and look the differences between graphEdeges_m_filt and graphEdeges_m
    graphEdeges_m_filt = filter(b,a,graphEdeges_m); %apply the filter
    graphEdeges_m_filt(graphEdeges_m == Inf) = Inf; %Restore Infs to avoid introducing errors due to edge length underestimation
else
    graphEdeges_m_filt = graphEdeges_m;
    for i_link=1:size(graphEdeges_m,2)
        graphEdeges_m_filt(:,i_link) = ones(size(graphEdeges_m_filt,1),1).*mean(graphEdeges_m(graphEdeges_m(:,i_link) ~= Inf , i_link));
    end
else
    if F_filt ~= 0
        fs = 1/(2*winc_sec);
        [b,a] = butter(n_filt,F_filt / fs,'low');  %create filter
        graphEdeges_m(graphEdeges_m == Inf) = 300; %This sets the maximum edge length (used for filtering) to 300 meters, if this is removed the filter output could be NaN. To see this simply remove this line and look the differences between graphEdeges_m_filt and graphEdeges_m
        graphEdeges_m(isnan(graphEdeges_m)) = 300;
        graphEdeges_m_filt = filter(b,a,graphEdeges_m); %apply the filter
        graphEdeges_m_filt(graphEdeges_m == Inf) = Inf; %Restore Infs to avoid introducing errors due to edge length underestimation
        graphEdeges_m_filt(isnan(graphEdeges_m)) = Inf; % This avoid NaNs that can be problematic during energy count
    else
        graphEdeges_m_filt = graphEdeges_m;
    end
end

%LINK RELIABILITY
fprintf('LINKS RELIABILITY CHECK:\n');
LINKS_UNRELIABLITY = zeros(size(graphEdeges_m));
for i_link_1=1:size(graphEdeges_m,2) %scan all links and evaluate all possible 'triangles'.
    
    id_1 = links(1,i_link_1);
    id_2_temp = links(2,links(1,:)==id_1);
    id_2 = id_2_temp(1);
    i_links_2_temp = find(links(1,:)==id_2);
    for i_link_2=i_links_2_temp
        id_3 = links(2,i_link_2);
        i_link_3 = find(links(2,:)==id_3 & links(1,:)==id_1);
        
        if(size(i_link_3) == 1 )
            
            for timeIndexNo = 1:size(graphEdeges_m,1)
                if (graphEdeges_m(timeIndexNo,i_link_1)~=Inf) && (graphEdeges_m(timeIndexNo,i_link_2)~=Inf) && (graphEdeges_m(timeIndexNo,i_link_3)~=Inf)
                    if graphEdeges_m(timeIndexNo,i_link_1) + graphEdeges_m(timeIndexNo,i_link_2) <  0.8*graphEdeges_m(timeIndexNo,i_link_3)
                        %links(i_link_3) -> unreliable
                        LINKS_UNRELIABLITY(timeIndexNo,i_link_3) = LINKS_UNRELIABLITY(timeIndexNo,i_link_3) + 1;
                    end
                    if graphEdeges_m(timeIndexNo,i_link_2) + graphEdeges_m(timeIndexNo,i_link_3) <  0.8*graphEdeges_m(timeIndexNo,i_link_1)
                        %links(i_link_1) -> unreliable
                        LINKS_UNRELIABLITY(timeIndexNo,i_link_1) = LINKS_UNRELIABLITY(timeIndexNo,i_link_1) + 1;
                    end
                    if graphEdeges_m(timeIndexNo,i_link_3) + graphEdeges_m(timeIndexNo,i_link_1) <  0.8*graphEdeges_m(timeIndexNo,i_link_2)
                        %links(i_link_2) -> unreliable
                        LINKS_UNRELIABLITY(timeIndexNo,i_link_2) = LINKS_UNRELIABLITY(timeIndexNo,i_link_2) + 1;
                    end
                end
            end
        else
            if ~isempty(i_link_3)
                error('i_link_3 has more than one element, check!!!');
            end
        end
    end
end
fprintf('Done!\n\n');

figure(200)
plot(T_TAG*TICK_DURATION,zeros(size(T_TAG)),'ro', t_w*TICK_DURATION, graphEdeges_m_filt,  t_w*TICK_DURATION, graphEdeges_m );
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
%% CALCULATING NODES LAYOUT
% NOTE: for now, changing the spring constant has no evident effect on
% layout. Moreover neato fail to layouts a matematical straigt line such as:
% graph G{
% 1 -- 2[len="1",weight="1";
% 2 -- 3[len="1",weight="1";
% 1 -- 3[len="2",weight="1";
% }
fprintf('CALCULATING LAYOUT:\n');
nodePositionXY = zeros(size(unique(links),1),3,xstop_index-xstart_index);
nodePositionIndex = 1;
nextPercentPlotIndex = xstart_index;
str = [];
for timeIndexNo = xstart_index : xstop_index
    CENTERING_OFFSET_XY = [0,0];
    switch LAYOUT_ALGORITHM
        case 0 % use neato to place nodes
            if timeIndexNo == xstart_index
                createDOTdescriptionFile( graphEdeges_m_filt(timeIndexNo,:), links, 1+LINKS_UNRELIABLITY(timeIndexNo,:) , '../output/output_m_temp.dot',[]); %1+LINKS_UNRELIABLITY(timeIndexNo,:) is because LINKS_UNRELIABLITY is zero if the link is reliable, inside createDOTdescriptionFile the spring constant is calculated with 1/LINKS_UNRELIABLITY(...). If LINKS_UNRELIABLITY(...) == 0 the constant will be Inf...
            else
                createDOTdescriptionFile( graphEdeges_m_filt(timeIndexNo,:), links, 1+LINKS_UNRELIABLITY(timeIndexNo,:) , '../output/output_m_temp.dot',nodePositionXY(:,:,nodePositionIndex-1));
            end
            [status,cmdout] = dos('neato -Tplain ../output/output_m_temp.dot');
            if status == 0
                textLines = textscan(cmdout, '%s','delimiter', '\n');
                
                for textLineNo = 2:length(textLines{1})
                    tLine = sscanf( char(textLines{1}(textLineNo)),'%s %d %f %f');
                    if( tLine(1) == 'n' && tLine(2) == 'o' && tLine(3) == 'd' && tLine(4) == 'e')
                        k = findNodeIndex(RSSI_MATRIX(:,:,1), tLine(5) );
                        nodePositionXY(k-1,:,nodePositionIndex) = tLine(5:7)';
                        if tLine(5) == CENTER_ON_ID
                            k_center_id = k;
                            if CENTER_ON_ID ~= 0
                                CENTERING_OFFSET_XY = nodePositionXY(k_center_id-1,2:3,nodePositionIndex);
                            end
                        end
                    end
                end
                
                if CENTER_ON_ID ~= 0 && sum(CENTERING_OFFSET_XY) ~= 0
                    for i_id = 1:size(nodePositionXY,1)
                        if nodePositionXY(i_id,1,nodePositionIndex) ~= 0
                            nodePositionXY(i_id,2:3,nodePositionIndex) = nodePositionXY(i_id,2:3,nodePositionIndex) - CENTERING_OFFSET_XY;
                        end
                    end
                end
                
            end
        case 1 % Use multidimensional scaling for placing nodes
            if timeIndexNo == xstart_index
                nodePositionXY(:,:,nodePositionIndex) = mdsLayout(graphEdeges_m_filt(timeIndexNo,:), links, 1+LINKS_UNRELIABLITY(timeIndexNo,:),[]); %1+LINKS_UNRELIABLITY(timeIndexNo,:) is because LINKS_UNRELIABLITY is zero if the link is reliable, inside createDOTdescriptionFile the spring constant is calculated with 1/LINKS_UNRELIABLITY(...). If LINKS_UNRELIABLITY(...) == 0 the constant will be Inf...
                k_center_id = find(nodePositionXY(:,1,1) == CENTER_ON_ID);
            else
                nodePositionXY(:,:,nodePositionIndex) = mdsLayout(graphEdeges_m_filt(timeIndexNo,:), links, 1+LINKS_UNRELIABLITY(timeIndexNo,:),nodePositionXY(:,2:3,nodePositionIndex-1));
            end
            
            if size(k_center_id,1) == 1
                if CENTER_ON_ID ~= 0
                    CENTERING_OFFSET_XY = nodePositionXY(k_center_id,2:3,nodePositionIndex);
                    nodePositionXY(:,2:3,nodePositionIndex) = nodePositionXY(:,2:3,nodePositionIndex) - [ones(size(nodePositionXY(:,2:3,nodePositionIndex),1),1) * CENTERING_OFFSET_XY(1), ones(size(nodePositionXY(:,2:3,nodePositionIndex),1),1) * CENTERING_OFFSET_XY(2)];
                end
            end
            
        case 2 % Use mesh relaxation for placing nodes
                  
            if timeIndexNo == xstart_index
                nodePositionXY(:,:,nodePositionIndex) = meshRelaxationLayout(graphEdeges_m_filt(timeIndexNo,:), links, 1+LINKS_UNRELIABLITY(timeIndexNo,:),[]); %1+LINKS_UNRELIABLITY(timeIndexNo,:) is because LINKS_UNRELIABLITY is zero if the link is reliable, inside createDOTdescriptionFile the spring constant is calculated with 1/LINKS_UNRELIABLITY(...). If LINKS_UNRELIABLITY(...) == 0 the constant will be Inf...
                k_center_id = find(nodePositionXY(:,1,1) == CENTER_ON_ID);
            else
                nodePositionXY(:,:,nodePositionIndex) = meshRelaxationLayout(graphEdeges_m_filt(timeIndexNo,:), links, 1+LINKS_UNRELIABLITY(timeIndexNo,:),nodePositionXY(:,2:3,nodePositionIndex-1));
            end
            
            if size(k_center_id,1) == 1
                if CENTER_ON_ID ~= 0
                    CENTERING_OFFSET_XY = nodePositionXY(k_center_id,2:3,nodePositionIndex);
                    nodePositionXY(:,2:3,nodePositionIndex) = nodePositionXY(:,2:3,nodePositionIndex) - [ones(size(nodePositionXY(:,2:3,nodePositionIndex),1),1) * CENTERING_OFFSET_XY(1), ones(size(nodePositionXY(:,2:3,nodePositionIndex),1),1) * CENTERING_OFFSET_XY(2)];
                end
            end
        otherwise
            error('Select a valid value for LAYOUT_ALGORITHM!');
    end
    
    nodePositionIndex = nodePositionIndex + 1;
    
    if timeIndexNo > nextPercentPlotIndex
        nextPercentPlotIndex = nextPercentPlotIndex + (xstop_index-xstart_index)/100;
        for s=1:(length(str))
            fprintf('\b');
        end
        str = sprintf('%.2f percent done...\n', (timeIndexNo-xstart_index)/(xstop_index-xstart_index)*100);
        fprintf(str);
    end
    
end
for s=1:(length(str))
    fprintf('\b');
end
fprintf('100 percent done...\n');
fprintf('Done!\n\n');

%% PLOTTING AND EXPORTING NODES LAYOUT
figure(205)
filename = '../output/output_Animation.gif';
fps = 1/winc_sec*5;
colorlist2 = hsv( size(nodePositionXY,1) );
squareDim = 50;
for timeIndexNo = 1 : size(nodePositionXY,3)
    nodePositionXY_temp = nodePositionXY(nodePositionXY(:,1,timeIndexNo) ~= 0,:, timeIndexNo);
    nodesOutsideSquare = 0;
    regularNodesPositionXY_temp =  nodePositionXY_temp(nodePositionXY_temp(:,1)~=254 & nodePositionXY_temp(:,1)~=FOCUS_ID_1 & nodePositionXY_temp(:,1)~=FOCUS_ID_2,:);
    masterNodePositionXY_temp = nodePositionXY_temp(nodePositionXY_temp(:,1)==254,:);
    focusNodesPositionXY_temp = nodePositionXY_temp(nodePositionXY_temp(:,1)==FOCUS_ID_1 | nodePositionXY_temp(:,1)==FOCUS_ID_2,:);
    plot(regularNodesPositionXY_temp(:,2),regularNodesPositionXY_temp(:,3),'bo',masterNodePositionXY_temp(:,2),masterNodePositionXY_temp(:,3),'ro',focusNodesPositionXY_temp(:,2),focusNodesPositionXY_temp(:,3),'go','LineWidth',3);
    xlabel('[m]?');
    ylabel('[m]?');
    grid on;
    for nodeNo = 1 : size(nodePositionXY_temp,1)
        if PLOT_NODE_LABELS == 1
            str = sprintf('%x',nodePositionXY_temp(nodeNo,1));
            text(nodePositionXY_temp(nodeNo,2)+3,nodePositionXY_temp(nodeNo,3),str,'Color',colorlist2(nodeNo,:),'FontSize',14,'FontWeight','bold');
        end
        if nodePositionXY_temp(nodeNo,2) > squareDim || nodePositionXY_temp(nodeNo,2) < -squareDim || nodePositionXY_temp(nodeNo,3) > squareDim || nodePositionXY_temp(nodeNo,3) < -squareDim
            nodesOutsideSquare = nodesOutsideSquare + 1;
        end
    end
    str = sprintf('Time = %.0f\n %d nodes inside the sqare\n %d nodes outside the square',(xstart_index+timeIndexNo)*winc_sec,nodeNo-nodesOutsideSquare,nodesOutsideSquare);
    text(-squareDim+squareDim*0.1,squareDim-squareDim*0.2,str,'FontSize',10,'FontWeight','bold');
    axis([-squareDim squareDim -squareDim squareDim]);
    
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

save last_run;
