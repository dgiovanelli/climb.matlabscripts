clear all;
close all;
clc;
%NODE_ID_1 AND NODE_ID_2 ARE NODES UNDER ATTENTION. THE SCRIPT PLOTS RSSI
%BETWEEN THESE NODES AND DELTA T BETWEEN SAMPLES FOR BOTH NODES.
%CHANGE filename VARIABLE TO CHANGE THE TEST TO BE ANALYZED

ANDROID = 1; %set this to 1 if the log has been performed with the android app
NODE_ID_1 = 134;
inf = 4294967295;
AMOUNT_OF_NODE = 10;
%% Import data from text file.
%% Initialize variables.
filename = '../BATTERY_LIFE_TEST/LOGS/5187f1cf-a6f0-4e4a-a025-cb2fe52a1061_log_130_7.36.42.txt';
delimiter = ' ';

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
    formatSpec = '%f%f%f%f%f%f%d%s%s%s%*s%s%[^\n\r]';
else
    formatSpec = '%d%s%s%s%s%s%[^\n\r]';
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

% EXTRACT TAG RELATED DATA -- NOT USED
TAG_DATA.TIMESTAMP.TIME_S_MILL = TIME_S_TICKS(strcmp(DATA_TYPE,TAG_DATA_TYPE));
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
RSSI_MATRIX = inf*ones(AMOUNT_OF_NODE,AMOUNT_OF_NODE,30000);%0;%uint32(0);
str = '';
timeSampleNo=0;
for lineNo = 1:1:length(ADV_DATA.TIMESTAMP.TIME_TICKS)
    if strcmp(ADV_DATA.SOURCE.NAME{lineNo},'CLIMBC') %&& length(ADV_DATA.DATA{lineNo}) == 38 %ONLY CHILD NODES ADV DATA IS ANALYZED HERE
        timeSampleNo = timeSampleNo + 1 ;
        RECEIVER_ID = uint32(sscanf(ADV_DATA.DATA{lineNo}(1:2),'%x')); %EXTRACT RECEIVER ID, RECEIVER IS INTENDED TO BE THE NODE THAT RECEIVES OTHER NODES ADV AND RETRANSMIT THEIR RSSI INFORMATION
        i = findNodeIndex(RSSI_MATRIX, RECEIVER_ID );
        if i > size(RSSI_MATRIX,1) %IF RECEIVER_ID IS NOT ALREADY IN THE MATRIX ADD IT
            RSSI_MATRIX = addIDtoMatrix(RSSI_MATRIX,RECEIVER_ID);  %THIS RESIZES RSSI_MATRIX ADDING ONE LINE AND ONE COLUMN
        else
            if(RSSI_MATRIX(i,1,1) == inf)
                RSSI_MATRIX(i,1,:) = double(RECEIVER_ID).*ones(size(RSSI_MATRIX(i,1,:)));
                RSSI_MATRIX(1,i,:) = double(RECEIVER_ID).*ones(size(RSSI_MATRIX(1,i,:)));
            end
        end
        if(lineNo ~= 1 && timeSampleNo > size(RSSI_MATRIX,3))
            RSSI_MATRIX = addTimeSample(RSSI_MATRIX); %EACH ADV PACKET IS TREATED AS A NEW SAMPLE, THEN ADD A NEW TIME SAMPLE (WHICH IS A TWO DIMENSION MATRIX)
        end
        %RSSI_MATRIX = addTimeSample(RSSI_MATRIX); %EACH ADV PACKET IS TREATED AS A NEW SAMPLE, THEN ADD A NEW TIME SAMPLE (WHICH IS A TWO DIMENSION MATRIX)
        if ANDROID == 1
            timestamp = double(ADV_DATA.TIMESTAMP.TIME_S_M(lineNo))*31*24*60*60 + double(ADV_DATA.TIMESTAMP.TIME_S_D(lineNo))*24*60*60 + double(ADV_DATA.TIMESTAMP.TIME_S_H(lineNo))*60*60 + double(ADV_DATA.TIMESTAMP.TIME_S_MIN(lineNo))*60 + double(ADV_DATA.TIMESTAMP.TIME_S_S(lineNo));
            RSSI_MATRIX(1,1,timeSampleNo) = timestamp;
            %RSSI_MATRIX(1,1,timeSampleNo) = typecast(ADV_DATA.TIMESTAMP.TIME_TICKS(lineNo),'uint32'); %THE TIMESTAMP OF EACH SAMPLE IS ALWAYS STORED IN CELL RSSI_MATRIX(1,1,:).
        else
            RSSI_MATRIX(1,1,timeSampleNo) = typecast(ADV_DATA.TIMESTAMP.TIME_TICKS(lineNo),'uint32'); %THE TIMESTAMP OF EACH SAMPLE IS ALWAYS STORED IN CELL RSSI_MATRIX(1,1,:).
        end
        %RSSI_MATRIX(i,i,end) = uint32( sscanf(ADV_DATA.DATA{lineNo}(end-1:end),'%x')); %ADV PKT COUNTER IS ALWAYS STORED IN THE DIAGONAL RSSI_MATRIX(index_of_RECEIVER_ID,index_of_RECEIVER_ID,: )
        RSSI_MATRIX(i,i,timeSampleNo) = uint32( sscanf(ADV_DATA.DATA{lineNo}(end-5:end-2),'%x'));
        for advDataIdx = 5:4:(numel(ADV_DATA.DATA{lineNo})-6) %FIND ALL SENDERS HEARED BY THIS NODE
            SENDER_ID = uint32(sscanf(ADV_DATA.DATA{lineNo}(advDataIdx:advDataIdx+1),'%x'));%sscanf(ADV_DATA.DATA{lineNo}(advDataIdx:advDataIdx+1),'%x');
            if SENDER_ID ~= 0 %ZERO ID IS NOT VALID!
                j = findNodeIndex(RSSI_MATRIX, SENDER_ID );
                if j > size(RSSI_MATRIX,1) %IF SENDER_ID IS NOT ALREADY IN THE MATRIX ADD IT
                    RSSI_MATRIX = addIDtoMatrix(RSSI_MATRIX,SENDER_ID); %THIS RESIZES RSSI_MATRIX ADDING ONE LINE AND ONE COLUMN
                end
                RSSI_MATRIX(i,j,timeSampleNo) = uint32(sscanf(ADV_DATA.DATA{lineNo}(advDataIdx+2:advDataIdx+3),'%x'));
                %typecast( uint8(sscanf(ADV_DATA.DATA{lineNo}(advDataIdx+2:advDataIdx+3),'%x')) ,'uint32'); %STORE RSSI VALUE IN THE PROPPER POSITION
            end
        end
    end
