function nodePositionXY = mdsLayout(edegesLength, links, unreliablility ,startingPos)

%create a distance matrix starting from graphEdeges_m_filt and links
nodeOrder = unique( links );
matrixSize = size(nodeOrder,1);

distanceMatrix = zeros(matrixSize);
weightsMatrix = zeros(matrixSize);

for linkNo = 1 : size(links(1,:),2)
    pos1 = find(nodeOrder == links(1,linkNo));
    pos2 = find(nodeOrder == links(2,linkNo));
    
    distanceMatrix(pos1, pos2) = edegesLength(linkNo);
    distanceMatrix(pos2, pos1) = edegesLength(linkNo);
    
    weightsMatrix(pos1, pos2) = 1/unreliablility(linkNo);
    weightsMatrix(pos2, pos1) = 1/unreliablility(linkNo);
end

if ~isempty(startingPos)
    [nodePositionXY , ~]= mdscale(distanceMatrix,2,'Weights', weightsMatrix);
else
    [nodePositionXY , ~]= mdscale(distanceMatrix,2,'Start', startingPos,'Weights', weightsMatrix);
end

nodePositionXY = [nodeOrder , nodePositionXY(:,1:2)];

end