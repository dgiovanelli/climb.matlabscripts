function NODE_POSITION_ID_XY = mdsLayout(edegesLength, LINKS, unreliablility ,startingPos)

%create a distance matrix starting from GRAPH_EDGES_M_FILT and LINKS
nodesList = unique( LINKS );
nodesAmount = size(nodesList,1);

distanceMatrix = zeros(nodesAmount);
weightsMatrix = zeros(nodesAmount);

for linkNo = 1 : size(LINKS,2)
    pos1 = find(nodesList == LINKS(1,linkNo));
    pos2 = find(nodesList == LINKS(2,linkNo));
    
    distanceMatrix(pos1, pos2) = edegesLength(linkNo);
    distanceMatrix(pos2, pos1) = edegesLength(linkNo);
    
    weightsMatrix(pos1, pos2) = 1/unreliablility(linkNo);
    weightsMatrix(pos2, pos1) = 1/unreliablility(linkNo);
end

if isempty(startingPos)
%     startingPos = rand(nodesAmount,2)*2-1;
%     r = 100*max(edegesLength);
%     deltaPhi_rad = (2*pi)/nodesAmount;
%     for nodeNo = 1:nodesAmount
%         startingPos(nodeNo,:) = [r*sin(deltaPhi_rad*nodeNo), r*cos(deltaPhi_rad*nodeNo)];
%     end
%     NODE_POSITION_ID_XY , ~]= mdscale(distanceMatrix,2,'Start', startingPos,'Weights', weightsMatrix);
    [NODE_POSITION_ID_XY , ~]= mdscale(distanceMatrix,2,'Weights', weightsMatrix);
else
    [NODE_POSITION_ID_XY , ~]= mdscale(distanceMatrix,2,'Start', startingPos,'Weights', weightsMatrix);
end


NODE_POSITION_ID_XY = [nodesList , NODE_POSITION_ID_XY(:,1:2)];

end