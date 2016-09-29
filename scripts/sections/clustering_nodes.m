epsilon=7;
MinPts=1;
IDX = zeros(size(AVAILABLE_IDs,1),size(t_w,1));
numberOfClusters = zeros(size(t_w,1),1);
fprintf('CLUSTERING NODES:\n');
for sampleIndex = 1:size(t_w,1)
    IDX(:,sampleIndex)=DBSCAN(DISTANCE_MATRIX(:,:,sampleIndex),epsilon,MinPts,size(AVAILABLE_IDs,1));
    
    numberOfClusters(sampleIndex) = size(unique(IDX(:,sampleIndex)),1);
end

IDX_reordered = zeros(size(IDX));
for nodeIdx=1:size(AVAILABLE_IDs,1)
    IDX_reordered(nodeIdx,:) =  IDX(nodePositionXY(nodeIdx,1,1)==AVAILABLE_IDs,:);
end

IDX = IDX_reordered;

