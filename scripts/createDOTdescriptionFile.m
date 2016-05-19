function createDOTdescriptionFile( SIGNAL, links, k_factor ,filename, nodeStartPositionXY)

if size(k_factor,2) ~= size(links,2) %is k_factor is wrong size, fix all spring constant to 1
    k_factor = ones(1,size(links,2));
end

fileID = fopen(filename,'w');
%HEADER
fprintf(fileID,'graph G {\n');

%START POSITION
for index = 1:length(nodeStartPositionXY)
    if sum(nodeStartPositionXY(index,1) == links(:)) ~= 0 % the node with ID nodeStartPositionXY(index,1) is present then set its initial condition
        
        pos1 = find(links(1,:)==nodeStartPositionXY(index,1)); %find links where the first node is nodeStartPositionXY(index,1)
        pos2 = find(links(2,:)==nodeStartPositionXY(index,1)); %find links where the second node is nodeStartPositionXY(index,1)
        
        if ( sum([ (SIGNAL(pos1)~=Inf & ~isnan(SIGNAL(pos1))) , (SIGNAL(pos2)~=Inf & ~isnan(SIGNAL(pos2))) ]) ) ~= 0 %if any of the link with node nodeStartPositionXY(index,1) is different from NaN or Inf the result will be higher than 1
            fprintf(fileID,'%d [pos="%.4f,%.4f"];\n',nodeStartPositionXY(index,1),nodeStartPositionXY(index,2),nodeStartPositionXY(index,3));
        end
    end
end
%LINKS LIST
for index = 1:1:size(links,2)
    if ~isnan(SIGNAL(index)) && SIGNAL(index) ~= Inf
        if SIGNAL(index) < 0
            SIGNAL(index) = 0.1;
        end
        fprintf(fileID,'%d -- %d[len="%.2f", weight="%.4f"];\n',links(1,index),links(2,index),SIGNAL(index),1/k_factor(index));
    end
end

fprintf(fileID,'}');

fclose(fileID);

end
