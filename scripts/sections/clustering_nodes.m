epsilon=12;
MinPts=1;
if TREAT_AS_STATIC == 0
    IDX_PRE_LOC = -Inf*ones(size(AVAILABLE_IDs,1),2,size(DISTANCE_MATRIX,3)); %the first column will containt the node ID, the second will contain the cluster number
    IDX_POST_LOC = -Inf*ones(size(AVAILABLE_IDs,1),2,size(DISTANCE_MATRIX,3)); %the first column will containt the node ID, the second will contain the cluster number
    
    fprintf('CLUSTERING NODES:\n');
    for sampleIndex = 1:size(DISTANCE_MATRIX,3)
        IDX_PRE_LOC(:,2,sampleIndex)=DBSCAN(DISTANCE_MATRIX(2:end,2:end,sampleIndex),epsilon,MinPts);
        IDX_PRE_LOC(:,1,sampleIndex)=DISTANCE_MATRIX(2:end,1,sampleIndex);
    end
    for sampleIndex = 1:size(DISTANCE_MATRIX_POST_LOC,3)
        IDX_POST_LOC(:,2,sampleIndex)=DBSCAN(DISTANCE_MATRIX_POST_LOC(2:end,2:end,sampleIndex),epsilon,MinPts);
        IDX_POST_LOC(:,1,sampleIndex)=DISTANCE_MATRIX_POST_LOC(2:end,1,sampleIndex);
    end
    
    IDX_pre_loc_reordered = zeros(size(IDX_PRE_LOC));
    IDX_post_loc_reordered = zeros(size(IDX_POST_LOC));
    for nodeIdx=1:size(AVAILABLE_IDs,1) %reorder following the same order of NODE_POSITION_ID_XY(nodeIdx,1,:)
        for sampleIndex = 1:size(IDX_PRE_LOC,3)
            IDX_pre_loc_reordered(nodeIdx,:,sampleIndex) =  IDX_PRE_LOC(IDX_PRE_LOC(:,1,sampleIndex) == NODE_POSITION_ID_XY(nodeIdx,1,sampleIndex),:,sampleIndex); %this should have no effect since the nodes in DISTANCE_MATRIX should have the same order of AVAILABLE_IDs
        end
        for sampleIndex = 1:size(IDX_POST_LOC,3)
            IDX_post_loc_reordered(nodeIdx,:,sampleIndex) =  IDX_POST_LOC(IDX_POST_LOC(:,1,sampleIndex) == NODE_POSITION_ID_XY(nodeIdx,1,sampleIndex),:,sampleIndex);
        end
    end
    fprintf('Done!\n\n');
    IDX_PRE_LOC = IDX_pre_loc_reordered;
    IDX_POST_LOC = IDX_post_loc_reordered;    
else
    IDX_PRE_LOC = -Inf*ones(size(AVAILABLE_IDs,1),2,1); %the first column will containt the node ID, the second will contain the cluster number
    IDX_POST_LOC = -Inf*ones(size(AVAILABLE_IDs,1),2,1); %the first column will containt the node ID, the second will contain the cluster number
    
    fprintf('CLUSTERING NODES:\n');
    for sampleIndex = 1:1
        IDX_PRE_LOC(:,2,sampleIndex)=DBSCAN(DISTANCE_MATRIX(2:end,2:end,sampleIndex),epsilon,MinPts);
        IDX_PRE_LOC(:,1,sampleIndex)=DISTANCE_MATRIX(2:end,1,sampleIndex);
    end
    for sampleIndex = 1:1
        IDX_POST_LOC(:,2,sampleIndex)=DBSCAN(DISTANCE_MATRIX_POST_LOC(2:end,2:end,sampleIndex),epsilon,MinPts);
        IDX_POST_LOC(:,1,sampleIndex)=DISTANCE_MATRIX_POST_LOC(2:end,1,sampleIndex);
    end
    
    IDX_pre_loc_reordered = zeros(size(IDX_PRE_LOC));
    IDX_post_loc_reordered = zeros(size(IDX_POST_LOC));
    for nodeIdx=1:size(AVAILABLE_IDs,1) %reorder following the same order of NODE_POSITION_ID_XY(nodeIdx,1,:)
        for sampleIndex = 1:size(IDX_PRE_LOC,3)
            IDX_pre_loc_reordered(nodeIdx,:,sampleIndex) =  IDX_PRE_LOC(IDX_PRE_LOC(:,1,sampleIndex) == NODE_POSITION_ID_XY(nodeIdx,1,sampleIndex),:,sampleIndex); %this should have no effect since the nodes in DISTANCE_MATRIX should have the same order of AVAILABLE_IDs
        end
        for sampleIndex = 1:size(IDX_POST_LOC,3)
            IDX_post_loc_reordered(nodeIdx,:,sampleIndex) =  IDX_POST_LOC(IDX_POST_LOC(:,1,sampleIndex) == NODE_POSITION_ID_XY(nodeIdx,1,sampleIndex),:,sampleIndex);
        end
    end
    fprintf('Done!\n\n');
    IDX_PRE_LOC = IDX_pre_loc_reordered;
    IDX_POST_LOC = IDX_post_loc_reordered;
end
