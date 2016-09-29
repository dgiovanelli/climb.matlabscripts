fprintf('RECALCULATING DISTANCE MATRIX AFTER RESAMPLING:\n');
DISTANCE_MATRIX = Inf*ones(size(AVAILABLE_IDs,1),size(AVAILABLE_IDs,1),size(graphEdeges_m_filt,1));
for sampleIndex = 1:1:size(t_w,1)
    pair = 1;
    for node1_idx=1:size(AVAILABLE_IDs,1)-1
        for node2_idx=node1_idx+1:size(AVAILABLE_IDs,1)
            DISTANCE_MATRIX(node1_idx,node2_idx,sampleIndex) = graphEdeges_m_filt(sampleIndex,pair);
            DISTANCE_MATRIX(node2_idx,node1_idx,sampleIndex) = graphEdeges_m_filt(sampleIndex,pair);
            DISTANCE_MATRIX(1,1,sampleIndex) = t_w(sampleIndex);
            pair = pair + 1;
         end
    end
end