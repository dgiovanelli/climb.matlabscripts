%% ANALYZE RELATIONS BETWEEN NODES
GRAPH_EDGES_RSSI = double.empty;
LINKS=double.empty;
T_TICKS=double.empty;

% graphEdeges_RSSI_2to1 = double.empty;
% graphEdeges_RSSI_1to2 = double.empty;
% t_2to1=double.empty;
% t_1to2=double.empty;
% relations2to1=double.empty;
% relations1to2=double.empty;

wsize = W_SIZE_S / TICK_DURATION_S;
winc = W_INCR_S / TICK_DURATION_S;
colorlist=hsv( (size(RSSI_MATRIX,1)^2-2*(size(RSSI_MATRIX,1)-1)-size(RSSI_MATRIX,1))/2 );
i=1;
focusId1 = findNodeIndex(RSSI_MATRIX, FOCUS_ID_1 );
focusId2 = findNodeIndex(RSSI_MATRIX, FOCUS_ID_2 );
emptySignalsCount = 0;
signalsCount = 0;
nextPercentPlotIndex = 0;
str = [];
positive_RSSI_count_2to1 = 0;
positive_RSSI_count_1to2 = 0;
        
fprintf('RESAMPLIG DATA LINKS:\n');
for i_id_1 = 2:1:(size(RSSI_MATRIX,1)-1)
    for i_id_2 = i_id_1+1:size(RSSI_MATRIX,2)
        T_2to1 = double.empty;
        T_1to2 = double.empty;
        RSSI_Signal_2to1 = double.empty;
        RSSI_Signal_1to2 = double.empty;
        RSSI_Signal_W = double.empty;
              
        for sampleIndex = 1:1:size(RSSI_MATRIX,3) %SCAN ALL TIMESAMPLES AND EXTRACT RSSI DATA BETWEEN i_id_1 AND i_id_2
            
            if RSSI_MATRIX(i_id_1,i_id_2,sampleIndex) ~= -Inf %IF THIS IS FALSE, THIS TIMESAMPLE DOESN'T HAVE THIS LINK (AT LEAST IN THIS DIRECTION)
                if RSSI_MATRIX(i_id_1,i_id_2,sampleIndex) < 0 %if the RSSI is positive it means that the node_1 has an old information (old RSSI value) regarding node_2, so it is better to discard it, anyway 'old' value are kept till timeout (NODE_TIMEOUT_OS_TICKS) with inverse sign 
                    RSSI_Signal_2to1 = cat(1,RSSI_Signal_2to1,RSSI_MATRIX(i_id_1,i_id_2,sampleIndex));
                    T_2to1 = cat(1,T_2to1,RSSI_MATRIX(1,1,sampleIndex));
                else
                    positive_RSSI_count_2to1 = positive_RSSI_count_2to1 + 1;
                end
            end
            
            if RSSI_MATRIX(i_id_2,i_id_1,sampleIndex) ~= -Inf %IF THIS IS FALSE, THIS TIMESAMPLE DOESN'T HAVE THIS LINK (AT LEAST IN THIS DIRECTION)
                if RSSI_MATRIX(i_id_2,i_id_1,sampleIndex) < 0 %if the RSSI is positive it means that the node_2 has an old information (old RSSI value) regarding node_1, so it is better to discard it, anyway 'old' value are kept till timeout (NODE_TIMEOUT_OS_TICKS) with inverse sign 
                    RSSI_Signal_1to2 = cat(1,RSSI_Signal_1to2,RSSI_MATRIX(i_id_2,i_id_1,sampleIndex));
                    T_1to2 = cat(1,T_1to2,RSSI_MATRIX(1,1,sampleIndex));
                else
                    positive_RSSI_count_1to2 = positive_RSSI_count_2to1 + 1;
                end
            end
            
        end

