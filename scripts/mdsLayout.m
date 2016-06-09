function nodePositionXY = mdsLayout(edegesLength, links, unreliablility ,startingPos)

%create a distance matrix starting from graphEdeges_m_filt and links
nodesList = unique( links );
nodesAmount = size(nodesList,1);

distanceMatrix = zeros(nodesAmount);
weightsMatrix = zeros(nodesAmount);

for linkNo = 1 : size(links,2)
    pos1 = find(nodesList == links(1,linkNo));
    pos2 = find(nodesList == links(2,linkNo));
    
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
%     nodePositionXY , ~]= mdscale(distanceMatrix,2,'Start', startingPos,'Weights', weightsMatrix);
    [nodePositionXY , ~]= mdscale(distanceMatrix,2,'Weights', weightsMatrix);
else
    [nodePositionXY , ~]= mdscale(distanceMatrix,2,'Start', startingPos,'Weights', weightsMatrix);
end


nodePositionXY = [nodesList , nodePositionXY(:,1:2)];

end