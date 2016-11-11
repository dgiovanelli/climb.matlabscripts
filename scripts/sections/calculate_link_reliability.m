%LINK RELIABILITY
fprintf('LINKS RELIABILITY CHECK:\n');
LINKS_UNRELIABLITY = zeros(size(GRAPH_EDGES_M_FILT));
for i_link_id1_id2=1:size(LINKS,2) %scan all LINKS and evaluate all possible 'triangles'. NB: selecting a line of 'LINKS' means selecting the firsts two nodes and the first link (i.e. it doesn't need a second cycle to select the second node)
    i_link_1 = i_link_id1_id2;
    id_1 = LINKS(1,i_link_id1_id2);
    id_2 = LINKS(2,i_link_id1_id2);
    i_links_2_list = find(LINKS(1,:)==id_2);
    
    for i_link_id3=i_links_2_list
        i_link_2 = i_link_id3;
        id_3 = LINKS(2,i_link_id3);
        i_links_3_list = find(( LINKS(2,:) == id_3 & LINKS(1,:) == id_1 ));
        if( size(i_links_3_list,2) == 1)
            i_link_3 = i_links_3_list(1);
            if PLOT_VERBOSITY > 2
                fprintf('Analyzing triangle: %02x - %02x - %02x\n',id_1,id_2,id_3);
            end
            
            for timeIndexNo = 1:size(GRAPH_EDGES_M_FILT,1)
                if (GRAPH_EDGES_M_FILT(timeIndexNo,i_link_1)~=Inf) && (GRAPH_EDGES_M_FILT(timeIndexNo,i_link_2)~=Inf) && (GRAPH_EDGES_M_FILT(timeIndexNo,i_link_3)~=Inf)
                    if GRAPH_EDGES_M_FILT(timeIndexNo,i_link_1) + GRAPH_EDGES_M_FILT(timeIndexNo,i_link_2) <  0.8*GRAPH_EDGES_M_FILT(timeIndexNo,i_link_3)
                        LINKS_UNRELIABLITY(timeIndexNo,i_link_1) = LINKS_UNRELIABLITY(timeIndexNo,i_link_1) + 1;
                        LINKS_UNRELIABLITY(timeIndexNo,i_link_2) = LINKS_UNRELIABLITY(timeIndexNo,i_link_2) + 1;
                        LINKS_UNRELIABLITY(timeIndexNo,i_link_3) = LINKS_UNRELIABLITY(timeIndexNo,i_link_3) + 1;
                    end
                    if GRAPH_EDGES_M_FILT(timeIndexNo,i_link_2) + GRAPH_EDGES_M_FILT(timeIndexNo,i_link_3) <  0.8*GRAPH_EDGES_M_FILT(timeIndexNo,i_link_1)
                        LINKS_UNRELIABLITY(timeIndexNo,i_link_1) = LINKS_UNRELIABLITY(timeIndexNo,i_link_1) + 1;
                        LINKS_UNRELIABLITY(timeIndexNo,i_link_2) = LINKS_UNRELIABLITY(timeIndexNo,i_link_2) + 1;
                        LINKS_UNRELIABLITY(timeIndexNo,i_link_3) = LINKS_UNRELIABLITY(timeIndexNo,i_link_3) + 1;
                    end
                    if GRAPH_EDGES_M_FILT(timeIndexNo,i_link_3) + GRAPH_EDGES_M_FILT(timeIndexNo,i_link_1) <  0.8*GRAPH_EDGES_M_FILT(timeIndexNo,i_link_2)
                        LINKS_UNRELIABLITY(timeIndexNo,i_link_1) = LINKS_UNRELIABLITY(timeIndexNo,i_link_1) + 1;
                        LINKS_UNRELIABLITY(timeIndexNo,i_link_2) = LINKS_UNRELIABLITY(timeIndexNo,i_link_2) + 1;
                        LINKS_UNRELIABLITY(timeIndexNo,i_link_3) = LINKS_UNRELIABLITY(timeIndexNo,i_link_3) + 1;
                    end
                end
            end
        else
            if( size(i_links_3_list,2) ~= 0)
                error('The triangle is not single since between %02x and %02x there are more than one link....check the script!',id_3,id_1);
                LINKS'
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
    for linkNo=1:size(LINKS,2)
        figure(634)
        hold on;
        unrel_step_width = (max(max(LINKS_UNRELIABLITY)) - min(min(LINKS_UNRELIABLITY)))/NO_OF_UNREL_LEVELS;
        for unrel_level=1:NO_OF_UNREL_LEVELS
            selected_Samples = LINKS_UNRELIABLITY(:,linkNo)>=(unrel_level-1)*unrel_step_width;% & LINKS_UNRELIABLITY(:,linkNo)<=(unrel_level)*unrel_step_width; %to avoid interruption in the link traces plot only the LINKS with LINKS_UNRELIABLITY > unrel_level
            graphEdege_m_temp = GRAPH_EDGES_M_FILT(:,linkNo);
            graphEdege_m_temp(~selected_Samples) = NaN; 
            h{unrel_level} = plot(unixToMatlabTime(T_TICKS), graphEdege_m_temp,'Color',colorlist(NO_OF_UNREL_LEVELS-unrel_level+1,:));
            if linkNo == 1
                fprintf('Step %d: from %.2f to %.2f\n', unrel_level, (unrel_level-1)*unrel_step_width, (unrel_level)*unrel_step_width);
                legendStrs{unrel_level} = sprintf('Unreliability from %.2f to %.2f\n',(unrel_level-1)*unrel_step_width, (unrel_level)*unrel_step_width);
            end
            %[strPos_y_val, strPos_x_idx] = max(GRAPH_EDGES_M_FILT(selected_Samples,linkNo));
            valid_positions = find(selected_Samples);
            if ~isempty(valid_positions)
                label_positions = [valid_positions(1); valid_positions(find((diff(valid_positions))>1)+1)];
                for labelNo = 1:size(label_positions,1)
                    strPos_x_idx = label_positions(labelNo);
                    linkStr = sprintf('%02x<->%02x', LINKS(1,linkNo),LINKS(2,linkNo));
                    text(unixToMatlabTime(T_TICKS(strPos_x_idx)),GRAPH_EDGES_M_FILT(strPos_x_idx,linkNo),linkStr,'FontSize',9);%,'FontWeight','bold');
                end
            end
        end
    end
    clickableLegend( legendStrs );
    datetick('x',DATE_FORMAT);
    title('Unreliablity level');
    hold off;
end
fprintf('Done!\n\n');