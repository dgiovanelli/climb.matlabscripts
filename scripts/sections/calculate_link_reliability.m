%LINK RELIABILITY
fprintf('LINKS RELIABILITY CHECK:\n');
LINKS_UNRELIABLITY = zeros(size(graphEdeges_m_filt));
for i_link_id1_id2=1:size(links,2) %scan all links and evaluate all possible 'triangles'. NB: selecting a line of 'links' means selecting the firsts two nodes and the first link (i.e. it doesn't need a second cycle to select the second node)
    i_link_1 = i_link_id1_id2;
    id_1 = links(1,i_link_id1_id2);
    id_2 = links(2,i_link_id1_id2);
    i_links_2_list = find(links(1,:)==id_2);
    
    for i_link_id3=i_links_2_list
        i_link_2 = i_link_id3;
        id_3 = links(2,i_link_id3);
        i_links_3_list = find(( links(2,:) == id_3 & links(1,:) == id_1 ));
        if( size(i_links_3_list,2) == 1)
            i_link_3 = i_links_3_list(1);
            if PLOT_VERBOSITY > 2
                fprintf('Triangle: %d - %d - %d\n',id_1,id_2,id_3);
            end
            
            for timeIndexNo = 1:size(graphEdeges_m_filt,1)
                if (graphEdeges_m_filt(timeIndexNo,i_link_1)~=Inf) && (graphEdeges_m_filt(timeIndexNo,i_link_2)~=Inf) && (graphEdeges_m_filt(timeIndexNo,i_link_3)~=Inf)
                    if graphEdeges_m_filt(timeIndexNo,i_link_1) + graphEdeges_m_filt(timeIndexNo,i_link_2) <  0.8*graphEdeges_m_filt(timeIndexNo,i_link_3)
                        LINKS_UNRELIABLITY(timeIndexNo,i_link_1) = LINKS_UNRELIABLITY(timeIndexNo,i_link_1) + 1;
                        LINKS_UNRELIABLITY(timeIndexNo,i_link_2) = LINKS_UNRELIABLITY(timeIndexNo,i_link_2) + 1;
                        LINKS_UNRELIABLITY(timeIndexNo,i_link_3) = LINKS_UNRELIABLITY(timeIndexNo,i_link_3) + 1;
                    end
                    if graphEdeges_m_filt(timeIndexNo,i_link_2) + graphEdeges_m_filt(timeIndexNo,i_link_3) <  0.8*graphEdeges_m_filt(timeIndexNo,i_link_1)
                        LINKS_UNRELIABLITY(timeIndexNo,i_link_1) = LINKS_UNRELIABLITY(timeIndexNo,i_link_1) + 1;
                        LINKS_UNRELIABLITY(timeIndexNo,i_link_2) = LINKS_UNRELIABLITY(timeIndexNo,i_link_2) + 1;
                        LINKS_UNRELIABLITY(timeIndexNo,i_link_3) = LINKS_UNRELIABLITY(timeIndexNo,i_link_3) + 1;
                    end
                    if graphEdeges_m_filt(timeIndexNo,i_link_3) + graphEdeges_m_filt(timeIndexNo,i_link_1) <  0.8*graphEdeges_m_filt(timeIndexNo,i_link_2)
                        LINKS_UNRELIABLITY(timeIndexNo,i_link_1) = LINKS_UNRELIABLITY(timeIndexNo,i_link_1) + 1;
                        LINKS_UNRELIABLITY(timeIndexNo,i_link_2) = LINKS_UNRELIABLITY(timeIndexNo,i_link_2) + 1;
                        LINKS_UNRELIABLITY(timeIndexNo,i_link_3) = LINKS_UNRELIABLITY(timeIndexNo,i_link_3) + 1;
                    end
                end
            end
        else
            if( size(i_links_3_list,2) ~= 0)
                error('The triangle is not single since between %0x and %0x there are more than one link....check the script!',id_3,id_1);
                links'
            end
        end
    end
    %end
end
fprintf('Done!\n\n');