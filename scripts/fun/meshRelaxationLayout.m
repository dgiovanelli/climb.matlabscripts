function [nodePositionXY, spring_En, nodes_En] = meshRelaxationLayout(edegesLength, links, unreliablility ,startingPos, high_precision)
spring_En = NaN*ones(size(links,2),1);

if high_precision ~= 0
    epsilon_D_energy = 0.01; %this is used when the stop condition is on the slope of energy associated to one node
    epsilon_d_movement = 0.01;  %this is used when the stop condition is on the minimum movement of the node
    MAX_ITER = 10000;
else
    epsilon_D_energy = 1; %this is used when the stop condition is on the slope of energy associated to one node
    epsilon_d_movement = 0.1;  %this is used when the stop condition is on the minimum movement of the node
    MAX_ITER = 1000;
end
iteractions = 0;
k_spring_default = 20;

nodesList = unique( links );
nodesAmount = size(nodesList,1);
nodes_En = zeros(nodesAmount,2);

distanceMatrix = zeros(nodesAmount);
k_springs = k_spring_default*ones(nodesAmount);
dEdx = zeros(nodesAmount);
dEdy = zeros(nodesAmount);
Dm = zeros(nodesAmount,1);
if isempty(startingPos)
    nodePositionXY = rand(nodesAmount,2)*2-1;
    r = 100*max(edegesLength(edegesLength ~= Inf)); %avoid Infs
    deltaPhi_rad = (2*pi)/nodesAmount;
    for nodeNo = 1:nodesAmount
        nodePositionXY(nodeNo,:) = [r*sin(deltaPhi_rad*nodeNo), r*cos(deltaPhi_rad*nodeNo)];
    end
    MAX_ITER = MAX_ITER*2; %if the starting position is not given increase the MAX_ITER by a factor of two
else
    nodePositionXY = startingPos;
end

Dm_max_value = Inf;
d = Inf;
%GENERATE DISTANCE MATRIX
for linkNo = 1 : size(links,2)
    pos1 = find(nodesList == links(1,linkNo));
    pos2 = find(nodesList == links(2,linkNo));
    
    distanceMatrix(pos1, pos2) = edegesLength(linkNo);
    distanceMatrix(pos2, pos1) = edegesLength(linkNo);
    
    %k_springs(pos1, pos2) = k_springs(pos1, pos2)/(edegesLength(linkNo).^2);
    %k_springs(pos2, pos1) = k_springs(pos1, pos2)/(edegesLength(linkNo).^2);
    
    k_springs(pos1, pos2) = k_springs(pos1, pos2)/unreliablility(linkNo);%sqrt(unreliablility(linkNo));
    k_springs(pos2, pos1) = k_springs(pos2, pos1)/unreliablility(linkNo);%sqrt(unreliablility(linkNo));
    
end

