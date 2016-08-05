%% GENERATE SAMPLE DATA FOR FIXED NODES
button = 1;
fixedNodeNo = 0; 

%fixedNodesPositionXY(1,:) = [firstNodeId, 0, 0];
figure(1)
%plot(fixedNodesPositionXY(1,2), fixedNodesPositionXY(1,3),'o')
plot(1000,1000);
axis([-1, SQUARE_SIZE_M-1, -1, SQUARE_SIZE_M-1]);
grid on;

fprintf('Insert new nodes by clicking on image (right click to stop)\n');
while button == 1
    [x,y,button] = ginput(1);
    if button == 1
        fprintf('Node with ID:%d inserted in pos (%.2f,%.2f)!\n',firstNodeId+fixedNodeNo, x,y);
        if fixedNodeNo == 0
            fixedNodesPositionXY = [firstNodeId+fixedNodeNo , x , y];
        else
            fixedNodesPositionXY = [fixedNodesPositionXY(1:fixedNodeNo,:);[firstNodeId+fixedNodeNo , x , y]];
        end
        plot(fixedNodesPositionXY(1:fixedNodeNo+1,2), fixedNodesPositionXY(1:fixedNodeNo+1,3),'o');
        axis([-1, SQUARE_SIZE_M-1, -1, SQUARE_SIZE_M-1]);
        grid on;
        fixedNodeNo = fixedNodeNo+1;
    end
end
fprintf('%d fixed nodes inserted!\n\n',fixedNodeNo);
%% GENERATE SAMPLE DATA FOR MOVING NODES (only linear trajectories are alowed)
movingNodeNo = 0;
button = 1;
fprintf('Insert new moving nodes by clicking on image, only linear trajectories are alowed (right click to stop)\n');
while button == 1
    fprintf('Select start point (right click to stop)...\n');
    [x,y,button] = ginput(1);
    if button == 1 %continue
        start_XY = [x,y];
        fprintf('Select stop point (right click to stop)...\n');
        [x,y,button] = ginput(1);
        if button == 1 %continue
            fprintf('Node with ID:%d inserted!\n',firstNodeId+fixedNodeNo+movingNodeNo);
            
            stop_XY = [x,y];
            
            len_XY = stop_XY - start_XY;
            speed_XY = len_XY./duration_s;
            
            if movingNodeNo == 0
                movingNodePositionXY = zeros(1,3,size(t_w,2));
            end
            
            for timeNo = 1:size(t_w,2)
                movingNodePositionXY(movingNodeNo+1,:,timeNo) = [firstNodeId+fixedNodeNo+movingNodeNo, start_XY+speed_XY.*(timeNo-1).*Ts];
            end
            movingNodeNo = movingNodeNo + 1;
        end
    end
end
if movingNodeNo == 0 && fixedNodeNo == 0
    error('No node inserted!!\n');
end

fprintf('Moving nodes inserted!\n\n');
nodePositionXY_GroundTh = zeros(fixedNodeNo+movingNodeNo,3,size(t_w,2));
for timeNo = 1:size(t_w,2)
    if movingNodeNo ~= 0 && fixedNodeNo ~= 0
        nodePositionXY_GroundTh(:,:,timeNo) = [fixedNodesPositionXY ; movingNodePositionXY(:,:,timeNo)];
    elseif fixedNodeNo ~= 0
        nodePositionXY_GroundTh(:,:,timeNo) = fixedNodesPositionXY;
    elseif movingNodeNo ~= 0
        nodePositionXY_GroundTh(:,:,timeNo) = movingNodePositionXY(:,:,timeNo);
    end
    
    k_center_id = find(CENTER_ON_ID == nodePositionXY_GroundTh(:,1,timeNo));
    
    if CENTER_ON_ID ~= 0
        if size(k_center_id) == 0
            
        elseif size(k_center_id) == 1
            CENTERING_OFFSET_XY = nodePositionXY_GroundTh(k_center_id,2:3,timeNo);
            nodePositionXY_GroundTh(:,2:3,timeNo) = nodePositionXY_GroundTh(:,2:3,timeNo) - [ones(size(nodePositionXY_GroundTh(:,2:3,timeNo),1),1) * CENTERING_OFFSET_XY(1), ones(size(nodePositionXY_GroundTh(:,2:3,timeNo),1),1) * CENTERING_OFFSET_XY(2)];
        else
            error('More than one (%d) ID is %d!!\n',size(k_center_id),CENTER_ON_ID);
        end
    end
end

