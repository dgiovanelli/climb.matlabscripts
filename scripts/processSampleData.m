%% CALULATING LAYOUT
xstart_index = 1;
xstop_index = size(t,2);

fprintf('CALCULATING LAYOUT:\n');
nodePositionXY = zeros(length(AVAILABLE_IDs),3,xstop_index-xstart_index);
nodePositionIndex = 1;
nextPercentPlotIndex = xstart_index;
str = [];
for timeIndexNo = xstart_index : xstop_index
    CENTERING_OFFSET_XY = [0,0];
    switch LAYOUT_ALGORITHM
        case 0 % use neato to place nodes
            if timeIndexNo == xstart_index
                createDOTdescriptionFile( graphEdeges_m_filt(timeIndexNo,:), links, 1+LINKS_UNRELIABLITY(timeIndexNo,:) , '../output/output_m_temp.dot',[]); %1+LINKS_UNRELIABLITY(timeIndexNo,:) is because LINKS_UNRELIABLITY is zero if the link is reliable, inside createDOTdescriptionFile the spring constant is calculated with 1/LINKS_UNRELIABLITY(...). If LINKS_UNRELIABLITY(...) == 0 the constant will be Inf...
            else
                createDOTdescriptionFile( graphEdeges_m_filt(timeIndexNo,:), links, 1+LINKS_UNRELIABLITY(timeIndexNo,:) , '../output/output_m_temp.dot',nodePositionXY(:,:,nodePositionIndex-1));
            end
            [status,cmdout] = dos('neato -Tplain ../output/output_m_temp.dot');
            if status == 0
                textLines = textscan(cmdout, '%s','delimiter', '\n');
                
                for textLineNo = 2:length(textLines{1})
                    tLine = sscanf( char(textLines{1}(textLineNo)),'%s %d %f %f');
                    if( tLine(1) == 'n' && tLine(2) == 'o' && tLine(3) == 'd' && tLine(4) == 'e')
                        k = find(AVAILABLE_IDs == tLine(5) )+1;
                        nodePositionXY(k-1,:,nodePositionIndex) = tLine(5:7)';
                        if tLine(5) == CENTER_ON_ID
                            k_center_id = k;
                            if CENTER_ON_ID ~= 0
                                CENTERING_OFFSET_XY = nodePositionXY(k_center_id-1,2:3,nodePositionIndex);
                            end
                        end
                    end
                end
                
                if CENTER_ON_ID ~= 0 && sum(CENTERING_OFFSET_XY) ~= 0
                    for i_id = 1:size(nodePositionXY,1)
                        if nodePositionXY(i_id,1,nodePositionIndex) ~= 0
                            nodePositionXY(i_id,2:3,nodePositionIndex) = nodePositionXY(i_id,2:3,nodePositionIndex) - CENTERING_OFFSET_XY;
                        end
                    end
                end
                
            end
        case 1 % Use multidimensional scaling for placing nodes
            if timeIndexNo == xstart_index
                nodePositionXY(:,:,nodePositionIndex) = mdsLayout(graphEdeges_m_filt(timeIndexNo,:), links, 1+LINKS_UNRELIABLITY(timeIndexNo,:),[]); %1+LINKS_UNRELIABLITY(timeIndexNo,:) is because LINKS_UNRELIABLITY is zero if the link is reliable, inside createDOTdescriptionFile the spring constant is calculated with 1/LINKS_UNRELIABLITY(...). If LINKS_UNRELIABLITY(...) == 0 the constant will be Inf...
                k_center_id = find(nodePositionXY(:,1,1) == CENTER_ON_ID);
            else
                nodePositionXY(:,:,nodePositionIndex) = mdsLayout(graphEdeges_m_filt(timeIndexNo,:), links, 1+LINKS_UNRELIABLITY(timeIndexNo,:),nodePositionXY(:,2:3,nodePositionIndex-1));
            end
            
            if size(k_center_id,1) == 1
                if CENTER_ON_ID ~= 0
                    CENTERING_OFFSET_XY = nodePositionXY(k_center_id,2:3,nodePositionIndex);
                    nodePositionXY(:,2:3,nodePositionIndex) = nodePositionXY(:,2:3,nodePositionIndex) - [ones(size(nodePositionXY(:,2:3,nodePositionIndex),1),1) * CENTERING_OFFSET_XY(1), ones(size(nodePositionXY(:,2:3,nodePositionIndex),1),1) * CENTERING_OFFSET_XY(2)];
                end
            end
            
        case 2 % Use mesh relaxation scaling for placing nodes
                  
            if timeIndexNo == xstart_index
                nodePositionXY(:,:,nodePositionIndex) = meshRelaxationLayout(graphEdeges_m_filt(timeIndexNo,:), links, 1+LINKS_UNRELIABLITY(timeIndexNo,:),[]); %1+LINKS_UNRELIABLITY(timeIndexNo,:) is because LINKS_UNRELIABLITY is zero if the link is reliable, inside createDOTdescriptionFile the spring constant is calculated with 1/LINKS_UNRELIABLITY(...). If LINKS_UNRELIABLITY(...) == 0 the constant will be Inf...
                k_center_id = find(nodePositionXY(:,1,1) == CENTER_ON_ID);
            else
                nodePositionXY(:,:,nodePositionIndex) = meshRelaxationLayout(graphEdeges_m_filt(timeIndexNo,:), links, 1+LINKS_UNRELIABLITY(timeIndexNo,:),nodePositionXY(:,2:3,nodePositionIndex-1));
            end
            
            if size(k_center_id,1) == 1
                if CENTER_ON_ID ~= 0
                    CENTERING_OFFSET_XY = nodePositionXY(k_center_id,2:3,nodePositionIndex);
                    nodePositionXY(:,2:3,nodePositionIndex) = nodePositionXY(:,2:3,nodePositionIndex) - [ones(size(nodePositionXY(:,2:3,nodePositionIndex),1),1) * CENTERING_OFFSET_XY(1), ones(size(nodePositionXY(:,2:3,nodePositionIndex),1),1) * CENTERING_OFFSET_XY(2)];
                end
            end
        otherwise
            error('Select a valid value for LAYOUT_ALGORITHM!');
    end
    
    nodePositionIndex = nodePositionIndex + 1;
    
    if timeIndexNo > nextPercentPlotIndex
        nextPercentPlotIndex = nextPercentPlotIndex + (xstop_index-xstart_index)/100;
        for s=1:(length(str))
            fprintf('\b');
        end
        str = sprintf('%.2f percent done...\n', (timeIndexNo-xstart_index)/(xstop_index-xstart_index)*100);
        fprintf(str);
    end
    
end
for s=1:(length(str))
    fprintf('\b');
end
fprintf('100 percent done...\n');
fprintf('Done!\n\n');