end
%MATRIX = MATRIX(:,:,500:end); %DELETE SOME TIME SAMPLES

% %% PACKET CHECK
% packetStat = zeros(size(RSSI_MATRIX,1)-1,3); %column 1: ID, column 2: total packets, column 3: missing packets
% packetStat(:,1) = RSSI_MATRIX(2:end,1,end);
% isFirst = 1;
% sampleNo = 1;
%
% for lineNo = 2:1:size(RSSI_MATRIX,1) %SELECT A LINE, THAT MEANS: SELECT A RECEIVER ID
%     while sampleNo < size(RSSI_MATRIX,3) %ANALYZE ALL TIMESAMPLES
%         if RSSI_MATRIX(lineNo,lineNo,sampleNo) ~= inf %IF ADV PKT COUNTER IS inf IT MEANS THAT THIS TIMESAMPLE IS RELATED TO ANOTHER RECEIVER, THEN DISCARD IT
%
%             packetStat(lineNo-1,2) = packetStat(lineNo-1,2) + 1; %INCREMENT TOTAL PACKETS COUNTER
%
%             if isFirst == 1 %IF IT IS THE FIRST SAMPLE FOR THIS RECEIVER STORE THE ACTUAL ADV PKT COUNTER, THE NEXT ONE SHOULD BE ACTUAL ADV PKT INDEX + 1
%
%                 nextExpected = RSSI_MATRIX(lineNo,lineNo,sampleNo) + 1;
%                 if nextExpected == 256 %REMEMBER THAT EACH FIELD IN ADV PKT IS 8 BIT UNSIGNED INTEGER
%                     nextExpected = 0;
%                 end
%
%                 sampleNo = sampleNo + 1;
%                 isFirst = 0;
%             else
%                 if RSSI_MATRIX(lineNo,lineNo,sampleNo) ~= nextExpected && RSSI_MATRIX(lineNo,lineNo,sampleNo) ~= nextExpected-1 %NB: SOMETIMES ADV PKT COUNTER IS NOT INCREMENTED BY THE NODE, DON'T KNOW WHY...
%                     packetStat(lineNo-1,3) = packetStat(lineNo-1,3) + 1; %IF COUNTER IS DIFFERENT FROM WHAT IS EXPECTED, INCREMENT ERROR COUNTER
%                     nextExpected = nextExpected + 1;
%                 else %THE COUNTER IS WHAT IS EXPECTED
%                     nextExpected = RSSI_MATRIX(lineNo,lineNo,sampleNo) + 1; %SET THE NEW EXPECTED VALUE
%                     sampleNo = sampleNo + 1;
%                 end
%
%
%                 if nextExpected == 256 %REMEMBER THAT EACH FIELD IN ADV PKT IS 8 BIT UNSIGNED INTEGER
%                     nextExpected = 0;
%                 end
%             end
%         else
%
%             sampleNo = sampleNo + 1; %IF THE SAMPLE IS NOT VALID GO TO THE NEXT ONE
%
%         end
%     end
%     sampleNo = 1;
%     isFirst = 1;
% end

