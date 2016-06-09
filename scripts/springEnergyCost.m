function El = springEnergyCost( XY, distanceMatrix, k_springs )

El = 0;
nodesAmount = size(distanceMatrix,1);
for nodeNo_1 = 1:(nodesAmount-1)
    for nodeNo_2 = nodeNo_1+1:nodesAmount    
        l_12 = distanceMatrix(nodeNo_1, nodeNo_2);
        El = El + k_springs(nodeNo_1,nodeNo_2) * ((sqrt( (XY(nodeNo_1,1) - XY(nodeNo_2,1)).^2 + (XY(nodeNo_1,2) - XY(nodeNo_2,2)).^2 ) - l_12 ).^2);
    end
end


end