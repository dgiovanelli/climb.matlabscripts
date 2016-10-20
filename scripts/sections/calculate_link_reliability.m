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
                fprintf('Analyzing triangle: %02x - %02x - %02x\n',id_1,id_2,id_3);
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
                error('The triangle is not single since between %02x and %02x there are more than one link....check the script!',id_3,id_1);
                links'
            end
        end
    end
    %end
end

if PLOT_VERBOSITY > 2
    NO_OF_UNREL_LEVELS = 5;
    colorlist = hsv( NO_OF_UNREL_LEVELS * 2);
    legendStrs = cell(NO_OF_UNREL_LEVELS,1);
    h = cell(NO_OF_UNREL_LEVELS,1);
    for linkNo=1:size(links,2)
        figure(634)
        hold on;
        unrel_step_width = (max(max(LINKS_UNRELIABLITY)) - min(min(LINKS_UNRELIABLITY)))/NO_OF_UNREL_LEVELS;
        for unrel_level=1:NO_OF_UNREL_LEVELS
            selected_Samples = LINKS_UNRELIABLITY(:,linkNo)>=(unrel_level-1)*unrel_step_width & LINKS_UNRELIABLITY(:,linkNo)<=(unrel_level)*unrel_step_width;
            graphEdege_m_temp = graphEdeges_m_filt(:,linkNo);
            graphEdege_m_temp(~selected_Samples) = NaN; 
            h{unrel_level} = plot(t_w*TICK_DURATION, graphEdege_m_temp,'Color',colorlist(NO_OF_UNREL_LEVELS-unrel_level+1,:));
            if linkNo == 1
                fprintf('Step %d: from %.2f to %.2f\n', unrel_level, (unrel_level-1)*unrel_step_width, (unrel_level)*unrel_step_width);
                legendStrs{unrel_level} = sprintf('Unreliability from %.2f to %.2f\n',(unrel_level-1)*unrel_step_width, (unrel_level)*unrel_step_width);
            end
            %[strPos_y_val, strPos_x_idx] = max(graphEdeges_m_filt(selected_Samples,linkNo));
            valid_positions = find(selected_Samples);
            if(~isempty(valid_positions))
                strPos_x_idx = valid_positions(1);
                linkStr = sprintf('%02x<->%02x', links(1,linkNo),links(2,linkNo));
                text(t_w(strPos_x_idx)*TICK_DURATION,graphEdeges_m_filt(strPos_x_idx,linkNo),linkStr,'FontSize',9);%,'FontWeight','bold'); 
            end
        end
    end
    clickableLegend( legendStrs );
    title('Unreliablity level');
    hold off;
end
fprintf('Done!\n\n');