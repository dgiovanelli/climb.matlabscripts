%% Format string for each line of text:
% For more information, see the TEXTSCAN documentation.
if ANDROID == 1
    formatSpec = '%f%f%f%f%f%f%f%s%s%s%s%s%[^\n\r]';
    TICK_DURATION_S = 0.001;
else
    formatSpec = '%d%s%s%s%s%s%[^\n\r]';
    TICK_DURATION_S = 0.00001;
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
    RSSI = dataArray{:, 11};
    RAW_DATA = dataArray{:, 12};
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

% EXTRACT GATT RELATED DATA
if ANDROID == 1
    GATT_DATA.TIMESTAMP.TIME_S_Y = TIME_S_Y(strcmp(DATA_TYPE,GATT_DATA_TYPE));
    GATT_DATA.TIMESTAMP.TIME_S_M = TIME_S_M(strcmp(DATA_TYPE,GATT_DATA_TYPE));
    GATT_DATA.TIMESTAMP.TIME_S_D = TIME_S_D(strcmp(DATA_TYPE,GATT_DATA_TYPE));
    GATT_DATA.TIMESTAMP.TIME_S_H = TIME_S_H(strcmp(DATA_TYPE,GATT_DATA_TYPE));
    GATT_DATA.TIMESTAMP.TIME_S_MIN = TIME_S_MIN(strcmp(DATA_TYPE,GATT_DATA_TYPE));
    GATT_DATA.TIMESTAMP.TIME_S_S = TIME_S_S(strcmp(DATA_TYPE,GATT_DATA_TYPE));
    GATT_DATA.TIMESTAMP.TIME_TICKS = TIME_S_TICKS(strcmp(DATA_TYPE,GATT_DATA_TYPE));
else
    GATT_DATA.TIMESTAMP.TIME_TICKS = TIME_S_TICKS(strcmp(DATA_TYPE,GATT_DATA_TYPE));
end
GATT_DATA.SOURCE.ADDRESS = SOURCE_ADD(strcmp(DATA_TYPE,GATT_DATA_TYPE));
GATT_DATA.SOURCE.NAME = SOURCE_NAME(strcmp(DATA_TYPE,GATT_DATA_TYPE));
GATT_DATA.DATA = RAW_DATA(strcmp(DATA_TYPE,GATT_DATA_TYPE));

% EXTRACT TAG RELATED DATA
if ANDROID == 1
    TAG_DATA.TIMESTAMP.TIME_S_Y = TIME_S_Y(strcmp(DATA_TYPE,TAG_DATA_TYPE));
    TAG_DATA.TIMESTAMP.TIME_S_M = TIME_S_M(strcmp(DATA_TYPE,TAG_DATA_TYPE));
    TAG_DATA.TIMESTAMP.TIME_S_D = TIME_S_D(strcmp(DATA_TYPE,TAG_DATA_TYPE));
    TAG_DATA.TIMESTAMP.TIME_S_H = TIME_S_H(strcmp(DATA_TYPE,TAG_DATA_TYPE));
    TAG_DATA.TIMESTAMP.TIME_S_MIN = TIME_S_MIN(strcmp(DATA_TYPE,TAG_DATA_TYPE));
    TAG_DATA.TIMESTAMP.TIME_S_S = TIME_S_S(strcmp(DATA_TYPE,TAG_DATA_TYPE));
    TAG_DATA.TIMESTAMP.TIME_TICKS = TIME_S_TICKS(strcmp(DATA_TYPE,TAG_DATA_TYPE));
else
    TAG_DATA.TIMESTAMP.TIME_TICKS = TIME_S_TICKS(strcmp(DATA_TYPE,TAG_DATA_TYPE));
end
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
    ADV_DATA.TIMESTAMP.TIME_S_Y = TIME_S_Y(strcmp(DATA_TYPE,ADV_DATA_TYPE));
 else
    ADV_DATA.TIMESTAMP.TIME_TICKS = TIME_S_TICKS(strcmp(DATA_TYPE,ADV_DATA_TYPE));
end
ADV_DATA.SOURCE.ADDRESS = SOURCE_ADD(strcmp(DATA_TYPE,ADV_DATA_TYPE));
ADV_DATA.SOURCE.NAME = SOURCE_NAME(strcmp(DATA_TYPE,ADV_DATA_TYPE));
ADV_DATA.RSSI = RSSI(strcmp(DATA_TYPE,ADV_DATA_TYPE));
ADV_DATA.DATA = RAW_DATA(strcmp(DATA_TYPE,ADV_DATA_TYPE));

%% CREATE RSSI_MATRIX
fprintf('CREATING RSSI MATRIX:\n');

