epsilon=12;
MinPts=1;
IDX_pre_localization = -Inf*ones(size(AVAILABLE_IDs,1),2,size(DISTANCE_MATRIX,3)); %the first column will containt the node ID, the second will contain the cluster number
IDX_post_localization = -Inf*ones(size(AVAILABLE_IDs,1),2,size(DISTANCE_MATRIX,3)); %the first column will containt the node ID, the second will contain the cluster number

fprintf('CLUSTERING NODES:\n');
for sampleIndex = 1:size(DISTANCE_MATRIX,3)
    IDX_pre_localization(:,2,sampleIndex)=DBSCAN(DISTANCE_MATRIX(2:end,2:end,sampleIndex),epsilon,MinPts);
    IDX_pre_localization(:,1,sampleIndex)=DISTANCE_MATRIX(2:end,1,sampleIndex);
end
for sampleIndex = 1:size(DISTANCE_MATRIX_post_loc,3)
    IDX_post_localization(:,2,sampleIndex)=DBSCAN(DISTANCE_MATRIX_post_loc(2:end,2:end,sampleIndex),epsilon,MinPts);
    IDX_post_localization(:,1,sampleIndex)=DISTANCE_MATRIX_post_loc(2:end,1,sampleIndex);
end

IDX_pre_loc_reordered = zeros(size(IDX_pre_localization));
IDX_post_loc_reordered = zeros(size(IDX_post_localization));
for nodeIdx=1:size(AVAILABLE_IDs,1) %reorder following the same order of nodePositionXY(nodeIdx,1,:)
    for sampleIndex = 1:size(IDX_pre_localization,3)
        IDX_pre_loc_reordered(nodeIdx,:,sampleIndex) =  IDX_pre_localization(IDX_pre_localization(:,1,sampleIndex) == nodePositionXY(nodeIdx,1,sampleIndex),:,sampleIndex); %this should have no effect since the nodes in DISTANCE_MATRIX should have the same order of AVAILABLE_IDs
    end
    for sampleIndex = 1:size(IDX_post_localization,3)
        IDX_post_loc_reordered(nodeIdx,:,sampleIndex) =  IDX_post_localization(IDX_post_localization(:,1,sampleIndex) == nodePositionXY(nodeIdx,1,sampleIndex),:,sampleIndex);
    end
end
fprintf('Done!\n\n');
IDX_pre_localization = IDX_pre_loc_reordered;
IDX_post_localization = IDX_post_loc_reordered;