%         if RSSI_MATRIX(i_id_1,1,1) == 54
%             warning('54 (0x36) found');
%         end
        %if (size(T_2to1,1) > 1) || (size(T_1to2,1) > 1) %IF AT LEAST ONE OF THE LINKS HAS DATA GO ON
        if ~isempty(T_2to1) || ~isempty(T_1to2) %IF AT LEAST ONE OF THE LINKS HAS DATA, GO ON!
            RSSI_Signal_W = timeBasedTwoDirectionsMerge(T_2to1, RSSI_Signal_2to1, T_1to2, RSSI_Signal_1to2, wsize, winc); %THIS MERGES RSSI DATA FROM BOTH DIRECTION AND RESAMPLE IT AT winc INTERVAL
            if ~isempty(RSSI_Signal_W)
                if (isempty(T_2to1) + isempty(T_1to2)) == 0 % both are non empty
                    t_merge = ( (0:1:(size(RSSI_Signal_W,1)-1))*winc + winc/2 + double(min([ T_2to1',T_1to2' ])) )';
                    legend2to1Str = sprintf('raw 0x%02x to 0x%02x',RSSI_MATRIX(i_id_2,1,1),RSSI_MATRIX(i_id_1,1,1) );
                    legend1to2Str = sprintf('raw 0x%02x to 0x%02x',RSSI_MATRIX(i_id_1,1,1),RSSI_MATRIX(i_id_2,1,1) );
                    legendStrs = {'merged-filtered-resampled',legend2to1Str,legend1to2Str,'TAGS'};
                elseif isempty(T_1to2)
                    t_merge = ( (0:1:(size(RSSI_Signal_W,1)-1))*winc + winc/2 + double(min(T_2to1)) )';
                    legend2to1Str = sprintf('raw 0x%02x to 0x%02x',RSSI_MATRIX(i_id_2,1,1),RSSI_MATRIX(i_id_1,1,1) );
                    legendStrs = {'merged-filtered-resampled',legend2to1Str,'TAGS'};
                else % T_2to1 is empty
                    t_merge = ( (0:1:(size(RSSI_Signal_W,1)-1))*winc + winc/2 + double(min(T_1to2)) )';
                    legend1to2Str = sprintf('raw 0x%02x to 0x%02x',RSSI_MATRIX(i_id_1,1,1),RSSI_MATRIX(i_id_2,1,1) );
                    legendStrs = {'merged-filtered-resampled',legend1to2Str,'TAGS'};
                end
                % PLOT FOCUS IDS RSSI IF ANY
                if( (FOCUS_ID_1 == RSSI_MATRIX(i_id_1,1,1) && FOCUS_ID_2 == RSSI_MATRIX(i_id_2,1,1)) || (FOCUS_ID_1 == RSSI_MATRIX(i_id_2,1,1) && FOCUS_ID_2 == RSSI_MATRIX(i_id_1,1,1))) && PLOT_VERBOSITY <= 2
                    figure;
                    
                    subplot(1,2,1);
                    plot(unixToMatlabTime(t_merge),RSSI_Signal_W,'.',unixToMatlabTime(T_2to1),RSSI_Signal_2to1,'.',unixToMatlabTime(T_1to2),RSSI_Signal_1to2,'.',unixToMatlabTime(T_TAG),-100*ones(size(T_TAG)),'ro');
                    legend(legendStrs);
                    datetick('x',DATE_FORMAT);
                    hold off;
                    xlabel('Time [s]');
                    ylabel('RSSI [dBm]');
                    grid on;
                    title('RSSI between FOCUS ID1 and FOCUS ID2');
                    
                    subplot(1,2,2)
                    plot(unixToMatlabTime(T_TAG),zeros(size(T_TAG)),'ro',unixToMatlabTime(T_2to1(2:end)),diff(T_2to1*TICK_DURATION_S),'.',unixToMatlabTime(T_1to2(2:end)),diff(T_1to2*TICK_DURATION_S),'.');
                    legend('TAGS','diff T_{2to1}','diff T_{1to2}');
                    datetick('x',DATE_FORMAT);
                    hold off;
                    xlabel('Time [s]');
                    ylabel('T diff [s]');
                    grid on;
                    title_str = sprintf('T diff of link between FOCUS ID1 and FOCUS ID2');
                    title(title_str);
                end
                if PLOT_VERBOSITY > 2
                    figure;
                    subplot(1,2,1)
                    plot(unixToMatlabTime(t_merge),RSSI_Signal_W,unixToMatlabTime(T_2to1),RSSI_Signal_2to1,'.',unixToMatlabTime(T_1to2),RSSI_Signal_1to2,'.',unixToMatlabTime(T_TAG),-100*ones(size(T_TAG)),'ro');
                    legend(legendStrs);
                    datetick('x',DATE_FORMAT);
                    hold off;
                    xlabel('Time [s]');
                    ylabel('RSSI [dBm]');
                    grid on;
                    title_str = sprintf('RSSI of linkNo: %d',size(LINKS,2)-1);
                    title(title_str);
                    
                    subplot(1,2,2)
                    plot(unixToMatlabTime(T_TAG),zeros(size(T_TAG)),'ro',unixToMatlabTime(T_2to1(2:end)),diff(T_2to1*TICK_DURATION_S),'.',unixToMatlabTime(T_1to2(2:end)),diff(T_1to2*TICK_DURATION_S),'.');
                    datetick('x',DATE_FORMAT);
                    legend('TAGS','diff T_{2to1}','diff T_{1to2}');
                    hold off;
                    xlabel('Time [s]');
                    ylabel('T diff [s]');
                    grid on;
                    title_str = sprintf('T diff of linkNo: %d',size(LINKS,2)-1);
                    title(title_str);
                end
                if isempty(T_TICKS) %% this is run only once at the first iteration of the nested loops
                    GRAPH_EDGES_RSSI = RSSI_Signal_W;
                    T_TICKS = t_merge;
                    %LINKS = [RSSI_MATRIX(1,i_id_1,1); RSSI_MATRIX(1,i_id_2,1)];
                else
                    if ((min(T_TICKS) - winc/2) >= min(t_merge)) || (max(t_merge) > ( (max(T_TICKS) + winc/2) )) %%the t_merge values are not contained within T_TICKS
                        if (min(T_TICKS) -  winc/2) >= min(t_merge) %%the current T_2to1_W array starts before t_2to1 array
                            % CREATE THE MISSING TIME VALUES
                            t_ticks_temp = (min(T_TICKS)-winc:-winc:min(t_merge)-winc)';
                            % APPEND THEM TO THE OLD T_TICKS
                            T_TICKS = cat(1,t_ticks_temp,T_TICKS);
                            
                            % CREATE MISSING GRAPH_EDGES_RSSI SAMPLES
                            graph_edeges_RSSI_temp = ones(size(T_TICKS,1),size(GRAPH_EDGES_RSSI,2)+1) * (-Inf);
                            graph_edeges_RSSI_temp( size(t_ticks_temp,1)+1:end,1:size(GRAPH_EDGES_RSSI,2) ) = GRAPH_EDGES_RSSI; %INSERT THE OLD VALUES OF GRAPH_EDGES_RSSI IN THE RESIZED VERSION graph_edeges_RSSI_temp
                            
                            % APPEND THE NEW DATA
                            if( size(RSSI_Signal_W,1) <= size(graph_edeges_RSSI_temp,1) )
                                graph_edeges_RSSI_temp(1:size(RSSI_Signal_W,1),end) = RSSI_Signal_W;
                            else  % if the new data array starts before and ends after the old data copy only the part that starts before, the part that ends after will be copied in the next 'if'
                                graph_edeges_RSSI_temp(1:end,end) = RSSI_Signal_W(1:size(graph_edeges_RSSI_temp,1));
                            end
                            % REPLACE THE OLD GRAPH_EDGES_RSSI VERSION WITH THE NEW ONE
                            GRAPH_EDGES_RSSI = graph_edeges_RSSI_temp;
                            
                            if max(t_merge) > (max(T_TICKS) + winc/2) %%the current T_2to1_W array also finishes after t_2to1 array
                                % CREATE THE MISSING TIME VALUES
                                t_ticks_temp = (max(T_TICKS)+winc:winc:max(t_merge))';
                                % APPEND THEM TO THE OLD T_TICKS
                                T_TICKS = cat(1,T_TICKS,t_ticks_temp);
                                
                                % CREATE MISSING GRAPH_EDGES_RSSI SAMPLES
                                graph_edeges_RSSI_temp = ones(size(T_TICKS,1),size(GRAPH_EDGES_RSSI,2)) * (-Inf);
                                graph_edeges_RSSI_temp( 1:size(GRAPH_EDGES_RSSI,1) ,1:size(GRAPH_EDGES_RSSI,2) ) = GRAPH_EDGES_RSSI;
                                graph_edeges_RSSI_temp(end-size(RSSI_Signal_W,1)+1 : end,end) = RSSI_Signal_W;
                                % REPLACE THE OLD GRAPH_EDGES_RSSI VERSION WITH THE NEW ONE
                                GRAPH_EDGES_RSSI = graph_edeges_RSSI_temp;
                            end
                        elseif max(t_merge) > (max(T_TICKS) + winc/2 ) %%the current T_2to1_W array finishes after t_2to1 array
                            % CREATE THE MISSING TIME VALUES
                            t_ticks_temp = (max(T_TICKS)+winc:winc:max(t_merge))';
                            % APPEND THEM TO THE OLD T_TICKS
                            T_TICKS = cat(1,T_TICKS,t_ticks_temp);
                            
                            % CREATE MISSING GRAPH_EDGES_RSSI SAMPLES
                            graph_edeges_RSSI_temp = ones(size(T_TICKS,1),size(GRAPH_EDGES_RSSI,2)+1) * (-Inf);
                            graph_edeges_RSSI_temp( 1:size(GRAPH_EDGES_RSSI,1) ,1:size(GRAPH_EDGES_RSSI,2) ) = GRAPH_EDGES_RSSI;
                            graph_edeges_RSSI_temp(end-size(RSSI_Signal_W,1)+1 : end,end) = RSSI_Signal_W;
                            % REPLACE THE OLD GRAPH_EDGES_RSSI VERSION WITH THE NEW ONE
                            GRAPH_EDGES_RSSI = graph_edeges_RSSI_temp;
                        end
                    else % THE t_merge ARE CONTAINED WITHIN T_TICKS
                        % CREATE MISSING GRAPH_EDGES_RSSI SAMPLES
                        graph_edeges_RSSI_temp = ones(size(T_TICKS,1),size(GRAPH_EDGES_RSSI,2)+1) * (-Inf);
                        graph_edeges_RSSI_temp(1:end,1:end-1) = GRAPH_EDGES_RSSI;
                        tmp = abs(T_TICKS-min(t_merge));
                        [ ~ , startingindex] = min(tmp);
                        graph_edeges_RSSI_temp(startingindex:startingindex+length(RSSI_Signal_W)-1,end) = RSSI_Signal_W;
                        % REPLACE THE OLD GRAPH_EDGES_RSSI VERSION WITH THE NEW ONE
                        GRAPH_EDGES_RSSI = graph_edeges_RSSI_temp;
                    end
                end
                signalsCount = signalsCount + 1;
                if size(GRAPH_EDGES_RSSI,2) ~= signalsCount + emptySignalsCount
                    error('something wrong appened');
                end
            else %create an -Inf signal that replace the missing edge
                graph_edeges_RSSI_temp = ones(size(T_TICKS,1),size(GRAPH_EDGES_RSSI,2)+1) * (-Inf);
                graph_edeges_RSSI_temp( 1:size(GRAPH_EDGES_RSSI,1) ,1:size(GRAPH_EDGES_RSSI,2) ) = GRAPH_EDGES_RSSI;
                % REPLACE THE OLD GRAPH_EDGES_RSSI VERSION WITH THE NEW ONE
                GRAPH_EDGES_RSSI = graph_edeges_RSSI_temp;
                emptySignalsCount = emptySignalsCount + 1;
            end
            
            LINKS = cat(2,LINKS, [RSSI_MATRIX(1,i_id_1,1); RSSI_MATRIX(1,i_id_2,1)]);
            
            if i > nextPercentPlotIndex
                nextPercentPlotIndex = nextPercentPlotIndex + 5;
                for s=1:(length(str))
                    fprintf('\b');
                end
                str = sprintf('%.2f percent done...\n',i/((size(RSSI_MATRIX,1)^2-2*(size(RSSI_MATRIX,1)-1)-size(RSSI_MATRIX,1))/2)*100);
                fprintf(str);
            end
            i = i+1;
        else %the signal is empty. Store a NaN signal
            %TODO:CHECK!!!!!
            if isempty(T_TICKS)
                GRAPH_EDGES_RSSI = -Inf;
                T_TICKS = RSSI_MATRIX(1,1,round(size(RSSI_MATRIX,3)/2));
            else
                graph_edeges_RSSI_temp = ones(size(T_TICKS,1),size(GRAPH_EDGES_RSSI,2)+1) * (-Inf);
                graph_edeges_RSSI_temp( 1:size(GRAPH_EDGES_RSSI,1) ,1:size(GRAPH_EDGES_RSSI,2) ) = GRAPH_EDGES_RSSI;
                % REPLACE THE OLD GRAPH_EDGES_RSSI VERSION WITH THE NEW ONE
                GRAPH_EDGES_RSSI = graph_edeges_RSSI_temp;
            end
            emptySignalsCount = emptySignalsCount + 1;
            LINKS = cat(2,LINKS, [RSSI_MATRIX(1,i_id_1,1); RSSI_MATRIX(1,i_id_2,1)]);
        end
    end
end


% t_zero = min([T_TAG;T_TICKS]);
% T_TAG = T_TAG - t_zero;
% T_TICKS = T_TICKS - double(t_zero);

for s=1:(length(str))
    fprintf('\b');
end
fprintf('100 percent done...\n');
fprintf('Done!\n\n');