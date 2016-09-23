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
                RSSI_Signal_2to1 = cat(1,RSSI_Signal_2to1,RSSI_MATRIX(i_id_1,i_id_2,sampleIndex));
                T_2to1 = cat(1,T_2to1,RSSI_MATRIX(1,1,sampleIndex));
            end
            
            if RSSI_MATRIX(i_id_2,i_id_1,sampleIndex) ~= -Inf %IF THIS IS FALSE, THIS TIMESAMPLE DOESN'T HAVE THIS LINK (AT LEAST IN THIS DIRECTION)
                RSSI_Signal_1to2 = cat(1,RSSI_Signal_1to2,RSSI_MATRIX(i_id_2,i_id_1,sampleIndex));
                T_1to2 = cat(1,T_1to2,RSSI_MATRIX(1,1,sampleIndex));
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
                    T_W = ( (1:1:size(RSSI_Signal_W,1))*winc + double(min([ T_2to1',T_1to2' ])) )';
                    legend2to1Str = sprintf('raw 0x%02x to 0x%02x',RSSI_MATRIX(i_id_2,1,1),RSSI_MATRIX(i_id_1,1,1) );
                    legend1to2Str = sprintf('raw 0x%02x to 0x%02x',RSSI_MATRIX(i_id_1,1,1),RSSI_MATRIX(i_id_2,1,1) );
                    legendStrs = {'merged-filtered-resampled',legend2to1Str,legend1to2Str};
                elseif isempty(T_1to2)
                    T_W = ( (1:1:size(RSSI_Signal_W,1))*winc + double(min(T_2to1)) )';
                    legend2to1Str = sprintf('raw 0x%02x to 0x%02x',RSSI_MATRIX(i_id_2,1,1),RSSI_MATRIX(i_id_1,1,1) );
                    legendStrs = {'merged-filtered-resampled',legend2to1Str};
                else % T_2to1 is empty
                    T_W = ( (1:1:size(RSSI_Signal_W,1))*winc + double(min(T_1to2)) )';
                    legend1to2Str = sprintf('raw 0x%02x to 0x%02x',RSSI_MATRIX(i_id_1,1,1),RSSI_MATRIX(i_id_2,1,1) );
                    legendStrs = {'merged-filtered-resampled',legend1to2Str};
                end
                % PLOT FOCUS IDS RSSI IF ANY
                if( (focusId1 == RSSI_MATRIX(i_id_1,1,1) && focusId2 == RSSI_MATRIX(i_id_2,1,1)) || (focusId1 == RSSI_MATRIX(i_id_2,1,1) && focusId2 == RSSI_MATRIX(i_id_1,1,1)) || PLOT_VERBOSITY > 2)
                    figure;
                    plot(T_W*TICK_DURATION,RSSI_Signal_W,T_2to1*TICK_DURATION,RSSI_Signal_2to1,'.',T_1to2*TICK_DURATION,RSSI_Signal_1to2,'.');
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


t_zero = min([T_TAG;t_w]);
T_TAG = T_TAG - t_zero;
t_w = t_w - double(t_zero);

for s=1:(length(str))
    fprintf('\b');
end
fprintf('100 percent done...\n');
fprintf('Done!\n\n');