function createXMLdescriptionFile( SIGNAL, LINKS, ID_LIST , filename)
    
fileID = fopen(filename,'w');
clk = clock;
%HEADER
fprintf(fileID,'<?xml version="1.0" encoding="UTF-8"?>\n');
fprintf(fileID,'<gexf xmlns:viz="http:///www.gexf.net/1.1draft/viz" version="1.1" xmlns="http://www.gexf.net/1.1draft">\n');
fprintf(fileID,'<meta lastmodifieddate="%d-%02d-%02d+%02d:%02d">\n',clk(1),clk(2),clk(3),clk(4),clk(5));
fprintf(fileID,'<creator>Davide</creator>\n');
fprintf(fileID,'</meta>\n');
fprintf(fileID,'<graph defaultedgetype="undirected" idtype="string" type="static">\n');
fprintf(fileID,'<nodes count="%d">\n',length(ID_LIST));

%NODE LIST
for index = 1:1:length(ID_LIST)
    fprintf(fileID,'<node id="%d.0" label="%02x"/>\n',ID_LIST(index),ID_LIST(index));
end
fprintf(fileID,'</nodes>\n');

%EDGES LIST
fprintf(fileID,'<edges count="%d">\n',size(SIGNAL,2));
for index = 1:1:size(LINKS,2)
    if strcmp(sprintf('%.2f',SIGNAL(index)), 'NaN') == 0
        fprintf(fileID,'<edge id="%d.0" source="%d.0" target="%d.0" weight="%.5f"/>\n',index,LINKS(1,index),LINKS(2,index),SIGNAL(index));
    end
end
fprintf(fileID,'</edges>\n');
fprintf(fileID,'</graph>\n');
fprintf(fileID,'</gexf>\n');

fclose(fileID);

end