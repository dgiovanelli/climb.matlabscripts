
%COUNTER/BATTERY CHECK
if SHOW_BATTERY_VOLTAGE == 1
    fprintf('GETTING BATTERY VOLTAGE DATA.\n');
    %% BATTERY CHECK
    colorlist=hsv(size(AVAILABLE_IDs,1));
    legendStrs = cell(size(AVAILABLE_IDs(AVAILABLE_IDs ~= 256 & AVAILABLE_IDs ~= 254),1),1);
    nodesBatteryData = cell(size(AVAILABLE_IDs(AVAILABLE_IDs ~= 256 & AVAILABLE_IDs ~= 254),1),1);
    i_nodes_data = 1;
    for i_id = 2:1:size(AVAILABLE_IDs,1)+1
        if RSSI_MATRIX(i_id,1,end) ~= 256 && RSSI_MATRIX(i_id,1,end) ~= 254
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
            nodesBatteryData{i_nodes_data}.ID = AVAILABLE_IDs(i_id-1);
            nodesBatteryData{i_nodes_data}.BATT_Volt_milliV = BATT_Volt_milliV_temp(1:storedSamples);
            nodesBatteryData{i_nodes_data}.T_batt_volt = T_batt_volt_temp(1:storedSamples);
            
            if ~isempty(nodesBatteryData{i_nodes_data}.T_batt_volt)
                legendStrs{i_nodes_data} = sprintf('ID: 0x%02x',nodesBatteryData{i_nodes_data}.ID);              
                figure(25)
                plot(unixToMatlabTime(nodesBatteryData{i_nodes_data}.T_batt_volt), nodesBatteryData{i_nodes_data}.BATT_Volt_milliV ,'.', 'col',colorlist(i_id-1,:) );
                datetick('x',DATE_FORMAT);
                axis([unixToMatlabTime(RSSI_MATRIX(1,1,1)), unixToMatlabTime(RSSI_MATRIX(1,1,end)), 0, 3300]);
                xlabel('Time [s]');
                ylabel('battery voltage [mV]');
                grid on;
                hold on;
            end
            
            i_nodes_data = i_nodes_data + 1;
        end
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
    
    fprintf('PACKET CHECK STATISTICS (ONLY FOR ADV DATA!!):\n');
    fprintf('Node ID | received packets | missing packets | PEr\n');
    for nodeNo = 1 : size(packetStat,1)
        fprintf('0x%02X      | %d               | %d              | %.2f %%\n',packetStat(nodeNo,1), packetStat(nodeNo,2), packetStat(nodeNo,3) ,  packetStat(nodeNo,3) / (packetStat(nodeNo,2) + packetStat(nodeNo,3))*100 );
    end
    fprintf('\n');
end
