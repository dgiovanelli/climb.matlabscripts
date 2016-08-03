%LINK RELIABILITY
fprintf('LINKS RELIABILITY CHECK:\n');
LINKS_UNRELIABLITY = zeros(size(graphEdeges_m));
for i_link_1=1:size(graphEdeges_m,2) %scan all links and evaluate all possible 'triangles'.
    
    id_1 = links(1,i_link_1);
    id_2_temp = links(2,links(1,:)==id_1);
    id_2 = id_2_temp(1);
    i_links_2_temp = find(links(1,:)==id_2);
    for i_link_2=i_links_2_temp
        id_3 = links(2,i_link_2);
        i_link_3 = find(links(2,:)==id_3 & links(1,:)==id_1);
        
        if(size(i_link_3) == 1 )
            
            for timeIndexNo = 1:size(graphEdeges_m,1)
                if (graphEdeges_m(timeIndexNo,i_link_1)~=Inf) && (graphEdeges_m(timeIndexNo,i_link_2)~=Inf) && (graphEdeges_m(timeIndexNo,i_link_3)~=Inf)
                    if graphEdeges_m(timeIndexNo,i_link_1) + graphEdeges_m(timeIndexNo,i_link_2) <  0.8*graphEdeges_m(timeIndexNo,i_link_3)
                        %links(i_link_3) -> unreliable
                        LINKS_UNRELIABLITY(timeIndexNo,i_link_3) = LINKS_UNRELIABLITY(timeIndexNo,i_link_3) + 1;
                    end
                    if graphEdeges_m(timeIndexNo,i_link_2) + graphEdeges_m(timeIndexNo,i_link_3) <  0.8*graphEdeges_m(timeIndexNo,i_link_1)
                        %links(i_link_1) -> unreliable
                        LINKS_UNRELIABLITY(timeIndexNo,i_link_1) = LINKS_UNRELIABLITY(timeIndexNo,i_link_1) + 1;
                    end
                    if graphEdeges_m(timeIndexNo,i_link_3) + graphEdeges_m(timeIndexNo,i_link_1) <  0.8*graphEdeges_m(timeIndexNo,i_link_2)
                        %links(i_link_2) -> unreliable
                        LINKS_UNRELIABLITY(timeIndexNo,i_link_2) = LINKS_UNRELIABLITY(timeIndexNo,i_link_2) + 1;
                    end
                end
            end
        else
            if ~isempty(i_link_3)
                error('i_link_3 has more than one element, check!!!');
            end
        end
    end
end
fprintf('Done!\n\n');