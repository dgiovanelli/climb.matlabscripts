%LINK CHECK/RECONSTRUCTION
%NOTE: graphEdeges_RSSI == -Inf (or graphEdeges_m == Inf) are usually
%associated with devices not in range, instead graphEdeges_RSSI == NaN are
%more associated with missing packets (devices that have been seen at least once).
warning('ATTENTION: the link recostruction is not working well, CHECK IT!!');
fprintf('LINKS RECONSTRUCTION CHECK:\n');
for edgeNo=1:size(graphEdeges_m,2)
    nanIndexes = find(isnan(graphEdeges_m(:,edgeNo)));
    if ~isempty(nanIndexes)
        lastKnownRSSI = graphEdeges_m(nanIndexes(1)-1,edgeNo); %TODO:  check for overflow on graphEdeges_RSSI( nanIndexes(1)-1,edgeNo );, may be very rare (if the first sample is missing it should be -Inf and not NaN)
        lastKnownRSSIIndex = nanIndexes(1)-1;
        for indexNo=1:length(nanIndexes)
            if isempty(find(nanIndexes(indexNo)+1 == nanIndexes,1)) %end of NaN block found
                nextKnownRSSI = graphEdeges_m( nanIndexes(indexNo)+1 ,edgeNo); %TODO:  check for overflow on graphEdeges_RSSI( nanIndexes(indexNo)+1 ,edgeNo);
                nextKnownRSSIIndex = nanIndexes(indexNo)+1;
                nanBlockLength = nextKnownRSSIIndex - lastKnownRSSIIndex - 1;
                predictionSlope = (nextKnownRSSI - lastKnownRSSI)/(nanBlockLength+2);
                graphEdeges_m(lastKnownRSSIIndex + 1:nextKnownRSSIIndex - 1, edgeNo) = lastKnownRSSI+((1:nanBlockLength).*predictionSlope);
                %reset state for the new NaN block
                if indexNo ~= length(nanIndexes)
                    lastKnownRSSI = graphEdeges_m(nanIndexes(indexNo+1)-1,edgeNo);
                    lastKnownRSSIIndex = nanIndexes(indexNo+1)-1;
                end
            end
        end
    end
end
fprintf('Done!\n\n');