%while Dm_max_value > epsilon && iteractions < MAX_ITER
while d > epsilon_d_movement && iteractions < MAX_ITER
    for nodeNo_m = 1:nodesAmount
        for nodeNo_i = 1:nodesAmount
            
            if nodeNo_i ~= nodeNo_m
                dmi_x = nodePositionXY(nodeNo_m,1) - nodePositionXY(nodeNo_i,1);
                dmi_y = nodePositionXY(nodeNo_m,2) - nodePositionXY(nodeNo_i,2);
                
                dEdx(nodeNo_m,nodeNo_i) = k_springs(nodeNo_m, nodeNo_i)*(dmi_x - distanceMatrix(nodeNo_m, nodeNo_i)*dmi_x / sqrt(dmi_x^2+dmi_y^2));
                dEdy(nodeNo_m,nodeNo_i) = k_springs(nodeNo_m, nodeNo_i)*(dmi_y - distanceMatrix(nodeNo_m, nodeNo_i)*dmi_y / sqrt(dmi_x^2+dmi_y^2));
                
            end
        end
        
        Dm(nodeNo_m) = sqrt( sum(dEdx(nodeNo_m,~isnan(dEdx(nodeNo_m,:))))^2 + sum(dEdy(nodeNo_m,~isnan(dEdy(nodeNo_m,:))))^2);
    end
    
    
    [Dm_max_value, Dm_max_index] = max(Dm);
    A = zeros(2);
    B = zeros(2,1);
    
    for nodeNo_i = 1:nodesAmount
        if nodeNo_i ~= Dm_max_index
            if distanceMatrix(Dm_max_index, nodeNo_i) ~= Inf && ~isnan(distanceMatrix(Dm_max_index, nodeNo_i))
                dmi_x = nodePositionXY(Dm_max_index,1) - nodePositionXY(nodeNo_i,1);
                dmi_y = nodePositionXY(Dm_max_index,2) - nodePositionXY(nodeNo_i,2);
                dmi_x_square = dmi_x.^2;
                dmi_y_square = dmi_y.^2;
                l_mi = distanceMatrix(Dm_max_index, nodeNo_i);
                k_mi = k_springs(Dm_max_index, nodeNo_i);
                %dEdx(nodeNo_m,nodeNo_i) = k_springs(nodeNo_m, nodeNo_i)*(dmi_x - distanceMatrix(nodeNo_m, nodeNo_i)*dmi_x / sqrt(dmi_x^2+dmi_y^2));
                %dEdy(nodeNo_m,nodeNo_i) = k_springs(nodeNo_m, nodeNo_i)*(dmi_y - distanceMatrix(nodeNo_m, nodeNo_i)*dmi_y / sqrt(dmi_x^2+dmi_y^2));
                
                A(1,1) = A(1,1) + k_mi*( 1 - l_mi*(dmi_y_square) / ( (dmi_x_square + dmi_y_square).^(3/2) ) );
                A(1,2) = A(1,2) + l_mi*dmi_x*dmi_y / (dmi_x_square + dmi_y_square).^(3/2);
                A(2,1) = A(1,2);
                A(2,2) = A(2,2) + k_mi*( 1 - l_mi*(dmi_x_square) / (dmi_x_square + dmi_y_square).^(3/2) );
                
                B(1) = B(1) - dEdx(Dm_max_index, nodeNo_i);
                B(2) = B(2) - dEdy(Dm_max_index, nodeNo_i);
            end
        end
    end
    
    if any(any(A))
        X = linsolve(A,B);
        dx = X(1);
        dy = X(2);
        d = sqrt(dx^2 + dy^2);
    
        nodePositionXY(Dm_max_index,:) = nodePositionXY(Dm_max_index,:) + [dx,dy];
    end
    iteractions = iteractions + 1; 
end
%iteractions
if iteractions >= MAX_ITER
    warning('Loop stopped, MAX_ITER reached!');
end

if high_precision ~= 0
    springEnergyCost_an = @(x)springEnergyCost( x, distanceMatrix, k_springs );
    
    %USE THE FOLLOWING TWO LINES IF THE GRADIENT IS NOT PROVIDED INSIDE springEnergyCost
    %options = optimset('Display','notify');
    %[nodePositionXY,~] = fminunc(springEnergyCost_an,nodePositionXY,options);
    %INSTEAD USE THE FOLLOWING TWO LINES IF THE GRADIENT IS PROVIDED INSIDE springEnergyCost
    options = optimoptions('fminunc','Algorithm','trust-region','SpecifyObjectiveGradient',true,'Display','notify');
    [nodePositionXY,fval] = fminunc(springEnergyCost_an,nodePositionXY,options); %Providing gradient function decrease performance in some cases ....
end
nodePositionXY = [nodesList , nodePositionXY(:,1:2)];

%calculate springs energy
for linkNo=1:size(links,2)
    pos1 = find(nodesList == links(1,linkNo));
    pos2 = find(nodesList == links(2,linkNo));
    
    node_dist_after_loc = sqrt(sum((nodePositionXY(pos1,2:3)-nodePositionXY(pos2,2:3)).^2));
    if node_dist_after_loc ~= Inf && ~isnan(node_dist_after_loc)
        delta_l_spring = (distanceMatrix(pos1,pos2) - node_dist_after_loc).^2;
        
        spring_En(linkNo) = 1/2* k_springs(pos1,pos2) *delta_l_spring;
    end
end

%calculate the energy associated with each node
for nodeNo_1=1:nodesAmount
    
    nodes_En(nodeNo_1,1) = nodesList(nodeNo_1);
    
    for nodeNo_2=1:nodesAmount
        if nodeNo_2 ~= nodeNo_1
            linkNo = find((links(1,:) == nodesList(nodeNo_1) & links(2,:) == nodesList(nodeNo_2)) | (links(1,:) == nodesList(nodeNo_2) & links(2,:) == nodesList(nodeNo_1)));
            if sum(size(linkNo))==2
                if ~isnan(spring_En(linkNo)) && spring_En(linkNo) ~= Inf
                    nodes_En(nodeNo_1,2) = nodes_En(nodeNo_1,2) + spring_En(linkNo);
                end
            else
                warning('Link between %02f and %02f not found of doubled', nodesList(nodeNo_1), nodesList(nodeNo_2));
            end
        end
    end
end
end

