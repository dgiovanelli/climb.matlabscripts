fprintf('RECALCULATING DISTANCE MATRIX:\n');
DISTANCE_MATRIX = Inf*ones(size(AVAILABLE_IDs,1)+1,size(AVAILABLE_IDs,1)+1,size(graphEdeges_m_filt,1));
DISTANCE_MATRIX_post_loc = Inf*ones(size(AVAILABLE_IDs,1)+1,size(AVAILABLE_IDs,1)+1,size(graphEdeges_m_filt,1));
for sampleIndex = 1:1:size(DISTANCE_MATRIX,3)
    pair = 1;
    DISTANCE_MATRIX(2:end,1,sampleIndex) = AVAILABLE_IDs;
    DISTANCE_MATRIX(1,2:end,sampleIndex) = AVAILABLE_IDs;
    for node1_idx=2:size(AVAILABLE_IDs,1)
        for node2_idx=node1_idx+1:size(AVAILABLE_IDs,1)+1
            %recalculate distance matrix after resampling, link recostruction and filtering
            DISTANCE_MATRIX(node1_idx,node2_idx,sampleIndex) = graphEdeges_m_filt(sampleIndex,pair);
            DISTANCE_MATRIX(node2_idx,node1_idx,sampleIndex) = graphEdeges_m_filt(sampleIndex,pair);
            DISTANCE_MATRIX(1,1,sampleIndex) = t_w(sampleIndex);
            
            if ~sum(links(:,pair) == AVAILABLE_IDs(node1_idx-1)) == 1 && ~sum(links(:,pair) == AVAILABLE_IDs(node2_idx-1)) == 1
                error('There is an error in the order of nodes in AVAILABLE_IDs or [links graphEdeges_m_filt]'); %%if this is not called the node ordering in DISTANCE_MATRIX is the same as AVAILABLE_IDs
            end
            
            %recalculate distance matrix after localization
            x_y_node_dist = nodePositionXY(node1_idx-1,2:3,sampleIndex) - nodePositionXY(node2_idx-1,2:3,sampleIndex);
            node_dist = sqrt(x_y_node_dist(1)^2 + x_y_node_dist(2)^2);
            
            DISTANCE_MATRIX_post_loc(node1_idx,node2_idx,sampleIndex) = node_dist;
            DISTANCE_MATRIX_post_loc(node2_idx,node1_idx,sampleIndex) = node_dist;
            DISTANCE_MATRIX_post_loc(1,1,sampleIndex) = t_w(sampleIndex);
            DISTANCE_MATRIX_post_loc(1,node1_idx,sampleIndex) = nodePositionXY(node1_idx-1,1,sampleIndex);
            DISTANCE_MATRIX_post_loc(node1_idx,1,sampleIndex) = nodePositionXY(node1_idx-1,1,sampleIndex);
            DISTANCE_MATRIX_post_loc(1,node2_idx,sampleIndex) = nodePositionXY(node2_idx-1,1,sampleIndex);
            DISTANCE_MATRIX_post_loc(node2_idx,1,sampleIndex) = nodePositionXY(node2_idx-1,1,sampleIndex);
            pair = pair + 1;
         end
    end
end