clear all;
close all;
clc;
%NODE_ID_1 IS THE NODE UNDER ATTENTION. THE SCRIPT PLOTS RSSI
%BETWEEN THIS NODE AND MASTER, DELTA T BETWEEN RECEIVED SAMPLES.
%CHANGE filename VARIABLE TO CHANGE THE TEST TO BE ANALYZED

%NOTE: THIS SCRIPT HAS BEEN OBTAINED STARTING FROM logAnalysis_only_ADV,
%THEN IT IS NOT OPTIMIZED (I.E. BOTH RSSI_MATRIX_GATT AND STATE_MATRIX_GATT
%HAVE ONLY THE FIRST LINE THAT CARRIES INFORMATION.
%NODE_ID_1 = 7;
%MASTER_ID = 86;
%% Import data from text file.
%% Initialize variables.
filename = '.\LOGS\log_89_11.1.32.txt';%24_02_16\log_55_11.19.44.txt';
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
formatSpec = '%f%f%f%f%f%f%f%s%s%s%*s%s%[^\n\r]';

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
TIME_S_Y = dataArray{:, 1};
TIME_S_M = dataArray{:, 2};
TIME_S_D = dataArray{:, 3};
TIME_S_H = dataArray{:, 4};
TIME_S_MIN = dataArray{:, 5};
TIME_S_S = dataArray{:, 6};
TIME_S_MILL = dataArray{:, 7};
SOURCE_ADD = dataArray{:, 8};
SOURCE_NAME = dataArray{:, 9};
DATA_TYPE = dataArray{:, 10};
RAW_DATA = dataArray{:, 11};

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
GATT_DATA.TIMESTAMP.TIME_S_MILL = TIME_S_MILL(strcmp(DATA_TYPE,GATT_DATA_TYPE));
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
TAG_DATA.TIMESTAMP.TIME_S_MILL = TIME_S_MILL(strcmp(DATA_TYPE,TAG_DATA_TYPE));
TAG_DATA.SOURCE.ADDRESS = SOURCE_ADD(strcmp(DATA_TYPE,TAG_DATA_TYPE));
TAG_DATA.SOURCE.NAME = SOURCE_NAME(strcmp(DATA_TYPE,TAG_DATA_TYPE));
TAG_DATA.DATA = RAW_DATA(strcmp(DATA_TYPE,TAG_DATA_TYPE));

% EXTRACT ADV RELATED DATA
ADV_DATA.TIMESTAMP.TIME_S_Y = TIME_S_Y(strcmp(DATA_TYPE,ADV_DATA_TYPE));
ADV_DATA.TIMESTAMP.TIME_S_M = TIME_S_M(strcmp(DATA_TYPE,ADV_DATA_TYPE));
ADV_DATA.TIMESTAMP.TIME_S_D = TIME_S_D(strcmp(DATA_TYPE,ADV_DATA_TYPE));
ADV_DATA.TIMESTAMP.TIME_S_H = TIME_S_H(strcmp(DATA_TYPE,ADV_DATA_TYPE));
ADV_DATA.TIMESTAMP.TIME_S_MIN = TIME_S_MIN(strcmp(DATA_TYPE,ADV_DATA_TYPE));
ADV_DATA.TIMESTAMP.TIME_S_S = TIME_S_S(strcmp(DATA_TYPE,ADV_DATA_TYPE));
ADV_DATA.TIMESTAMP.TIME_S_MILL = TIME_S_MILL(strcmp(DATA_TYPE,ADV_DATA_TYPE));
ADV_DATA.SOURCE.ADDRESS = SOURCE_ADD(strcmp(DATA_TYPE,ADV_DATA_TYPE));
ADV_DATA.SOURCE.NAME = SOURCE_NAME(strcmp(DATA_TYPE,ADV_DATA_TYPE));
ADV_DATA.DATA = RAW_DATA(strcmp(DATA_TYPE,ADV_DATA_TYPE));

%% CREATE RSSI_MATRIX_GATT and STATE_MATRIX_GATT
RSSI_MATRIX_GATT = 0;
STATE_MATRIX_GATT = 0;
for lineNo = 1:1:length(GATT_DATA.TIMESTAMP.TIME_S_Y) 
    if strcmp(GATT_DATA.SOURCE.NAME{lineNo},'CLIMBM'); %ONLY MASTER NODES DATA IS ANALYZED HERE (not necessary)
        
        MASTER_ID = sscanf(GATT_DATA.SOURCE.ADDRESS{lineNo}(end-1:end),'%x'); %EXTRACT MASTER_ID FORM MAC ADDRESS
        i = findNodeIndex(RSSI_MATRIX_GATT, MASTER_ID );
        if i > size(RSSI_MATRIX_GATT,1) %IF MASTER_ID IS NOT ALREADY IN THE MATRIX ADD IT
            RSSI_MATRIX_GATT = addIDtoMatrix(RSSI_MATRIX_GATT,MASTER_ID);  %THIS RESIZES RSSI_MATRIX ADDING ONE LINE AND ONE COLUMN 
            STATE_MATRIX_GATT = addIDtoMatrix(STATE_MATRIX_GATT,MASTER_ID);
        end
        RSSI_MATRIX_GATT = addTimeSample(RSSI_MATRIX_GATT); %EACH ADV PACKET IS TREATED AS A NEW SAMPLE, THEN ADD A NEW TIME SAMPLE (WHICH IS A TWO DIMENSION MATRIX)
        RSSI_MATRIX_GATT(1,1,end) = GATT_DATA.TIMESTAMP.TIME_S_MILL(lineNo) / 1000; %THE TIMESTAMP OF EACH SAMPLE IS ALWAYS STORED IN CELL RSSI_MATRIX(1,1,:). ITS UNIT IS SECONDS
        STATE_MATRIX_GATT = addTimeSample(STATE_MATRIX_GATT); %EACH ADV PACKET IS TREATED AS A NEW SAMPLE, THEN ADD A NEW TIME SAMPLE (WHICH IS A TWO DIMENSION MATRIX)
        STATE_MATRIX_GATT(1,1,end) = GATT_DATA.TIMESTAMP.TIME_S_MILL(lineNo) / 1000; %THE TIMESTAMP OF EACH SAMPLE IS ALWAYS STORED IN CELL RSSI_MATRIX(1,1,:). ITS UNIT IS SECONDS
        for advDataIdx = 1:6:(numel(GATT_DATA.DATA{lineNo})) %FIND ALL SENDERS HEARED BY THIS NODE
            SENDER_ID = sscanf(GATT_DATA.DATA{lineNo}(advDataIdx:advDataIdx+1),'%x');
            if SENDER_ID ~= 0 %ZERO ID IS NOT VALID!
                j = findNodeIndex(RSSI_MATRIX_GATT, SENDER_ID );
                if j > size(RSSI_MATRIX_GATT,1) %IF SENDER_ID IS NOT ALREADY IN THE MATRIX ADD IT
                    RSSI_MATRIX_GATT = addIDtoMatrix(RSSI_MATRIX_GATT,SENDER_ID); %THIS RESIZES RSSI_MATRIX ADDING ONE LINE AND ONE COLUMN 
                    STATE_MATRIX_GATT = addIDtoMatrix(STATE_MATRIX_GATT,SENDER_ID);
                end
                RSSI_MATRIX_GATT(i,j,end) = typecast( uint8(sscanf(GATT_DATA.DATA{lineNo}(advDataIdx+4:advDataIdx+5),'%x')) ,'int8'); %STORE RSSI VALUE IN THE PROPPER POSITION
                STATE_MATRIX_GATT(i,j,end) = typecast( uint8(sscanf(GATT_DATA.DATA{lineNo}(advDataIdx+2:advDataIdx+3),'%x')) ,'int8'); %STORE STATE VALUE IN THE PROPPER POSITION
            end
        end
    end
end

RSSI_MATRIX_GATT(2:end,1,end) %SWOWS IDs
%RSSI_MATRIX_GATT = RSSI_MATRIX_GATT(:,:,500:end); %DELETE SOME TIME SAMPLES
%STATE_MATRIX_GATT = STATE_MATRIX_GATT(:,:,500:end); %DELETE SOME TIME SAMPLES
%% PACKET CHECK NOT APPLICABLE TO GATT PACKETS

%% EXTRACT TAG DATA CREATING A TIME ARRAY AND A DATA ARRAY

T_TAG = double.empty;
DATA_TAG = double.empty;
for lineNo = 1:1:length(TAG_DATA.TIMESTAMP.TIME_S_Y) 
    
    T_TAG = cat(1,T_TAG,TAG_DATA.TIMESTAMP.TIME_S_MILL(lineNo) / 1000);
    DATA_TAG = cat(1,DATA_TAG,TAG_DATA.DATA(lineNo));

end

%% ANALYZE RSSI AND STATE RECEIVED BY GATT

%i_id_1 = findNodeIndex(RSSI_MATRIX_GATT, NODE_ID_1 );
i_id_master = findNodeIndex(RSSI_MATRIX_GATT,MASTER_ID );


t_zero = T_TAG(1);%min([T_TAG(15);T_id_1]);
T_TAG = T_TAG - t_zero;
T_TAG = double(T_TAG);%/(60); 

for i_id_1 = 3:1:size(RSSI_MATRIX_GATT,1)
    
    if i_id_1 ~= i_id_master
        T_id_1 = double.empty;
        RSSI_Signal_id_1 = double.empty;
        STATE_Signal_id_1 = double.empty;
        for sampleIndex = 1:1:size(RSSI_MATRIX_GATT,3)
            
            if i_id_1 > size(RSSI_MATRIX_GATT,1)
                error('Selected ID is not contained in MATRIX');
            end
            
            if RSSI_MATRIX_GATT(i_id_master,i_id_1,sampleIndex) ~= - Inf
                RSSI_Signal_id_1 = cat(1,RSSI_Signal_id_1,RSSI_MATRIX_GATT(i_id_master,i_id_1,sampleIndex) );
                STATE_Signal_id_1 = cat(1,STATE_Signal_id_1,STATE_MATRIX_GATT(i_id_master,i_id_1,sampleIndex) );
                T_id_1 = cat(1,T_id_1,RSSI_MATRIX_GATT(1,1,sampleIndex));
            end
        end
        
        %EDIT THIS TO SHIFT TIME AXIS
        T_id_1 = T_id_1 - t_zero;
        T_id_1 = double(T_id_1);%/(60);
        
        % if length(T_id_1) > 0
        %     T_id_1 = T_id_1 - T_id_1(1);
        % end
        wsize = 30/60;
        winc = 5/60;
        
        RSSI_Signal_id_1_FILT = timeBasedSlidingAvg(T_id_1,RSSI_Signal_id_1,wsize,winc);
        T_id_1_FILT = (1:1:length(RSSI_Signal_id_1_FILT))*winc' + T_id_1(1);
        
        title_str = sprintf('Node ID: 0x%02X',RSSI_MATRIX_GATT(i_id_1,1,end));
        
        
        % figure
        % plot(T_id_1,RSSI_Signal_id_1,'o-',T_TAG,zeros(size(T_TAG)),'ro',T_id_1_FILT,RSSI_Signal_id_1_FILT,'o-')
        % xlabel('Time [min]');
        % ylabel('RSSI [dBm]');
        % legend('NODE to MASTER RSSI','TAGs','Filtered RSSI');
        % grid on;
        
%         figure(i_id_1);
%         h1 = subplot(3,1,1);
%         plot(T_id_1,RSSI_Signal_id_1,'o-');%,T_TAG,zeros(size(T_TAG)),'ro');
%         xlabel('Time [s]');
%         ylabel('RSSI [dBm]');
%         title(title_str);
%         legend('NODE to MASTER RSSI');%,'TAGs');
%         set(h1,'xlim',[min([T_id_1; T_TAG]),max([T_id_1; T_TAG])]);
%         set(h1,'ylim',[-100,1]);
%         grid on;
%         
%         h2 = subplot(3,1,2);
%         plot(T_id_1_FILT,RSSI_Signal_id_1_FILT);%,T_TAG,zeros(size(T_TAG)),'ro')
%         xlabel('Time [s]');
%         ylabel('RSSI [dBm]');
%         title(title_str);
%         legend('Filtered RSSI');%,'TAGs');
%         set(h2,'xlim',get(h1,'xlim'));
%         grid on;
        
        
        EST_DIST_id_1_FILT = RSSI_to_m(RSSI_Signal_id_1_FILT);
        %h3 = subplot(3,1,3);
        plot(T_id_1_FILT,EST_DIST_id_1_FILT,T_id_1,STATE_Signal_id_1*10,'.', T_TAG,zeros(size(T_TAG)),'o')
        xlabel('Time [s]');
        ylabel('d [m]');
        title(title_str);
        %set(h3,'xlim',get(h1,'xlim'));
        legend('Estimated distance from Master Node','Node state');
        grid on;
        
        %     figure
        %     plot(T_id_1,STATE_Signal_id_1,'o-',T_TAG,zeros(size(T_TAG)),'ro')
        %     xlabel('Time [min]');
        %     ylabel('STATE');
        %     title(title_str);
        %     legend('NODE STATE RECEIVED BY THE MASTER','TAGs');
        %     grid on;
        
        deltaT_1 = diff(T_id_1)*60;%receiving time of NODE_ID_1
        if length(T_id_1) > 0
            %         figure
            %         plot(T_id_1(2:end), deltaT_1,[T_id_1(1), T_id_1(end)], [mean(deltaT_1) , mean(deltaT_1)] ,T_TAG,zeros(size(T_TAG)),'ro' );
            %         xlabel('Time [min]');
            %         ylabel('[s]');
            %         legend('DeltaT between samples', 'Mean value', 'TAGs');
            %         title(title_str);
            %         grid on;
        end
    end
end
% figure
% plot(counter)
%
% for sampleNo = 1:1:size(STATE_MATRIX_GATT,3)
%     STATE_MATRIX_GATT(:,:,sampleNo)
%     pause;
% end


