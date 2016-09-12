%function El= springEnergyCost( XY ,distanceMatrix, k_springs )
function[El,g]= springEnergyCost( XY ,distanceMatrix, k_springs )
%Providing gradient function decrease performance in some cases .... [El,g]= springEnergyCost( XY ,distanceMatrix, k_springs )
El = 0;

nodesAmount = size(distanceMatrix,1);
g = zeros(size(XY,1),2);
for nodeNo_1 = 1:(nodesAmount-1)
    dEdx = 0;
    dEdy = 0;
    for nodeNo_2 = nodeNo_1+1:nodesAmount    
        l_12 = distanceMatrix(nodeNo_1, nodeNo_2);
        
        if l_12 ~= Inf && ~isnan(l_12)
            
            El = El + k_springs(nodeNo_1,nodeNo_2) * ((sqrt( (XY(nodeNo_1,1) - XY(nodeNo_2,1)).^2 + (XY(nodeNo_1,2) - XY(nodeNo_2,2)).^2 ) - l_12 ).^2);
            
            dmi_x = XY(nodeNo_1,1) - XY(nodeNo_2,1);
            dmi_y = XY(nodeNo_1,2) - XY(nodeNo_2,2);
            
            dEdx = dEdx + k_springs(nodeNo_1, nodeNo_2)*(dmi_x - l_12*dmi_x / sqrt(dmi_x^2+dmi_y^2));
            dEdy = dEdy + k_springs(nodeNo_1, nodeNo_2)*(dmi_y - l_12*dmi_y / sqrt(dmi_x^2+dmi_y^2));
            
        end
        
    end
    g(nodeNo_1,:) = [dEdx, dEdy];
end

end