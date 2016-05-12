function createDOTdescriptionFile( SIGNAL, links, filename, nodeStartPositionXY)
    
fileID = fopen(filename,'w');
%HEADER
fprintf(fileID,'graph G {\n');

%START POSITION
for index = 1:length(nodeStartPositionXY)
    if sum(nodeStartPositionXY(index,1) == links(:)) ~= 0 % the node with ID nodeStartPositionXY(index,1) is present then set its initial condition
        fprintf(fileID,'%d [pos="%.4f,%.4f"];\n',nodeStartPositionXY(index,1),nodeStartPositionXY(index,2),nodeStartPositionXY(index,3));
    end
end
%LINKS LIST
for index = 1:1:size(links,2)
    if strcmp(sprintf('%.2f',SIGNAL(index)), 'NaN') == 0 && SIGNAL(index) ~= Inf
        if SIGNAL(index) < 0
            SIGNAL(index) = 0;
        end
        fprintf(fileID,'%d -- %d[len="%.2f", weight="1"];\n',links(1,index),links(2,index),SIGNAL(index));
    end
end

fprintf(fileID,'}');

fclose(fileID);

end