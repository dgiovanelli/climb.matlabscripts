function createDOTdescriptionFile( SIGNAL, links, filename)
    
fileID = fopen(filename,'w');
clk = clock;
%HEADER
fprintf(fileID,'graph G {\n');

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