%% ANALYZE DATA

i_id = findNodeIndex(RSSI_MATRIX, NODE_ID_1 );
colorlist=hsv(size(RSSI_MATRIX,1));
legendStrs = {};

for i_id = 2:1:size(RSSI_MATRIX,1)
    if RSSI_MATRIX(i_id,1,end) ~= inf
        T = uint32.empty;
        RSSI_Signal = double.empty;
        BATT_Volt_milliV = uint32.empty;
        T_batt_volt = uint32.empty;
        for sampleIndex = 1:1:size(RSSI_MATRIX,3)
            
            if RSSI_MATRIX(i_id,i_id,sampleIndex) ~= inf
                BATT_Volt_milliV = cat(1,BATT_Volt_milliV,RSSI_MATRIX(i_id,i_id,sampleIndex));
                T_batt_volt = cat(1,T_batt_volt,RSSI_MATRIX(1,1,sampleIndex));
            end
            T = cat(1,T,RSSI_MATRIX(1,1,sampleIndex));
            
        end
        
        if ANDROID == 1
            if ~isempty(T_batt_volt)>0
                T = double(T)/(60*60);
                T = T - T(1);
                T_batt_volt = double(T_batt_volt)/(60*60);
                T_batt_volt = T_batt_volt - T_batt_volt(1);
            end
        else
            T = double(T)/(60*6000000);
            T_batt_volt = double(T_batt_volt)/(60*6000000);
        end
        
        if ~isempty(T)>0
            legendStrs{i_id} = sprintf('ID: %02x',RSSI_MATRIX(i_id,1));
            %         T = T(2:end) - T(2);
            %         deltaT = diff(T);%receiving time of NODE_ID_1
            %         figure(1)
            %         plot(T(2:end), deltaT);
            %         xlabel('Time [h]');
            %         ylabel('[h]');
            %         grid on;
            %         hold on;
            
            figure(2)
            plot(T_batt_volt, BATT_Volt_milliV ,'o', 'col',colorlist(i_id,:) );
            xlabel('Time [h]');
            ylabel('battery voltage [mV]');
            grid on;
            hold on;
            
        end
    end
end
% figure(1)
% legend(legendStrs(2:end));
% hold off;
figure(2)
legend(legendStrs(2:end));
hold off;