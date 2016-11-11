function createDOTdescriptionFile( SIGNAL, LINKS, k_factor ,filename, nodeStartPositionXY)

if size(k_factor,2) ~= size(LINKS,2) %is k_factor is wrong size, fix all spring constant to 1
    k_factor = ones(1,size(LINKS,2));
end

fileID = fopen(filename,'w');
%HEADER
fprintf(fileID,'graph G {\n');

%START POSITION
for index = 1:length(nodeStartPositionXY)
    if sum(nodeStartPositionXY(index,1) == LINKS(:)) ~= 0 % the node with ID nodeStartPositionXY(index,1) is present then set its initial condition
        
        pos1 = find(LINKS(1,:)==nodeStartPositionXY(index,1)); %find LINKS where the first node is nodeStartPositionXY(index,1)
        pos2 = find(LINKS(2,:)==nodeStartPositionXY(index,1)); %find LINKS where the second node is nodeStartPositionXY(index,1)
        
        if ( sum([ (SIGNAL(pos1)~=Inf & ~isnan(SIGNAL(pos1))) , (SIGNAL(pos2)~=Inf & ~isnan(SIGNAL(pos2))) ]) ) ~= 0 %if any of the link with node nodeStartPositionXY(index,1) is different from NaN or Inf the result will be higher than 1
            fprintf(fileID,'%d [pos="%.4f,%.4f"];\n',nodeStartPositionXY(index,1),nodeStartPositionXY(index,2),nodeStartPositionXY(index,3));
        end
    end
end
%LINKS LIST
for index = 1:1:size(LINKS,2)
    if ~isnan(SIGNAL(index)) && SIGNAL(index) ~= Inf
        if SIGNAL(index) < 0
            SIGNAL(index) = 0.1;
        end
        fprintf(fileID,'%d -- %d[len="%.2f", weight="%.3f"];\n',LINKS(1,index),LINKS(2,index),SIGNAL(index),1/k_factor(index));
    end
end

fprintf(fileID,'}');

fclose(fileID);

end
