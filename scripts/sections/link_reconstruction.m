%LINK CHECK/RECONSTRUCTION
%NOTE: graphEdeges_RSSI == -Inf (or graphEdeges_m == Inf) are usually
%associated with devices not in range, instead graphEdeges_RSSI == NaN are
%more associated with missing packets (devices that have been seen at least once).

graphEdeges_m_rec = graphEdeges_m;
if ENABLE_LINK_RECONSTRUCTION
    nextPercentPlotIndex = 0;
    str = [];
    if TREAT_AS_STATIC == 0 %in static scenario there no need of recostructing links!
        fprintf('LINKS RECONSTRUCTION:\n');
        graphEdeges_m_rec(graphEdeges_m == Inf) = 0;
        for edgeNo = 1:size(graphEdeges_m_rec,2)
            graphEdeges_m_rec(:,edgeNo) = fillgaps(graphEdeges_m_rec(:,edgeNo)); %%this should avoid too long gaps (> 5 sec)
            %PLOT PROGRESS PERCENT DATA
            if edgeNo > nextPercentPlotIndex
                nextPercentPlotIndex = nextPercentPlotIndex + size(graphEdeges_m_rec,2)/100;
                for s=1:length(str)
                    fprintf('\b');
                end
                str = sprintf('%.2f percent of links recostruction done...\n', edgeNo / size(graphEdeges_m_rec,2)*100);
                fprintf(str);
            end
        end
        graphEdeges_m_rec(graphEdeges_m == Inf) = Inf;
        
        if PLOT_VERBOSITY > 2
            for edgeNo=1:size(graphEdeges_m,2)
                h = figure;
                plot(T_TAG*TICK_DURATION,zeros(size(T_TAG)),'ro', t_w*TICK_DURATION, graphEdeges_m(:,edgeNo),t_w*TICK_DURATION, graphEdeges_m_rec(:,edgeNo)+10);
                set(get(h,'Children'),'HitTest','off');
                xlabel('Time [s]');
                ylabel('distance [m]');
                legend('TAGs','Raw signal', 'reconstructed signal+10dBm');
                title('Link reconstruction response');
                grid on;
            end
        end
        % for edgeNo=1:size(graphEdeges_m,2)
        %     nanIndexes = find(isnan(graphEdeges_m(:,edgeNo)));
        %     gapEndIndexNo = 1;
        %     for gapStartIndexNo=gapEndIndexNo:length(nanIndexes)
        %         lastKnownRSSIIndex = gapStartIndexNo-1;
        %         lastKnownRSSI = graphEdeges_m(lastKnownRSSIIndex,edgeNo); %TODO:  check for overflow on graphEdeges_RSSI( nanIndexes(1)-1,edgeNo );, may be very rare (if the first sample is missing it should be -Inf and not NaN)
        %         for gapEndIndexNo=length(nanIndexes)
        %             if isempty(find(nanIndexes(gapEndIndexNo)+1 == nanIndexes,1)) %end of NaN block found
        %                 nextKnownRSSI = graphEdeges_m( nanIndexes(gapEndIndexNo)+1 ,edgeNo); %TODO:  check for overflow on graphEdeges_RSSI( nanIndexes(indexNo)+1 ,edgeNo);
        %                 nextKnownRSSIIndex = nanIndexes(gapEndIndexNo)+1;
        %                 nanBlockLength = nextKnownRSSIIndex - lastKnownRSSIIndex - 1;
        %                 predictionSlope = (nextKnownRSSI - lastKnownRSSI)/(nanBlockLength+2);
        %                 graphEdeges_m_rec(lastKnownRSSIIndex + 1:nextKnownRSSIIndex - 1, edgeNo) = lastKnownRSSI+((1:nanBlockLength).*predictionSlope);
        %                 %reset state for the new NaN block
        %                 if gapEndIndexNo ~= length(nanIndexes)
        %                     lastKnownRSSI = graphEdeges_m(nanIndexes(gapEndIndexNo+1)-1,edgeNo);
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
    fprintf('100 percent of links recostruction done...\n');
    fprintf('Done!\n\n');
end