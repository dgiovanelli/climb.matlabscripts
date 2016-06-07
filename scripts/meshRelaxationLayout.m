function nodePositionXY = meshRelaxationLayout(edegesLength, links, unreliablility ,startingPos)

epsilon = 0.0000000000001;

%create a distance matrix starting from graphEdeges_m_filt and links
nodesList = unique( links );
nodesAmount = size(nodesList,1);

distanceMatrix = zeros(nodesAmount);
k_springs = ones(nodesAmount)*10;
dEdx = zeros(nodesAmount);
dEdy = zeros(nodesAmount);
Dm = zeros(nodesAmount,1);
if isempty(startingPos)
    nodePositionXY = rand(nodesAmount,2)*2-1;
else
    nodePositionXY = startingPos;
end
Dm_max_value = Inf;

for linkNo = 1 : size(links,1)
    pos1 = find(nodesList == links(linkNo,1));
    pos2 = find(nodesList == links(linkNo,2));
    
    distanceMatrix(pos1, pos2) = edegesLength(linkNo);
    distanceMatrix(pos2, pos1) = edegesLength(linkNo);
    
    %k_springs(pos1, pos2) = 1/edegesLength(linkNo).^2;
    %k_springs(pos2, pos1) = 1/edegesLength(linkNo).^2;
end

while Dm_max_value > epsilon
   
    for nodeNo_m = 1:nodesAmount
        for nodeNo_i = 1:nodesAmount
            
            if nodeNo_i ~= nodeNo_m
                dmi_x = nodePositionXY(nodeNo_m,1) - nodePositionXY(nodeNo_i,1);
                dmi_y = nodePositionXY(nodeNo_m,2) - nodePositionXY(nodeNo_i,2);
                
                dEdx(nodeNo_m,nodeNo_i) = k_springs(nodeNo_m, nodeNo_i)*(dmi_x - distanceMatrix(nodeNo_m, nodeNo_i)*dmi_x / sqrt(dmi_x^2+dmi_y^2));
                dEdy(nodeNo_m,nodeNo_i) = k_springs(nodeNo_m, nodeNo_i)*(dmi_y - distanceMatrix(nodeNo_m, nodeNo_i)*dmi_y / sqrt(dmi_x^2+dmi_y^2));
                
            end
        end
        
        Dm(nodeNo_m) = sqrt( sum(dEdx(nodeNo_m,:))^2 + sum(dEdy(nodeNo_m,:))^2);
    end
    
    
    [Dm_max_value, Dm_max_index] = max(Dm);
    A = zeros(2);
    B = zeros(2,1);
    
    for nodeNo_i = 1:nodesAmount
        if nodeNo_i ~= Dm_max_index
            
            dmi_x = nodePositionXY(Dm_max_index,1) - nodePositionXY(nodeNo_i,1);
            dmi_y = nodePositionXY(Dm_max_index,2) - nodePositionXY(nodeNo_i,2);
            dmi_x_square = dmi_x.^2;
            dmi_y_square = dmi_y.^2;
            l_mi = distanceMatrix(Dm_max_index, nodeNo_i);
            k_mi = k_springs(Dm_max_index, nodeNo_i);
            %dEdx(nodeNo_m,nodeNo_i) = k_springs(nodeNo_m, nodeNo_i)*(dmi_x - distanceMatrix(nodeNo_m, nodeNo_i)*dmi_x / sqrt(dmi_x^2+dmi_y^2));
            %dEdy(nodeNo_m,nodeNo_i) = k_springs(nodeNo_m, nodeNo_i)*(dmi_y - distanceMatrix(nodeNo_m, nodeNo_i)*dmi_y / sqrt(dmi_x^2+dmi_y^2));
            
            A(1,1) = A(1,1) + k_mi*( 1 - l_mi*(dmi_y_square) / (dmi_x_square + dmi_y_square).^(3/2) );
            A(1,2) = A(1,2) + l_mi*dmi_x*dmi_y / (dmi_x_square + dmi_y_square).^(3/2);
            A(2,1) = A(1,2);
            A(2,2) = A(2,2) + k_mi*( 1 - l_mi*(dmi_x_square) / (dmi_x_square + dmi_y_square).^(3/2) );
            
            B(1) = B(1) - dEdx(Dm_max_index, nodeNo_i);
            B(2) = B(2) - dEdy(Dm_max_index, nodeNo_i);
        end
    end
    
    X = linsolve(A,B);
    dx = X(1);
    dy = X(2);
    
    nodePositionXY(Dm_max_index,:) = nodePositionXY(Dm_max_index,:) + [dx,dy];

end


nodePositionXY = [nodesList , nodePositionXY(:,1:2)];

end