RSSI_MATRIX = -Inf*double(ones(AMOUNT_OF_NODE+1,AMOUNT_OF_NODE+1,length(ADV_DATA.TIMESTAMP.TIME_TICKS)+length(GATT_DATA.TIMESTAMP.TIME_TICKS)));%0;%uint32(0);
str = [];
nextPercentPlotIndex = 0;
timeSampleNo=1;

deltaT_offset_ticks = (NETWORK_DELAY_COMPENSATION_MS*1000)*TICK_DURATION_S;
%%ADV DATA
for lineNo = 1:1:length(ADV_DATA.TIMESTAMP.TIME_TICKS)
    if strcmp(ADV_DATA.SOURCE.NAME{lineNo},'CLIMBC') %ONLY CHILD NODES ADV DATA IS ANALYZED HERE
        if ~isempty(ADV_DATA.DATA{lineNo})
            RECEIVER_ID = sscanf(ADV_DATA.DATA{lineNo}(1:2),'%x'); %EXTRACT RECEIVER ID, RECEIVER IS INTENDED TO BE THE NODE THAT RECEIVES OTHER NODES ADV AND RETRANSMIT THEIR RSSI INFORMATION
            if sum(IDs_TO_CONSIDER == RECEIVER_ID) >= 1 || isempty(IDs_TO_CONSIDER) %CHECK IF THE ID BELONGS TO IDs_TO_CONSIDER LIST (IF THAT LIST IS EMPTY ALL IDS HAVE TO BE CONSIDERED VALID)
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
                RSSI_MATRIX(1,1,timeSampleNo) = ADV_DATA.TIMESTAMP.TIME_TICKS(lineNo) - deltaT_offset_ticks; %THE TIMESTAMP OF EACH SAMPLE IS ALWAYS STORED IN CELL RSSI_MATRIX(1,1,:). ITS UNIT IS MILLISECONDS
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
                
                %% USE ALSO SMARTPHONE RSSI
                if ENABLE_SMARTPHONE_RSSI
                    SENDER_ID = RECEIVER_ID;  % the receiver is now the sender, because the analyzed packet has been sent by the mobile node and received by the smartphone
                    j = i;
                    RECEIVER_ID = 256;%for now the smartphone id is fixed to 256
                    i = findNodeIndex(RSSI_MATRIX, RECEIVER_ID ); %TRY TO FIND ID POSITION INSIDE RSSI_MATRIX
                    if i > size(RSSI_MATRIX,1) %IF THIS CONDITION IS TRUE IT MEANS THAT THE RSSI_MATRIX IS TOO SMALL TO STORE ALL IDS' DATA
                        RSSI_MATRIX = addIDtoMatrix(RSSI_MATRIX,SENDER_ID); %THIS RESIZES RSSI_MATRIX ADDING ONE LINE AND ONE COLUMN
                    else
                        if(RSSI_MATRIX(i,1,1) == -Inf) %IF THIS IS TRUE, IT IS THE FIRST TIME THE ID IS MET (-Inf IS THE INITIALIZATION VALUE), THEN IT NEEDS TO BE ADDED TO RSSI_MATRIX
                            RSSI_MATRIX(i,1,:) = RECEIVER_ID.*ones(size(RSSI_MATRIX(i,1,:)));
                            RSSI_MATRIX(1,i,:) = RECEIVER_ID.*ones(size(RSSI_MATRIX(1,i,:)));
                        end
                    end
                    RSSI_MATRIX(i,j,timeSampleNo) =  double( sscanf(ADV_DATA.RSSI{lineNo},'%d')); %STORE RSSI VALUE IN THE PROPPER POSITION
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
   if strcmp(GATT_DATA.SOURCE.NAME{lineNo},'CLIMBM') %ONLY MASTER GATT DATA IS ANALYZED HERE
        if ~isempty(GATT_DATA.DATA{lineNo})
            MASTER_ID = 254; %%254 is fixed for master ID
            if sum(IDs_TO_CONSIDER == MASTER_ID) >= 1 || isempty(IDs_TO_CONSIDER) %CHECK IF THE ID BELONGS TO IDs_TO_CONSIDER LIST (IF THAT LIST IS EMPTY ALL IDS HAVE TO BE CONSIDERED VALID)
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
                RSSI_MATRIX(1,1,timeSampleNo) = GATT_DATA.TIMESTAMP.TIME_TICKS(lineNo); %THE TIMESTAMP OF EACH SAMPLE IS ALWAYS STORED IN CELL RSSI_MATRIX(1,1,:). ITS UNIT IS MILLISECONDS
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
    end
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
fprintf('Done!\n\n');
