%LINK CHECK/RECONSTRUCTION
%NOTE: GRAPH_EDGES_RSSI == -Inf (or GRAPH_EDGES_M == Inf) are usually
%associated with devices not in range, instead GRAPH_EDGES_RSSI == NaN are
%more associated with missing packets (devices that have been seen at least once).

GRAPH_EDGES_M_REC = GRAPH_EDGES_M; %IF ENABLE_LINK_RECONSTRUCTION = 0, GRAPH_EDGES_M_REC is the same of GRAPH_EDGES_M
if ENABLE_LINK_RECONSTRUCTION
    nextPercentPlotIndex = 0;
    str = [];
    if TREAT_AS_STATIC == 0 %Note: in static scenario there is no need of recostructing LINKS!
        fprintf('LINKS RECONSTRUCTION:\n');
        GRAPH_EDGES_M_REC(GRAPH_EDGES_M == Inf) = 0;
        for edgeNo = 1:size(GRAPH_EDGES_M_REC,2)
            GRAPH_EDGES_M_REC(:,edgeNo) = fillgaps(GRAPH_EDGES_M_REC(:,edgeNo)); %%this should avoid too long gaps (> 5 sec)
            %PLOT PROGRESS PERCENT DATA
            if edgeNo > nextPercentPlotIndex
                nextPercentPlotIndex = nextPercentPlotIndex + size(GRAPH_EDGES_M_REC,2)/100;
                for s=1:length(str)
                    fprintf('\b');
                end
                str = sprintf('%.2f percent of LINKS recostruction done...\n', edgeNo / size(GRAPH_EDGES_M_REC,2)*100);
                fprintf(str);
            end
        end
        GRAPH_EDGES_M_REC(GRAPH_EDGES_M == Inf) = Inf;
        
        if PLOT_VERBOSITY > 2
            for edgeNo=1:size(GRAPH_EDGES_M,2)
                h = figure;
                plot(unixToMatlabTime(T_TAG),zeros(size(T_TAG)),'ro', unixToMatlabTime(T_TICKS), GRAPH_EDGES_M(:,edgeNo),unixToMatlabTime(T_TICKS), GRAPH_EDGES_M_REC(:,edgeNo)+10);
                set(get(h,'Children'),'HitTest','off');
                xlabel('Time [s]');
                ylabel('distance [m]');
                legend('TAGs','Raw signal', 'reconstructed signal+10dBm');
                datetick('x',DATE_FORMAT);
                title('Link reconstruction response');
                grid on;
            end
        end
        % for edgeNo=1:size(GRAPH_EDGES_M,2)
        %     nanIndexes = find(isnan(GRAPH_EDGES_M(:,edgeNo)));
        %     gapEndIndexNo = 1;
        %     for gapStartIndexNo=gapEndIndexNo:length(nanIndexes)
        %         lastKnownRSSIIndex = gapStartIndexNo-1;
        %         lastKnownRSSI = GRAPH_EDGES_M(lastKnownRSSIIndex,edgeNo); %TODO:  check for overflow on GRAPH_EDGES_RSSI( nanIndexes(1)-1,edgeNo );, may be very rare (if the first sample is missing it should be -Inf and not NaN)
        %         for gapEndIndexNo=length(nanIndexes)
        %             if isempty(find(nanIndexes(gapEndIndexNo)+1 == nanIndexes,1)) %end of NaN block found
        %                 nextKnownRSSI = GRAPH_EDGES_M( nanIndexes(gapEndIndexNo)+1 ,edgeNo); %TODO:  check for overflow on GRAPH_EDGES_RSSI( nanIndexes(indexNo)+1 ,edgeNo);
        %                 nextKnownRSSIIndex = nanIndexes(gapEndIndexNo)+1;
        %                 nanBlockLength = nextKnownRSSIIndex - lastKnownRSSIIndex - 1;
        %                 predictionSlope = (nextKnownRSSI - lastKnownRSSI)/(nanBlockLength+2);
        %                 GRAPH_EDGES_M_REC(lastKnownRSSIIndex + 1:nextKnownRSSIIndex - 1, edgeNo) = lastKnownRSSI+((1:nanBlockLength).*predictionSlope);
        %                 %reset state for the new NaN block
        %                 if gapEndIndexNo ~= length(nanIndexes)
        %                     lastKnownRSSI = GRAPH_EDGES_M(nanIndexes(gapEndIndexNo+1)-1,edgeNo);
        %                     lastKnownRSSIIndex = nanIndexes(gapEndIndexNo+1)-1;
        %                 end
        %             end
        %         end
        %     end
        %
        % end
    end
    
    for s=1:(length(str))
        fprintf('\b');
    end
    fprintf('100 percent of LINKS recostruction done...\n');
    fprintf('Done!\n\n');
end