if CENTER_ON_ID == 0 || isempty(find(nodePositionXY_GroundTh(:,1,1) == CENTER_ON_ID,1))
    warning('It is not raccomended to run this script without centerning a node! Check CENTER_ON_ID');
end

%% CALCULATE LINKS  AND OTHERS VARIABLES NEEDED FOR THE LAYOUT
links = [];
graphEdeges_m = [];
for nodeNo_1 = 1:size(nodePositionXY_GroundTh,1)-1
    for nodeNo_2 = nodeNo_1+1:size(nodePositionXY_GroundTh,1)
        graphEdeges_m_link = [];
        links = cat(2,links,[nodePositionXY_GroundTh(nodeNo_1,1,1);nodePositionXY_GroundTh(nodeNo_2,1,1)]);
        for timeIndexNo = 1 : size(nodePositionXY_GroundTh,3)
            d = sqrt( (nodePositionXY_GroundTh(nodeNo_2,2,timeIndexNo) - nodePositionXY_GroundTh(nodeNo_1,2,timeIndexNo))^2 + (nodePositionXY_GroundTh(nodeNo_2,3,timeIndexNo) - nodePositionXY_GroundTh(nodeNo_1,3,timeIndexNo))^2 );
            graphEdeges_m_link = cat(1,graphEdeges_m_link,d);
        end
        graphEdeges_m =  cat(2,graphEdeges_m,graphEdeges_m_link);
    end
end
LINKS_UNRELIABLITY = zeros(size(t_w,2),size(links,2));
AVAILABLE_IDs = nodePositionXY_GroundTh(:,1,1);

%% PLAYBACK THE GENERATED DATA
figure(2)
filename = '../output/fakeData.gif';
fps = 1/Ts*5;
colorlist2 = hsv( size(nodePositionXY_GroundTh,1) );
squareDim = SQUARE_SIZE_M/2;
fprintf('Playback data!\n\n');
for timeIndexNo = 1 : size(nodePositionXY_GroundTh,3)
    nodePositionXY_temp = nodePositionXY_GroundTh(nodePositionXY_GroundTh(:,1,timeIndexNo) ~= 0,:, timeIndexNo);
    nodesOutsideSquare = 0;
    regularNodesPositionXY_temp =  nodePositionXY_temp(nodePositionXY_temp(:,1)~=254 & nodePositionXY_temp(:,1)~=FOCUS_ID_1 & nodePositionXY_temp(:,1)~=FOCUS_ID_2,:);
    masterNodePositionXY_temp = nodePositionXY_temp(nodePositionXY_temp(:,1)==254,:);
    focusNodesPositionXY_temp = nodePositionXY_temp(nodePositionXY_temp(:,1)==FOCUS_ID_1 | nodePositionXY_temp(:,1)==FOCUS_ID_2,:);
    plot(regularNodesPositionXY_temp(:,2),regularNodesPositionXY_temp(:,3),'bo',masterNodePositionXY_temp(:,2),masterNodePositionXY_temp(:,3),'ro',focusNodesPositionXY_temp(:,2),focusNodesPositionXY_temp(:,3),'go','LineWidth',3);
    xlabel('[m]?');
    ylabel('[m]?');
    grid on;
    for nodeNo = 1 : size(nodePositionXY_temp,1)
        if PLOT_NODE_LABELS == 1
            str = sprintf('%x',nodePositionXY_temp(nodeNo,1));
            text(nodePositionXY_temp(nodeNo,2)+3,nodePositionXY_temp(nodeNo,3),str,'Color',colorlist2(nodeNo,:),'FontSize',14,'FontWeight','bold');
        end
        if nodePositionXY_temp(nodeNo,2) > squareDim || nodePositionXY_temp(nodeNo,2) < -squareDim || nodePositionXY_temp(nodeNo,3) > squareDim || nodePositionXY_temp(nodeNo,3) < -squareDim
            nodesOutsideSquare = nodesOutsideSquare + 1;
        end
    end
    str = sprintf('Time = %.0f\n %d nodes inside the sqare\n %d nodes outside the square',timeIndexNo*Ts,nodeNo-nodesOutsideSquare,nodesOutsideSquare);
    text(-squareDim+squareDim*0.1,squareDim-squareDim*0.2,str,'FontSize',10,'FontWeight','bold');
    axis([-squareDim squareDim -squareDim squareDim]);
    
    drawnow
    frame = getframe(2);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if timeIndexNo == 1;
        imwrite(imind,cm,filename,'gif', 'Loopcount',Inf,'delaytime',1/fps);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append','delaytime',1/fps);
    end
end


T_TAG = [];
TICK_DURATION = 1;