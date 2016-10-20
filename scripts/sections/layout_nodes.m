%% CALCULATING NODES LAYOUT
% NOTE: for now, changing the spring constant has no evident effect on
% layout. Moreover neato fail to layouts a matematical straigt line such as:
% graph G{
% 1 -- 2[len="1",weight="1";
% 2 -- 3[len="1",weight="1";
% 1 -- 3[len="2",weight="1";
% }
fprintf('CALCULATING LAYOUT:\n');
nodePositionXY = zeros(size(unique(links),1),3,size(graphEdeges_m_filt,1));
spring_En = NaN*ones(size(graphEdeges_m_filt));
nodes_En = NaN*ones(size(unique(links),1),2,size(graphEdeges_m_filt,1));
timeIndexNo_for_nodePositionXY = 1;
nextPercentPlotIndex = 0;
str = [];
if TREAT_AS_STATIC == 0
    amountOfTimeSamples = size(graphEdeges_m_filt,1);
else
    amountOfTimeSamples = 1;
end
for timeIndexNo = 1 : amountOfTimeSamples
    CENTERING_OFFSET_XY = [0,0];
    switch LAYOUT_ALGORITHM
        case 0 % use neato to place nodes
            if timeIndexNo == 1
                createDOTdescriptionFile( graphEdeges_m_filt(timeIndexNo,:), links, 1+LINKS_UNRELIABLITY(timeIndexNo,:) , '../output/output_m_temp.dot',[]); %1+LINKS_UNRELIABLITY(timeIndexNo,:) is because LINKS_UNRELIABLITY is zero if the link is reliable, inside createDOTdescriptionFile the spring constant is calculated with 1/LINKS_UNRELIABLITY(...). If LINKS_UNRELIABLITY(...) == 0 the constant will be Inf...
            else
                createDOTdescriptionFile( graphEdeges_m_filt(timeIndexNo,:), links, 1+LINKS_UNRELIABLITY(timeIndexNo,:) , '../output/output_m_temp.dot',nodePositionXY(:,:,timeIndexNo_for_nodePositionXY-1));
            end
            [status,cmdout] = dos('neato -Tplain ../output/output_m_temp.dot');
            if status == 0
                textLines = textscan(cmdout, '%s','delimiter', '\n');
                
                for textLineNo = 2:length(textLines{1})
                    tLine = sscanf( char(textLines{1}(textLineNo)),'%s %d %f %f');
                    if( tLine(1) == 'n' && tLine(2) == 'o' && tLine(3) == 'd' && tLine(4) == 'e')
                        k = findNodeIndex(RSSI_MATRIX(:,:,1), tLine(5) );
                        nodePositionXY(k-1,:,timeIndexNo_for_nodePositionXY) = tLine(5:7)';
                        if tLine(5) == CENTER_ON_ID
                            k_center_id = k;
                            if CENTER_ON_ID ~= 0
                                CENTERING_OFFSET_XY = nodePositionXY(k_center_id-1,2:3,timeIndexNo_for_nodePositionXY);
                            end
                        end
                    end
                end
                
                if CENTER_ON_ID ~= 0 && sum(CENTERING_OFFSET_XY) ~= 0
                    for i_id = 1:size(nodePositionXY,1)
                        if nodePositionXY(i_id,1,timeIndexNo_for_nodePositionXY) ~= 0
                            nodePositionXY(i_id,2:3,timeIndexNo_for_nodePositionXY) = nodePositionXY(i_id,2:3,timeIndexNo_for_nodePositionXY) - CENTERING_OFFSET_XY;
                        end
                    end
                end
                
            end
        case 1 % Use multidimensional scaling for placing nodes
            if timeIndexNo == 1
                nodePositionXY(:,:,timeIndexNo_for_nodePositionXY) = mdsLayout(graphEdeges_m_filt(timeIndexNo,:), links, 1+LINKS_UNRELIABLITY(timeIndexNo,:),[]); %1+LINKS_UNRELIABLITY(timeIndexNo,:) is because LINKS_UNRELIABLITY is zero if the link is reliable, inside createDOTdescriptionFile the spring constant is calculated with 1/LINKS_UNRELIABLITY(...). If LINKS_UNRELIABLITY(...) == 0 the constant will be Inf...
                k_center_id = find(nodePositionXY(:,1,1) == CENTER_ON_ID);
            else
                nodePositionXY(:,:,timeIndexNo_for_nodePositionXY) = mdsLayout(graphEdeges_m_filt(timeIndexNo,:), links, 1+LINKS_UNRELIABLITY(timeIndexNo,:),nodePositionXY(:,2:3,timeIndexNo_for_nodePositionXY-1));
            end
            
            if size(k_center_id,1) == 1
                if CENTER_ON_ID ~= 0
                    CENTERING_OFFSET_XY = nodePositionXY(k_center_id,2:3,timeIndexNo_for_nodePositionXY);
                    nodePositionXY(:,2:3,timeIndexNo_for_nodePositionXY) = nodePositionXY(:,2:3,timeIndexNo_for_nodePositionXY) - [ones(size(nodePositionXY(:,2:3,timeIndexNo_for_nodePositionXY),1),1) * CENTERING_OFFSET_XY(1), ones(size(nodePositionXY(:,2:3,timeIndexNo_for_nodePositionXY),1),1) * CENTERING_OFFSET_XY(2)];
                end
            end
            
        case 2 % Use mesh relaxation for placing nodes
            if timeIndexNo == 1
                [nodePositionXY(:,:,timeIndexNo_for_nodePositionXY), spring_En(timeIndexNo_for_nodePositionXY,:), nodes_En(:,:,timeIndexNo_for_nodePositionXY)] = meshRelaxationLayout(graphEdeges_m_filt(timeIndexNo,:), links, 1+LINKS_UNRELIABLITY(timeIndexNo,:),[],ENABLE_HIGH_PRECISION_ON_MESH_RELAXATION); %1+LINKS_UNRELIABLITY(timeIndexNo,:) is because LINKS_UNRELIABLITY is zero if the link is reliable, inside createDOTdescriptionFile the spring constant is calculated with 1/LINKS_UNRELIABLITY(...). If LINKS_UNRELIABLITY(...) == 0 the constant will be Inf...
                k_center_id = find(nodePositionXY(:,1,1) == CENTER_ON_ID);
            else
                [nodePositionXY(:,:,timeIndexNo_for_nodePositionXY), spring_En(timeIndexNo_for_nodePositionXY,:), nodes_En(:,:,timeIndexNo_for_nodePositionXY)] = meshRelaxationLayout(graphEdeges_m_filt(timeIndexNo,:), links, 1+LINKS_UNRELIABLITY(timeIndexNo,:),nodePositionXY(:,2:3,timeIndexNo_for_nodePositionXY-1),ENABLE_HIGH_PRECISION_ON_MESH_RELAXATION);
            end
            
            if CENTER_ON_ID ~= 0 && size(k_center_id,1) == 1
                CENTERING_OFFSET_XY = nodePositionXY(k_center_id,2:3,timeIndexNo_for_nodePositionXY);
            else
                CENTERING_OFFSET_XY = mean(nodePositionXY(:,2:3,timeIndexNo_for_nodePositionXY));
            end
            nodePositionXY(:,2:3,timeIndexNo_for_nodePositionXY) = nodePositionXY(:,2:3,timeIndexNo_for_nodePositionXY) - [ones(size(nodePositionXY(:,2:3,timeIndexNo_for_nodePositionXY),1),1) * CENTERING_OFFSET_XY(1), ones(size(nodePositionXY(:,2:3,timeIndexNo_for_nodePositionXY),1),1) * CENTERING_OFFSET_XY(2)];
            
        otherwise
            error('Select a valid value for LAYOUT_ALGORITHM!');
    end
    
    timeIndexNo_for_nodePositionXY = timeIndexNo_for_nodePositionXY + 1;
    
    if timeIndexNo > nextPercentPlotIndex
        nextPercentPlotIndex = nextPercentPlotIndex + amountOfTimeSamples/100;
        for s=1:(length(str))
            fprintf('\b');
        end
        str = sprintf('%.2f percent done...\n', timeIndexNo/amountOfTimeSamples*100);
        fprintf(str);
    end
    
end

if PLOT_VERBOSITY > 2 && LAYOUT_ALGORITHM == 2
    NO_OF_EN_LEVELS = 10;
    colorlist = hsv( NO_OF_EN_LEVELS * 2);
    legendStrs = cell(NO_OF_EN_LEVELS,1);
    Mid_sample = round(size(t_w,1)/2);
    for linkNo=1:size(links,2)
        figure(434)
        hold on;
        en_step_width = (max(max(spring_En)) - min(min(spring_En)))/NO_OF_EN_LEVELS;
        for en_level=1:NO_OF_EN_LEVELS
            selected_Samples = spring_En(:,linkNo)>=(en_level-1)*en_step_width & spring_En(:,linkNo)<=(en_level)*en_step_width;
            graphEdege_m_temp = graphEdeges_m_filt(:,linkNo);
            graphEdege_m_temp(~selected_Samples) = NaN; 
            plot(t_w*TICK_DURATION, graphEdege_m_temp,'Color',colorlist(NO_OF_EN_LEVELS-en_level+1,:));
            if linkNo == 1
                fprintf('Step %d: from %.2f to %.2f\n', en_level, (en_level-1)*en_step_width, (en_level)*en_step_width);
                legendStrs{en_level} = sprintf('Step from %.2f to %.2f\n',(en_level-1)*en_step_width, (en_level)*en_step_width);
            end
        end
        linkStr = sprintf('%02x<->%02x', links(1,linkNo),links(2,linkNo));
        text(t_w(Mid_sample)*TICK_DURATION,graphEdeges_m_filt(Mid_sample,linkNo),linkStr,'FontSize',10);%,'FontWeight','bold');
    end
    legend(legendStrs);
    title('Energy kept in the link');
    hold off;
end

for s=1:(length(str))
    fprintf('\b');
end
fprintf('100 percent done...\n');
fprintf('Done!\n\n');