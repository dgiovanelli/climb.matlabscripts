%% GENERATE SAMPLE DATA FOR FIXED NODES
button = 1;
fixedNodeNo = 2; %NB: the firs node is automatically inserted at pos (0,0)

fixedNodesPositionXY(1,:) = [firstNodeId, 0, 0];
figure(1)
plot(fixedNodesPositionXY(1,2), fixedNodesPositionXY(1,3),'o')
axis([-50, 50, -50, 50]);
grid on;

fprintf('Fixed node with ID:%d inserted in pos (0,0)\n',firstNodeId);
fprintf('Insert new nodes by clicking on image (right click to stop)\n');
while button == 1
    [x,y,button] = ginput(1);
    if button == 1
        fprintf('Node with ID:%d inserted in pos (%.2f,%.2f)!\n',firstNodeId+fixedNodeNo-1, x,y);
        fixedNodesPositionXY = [fixedNodesPositionXY(1:fixedNodeNo-1,:);[firstNodeId+fixedNodeNo-1 , x , y]];
        plot(fixedNodesPositionXY(1:fixedNodeNo,2), fixedNodesPositionXY(1:fixedNodeNo,3),'o');
        axis([-50, 50, -50, 50]);
        grid on;
        fixedNodeNo = fixedNodeNo+1;
    end
end
fprintf('Fixed nodes inserted!\n\n');
%% GENERATE SAMPLE DATA FOR MOVING NODES (only linear trajectories are alowed)
movingNodePositionXY = zeros(1,3,size(t,2));
movingNodeNo = 1;
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
            fprintf('Node with ID:%d inserted!\n',firstNodeId+fixedNodeNo-2+movingNodeNo);
            
            stop_XY = [x,y];
            
            len_XY = stop_XY - start_XY;
            speed_XY = len_XY./duration_s;
            
            for timeNo = 1:size(t,2)
                movingNodePositionXY(movingNodeNo,:,timeNo) = [firstNodeId+fixedNodeNo-2+movingNodeNo, start_XY+speed_XY.*timeNo.*Ts];
            end
            movingNodeNo = movingNodeNo + 1;
        end
    end
end
fprintf('Moving nodes inserted!\n\n');
nodePositionXY_GroundTh = zeros(fixedNodeNo-1+movingNodeNo-1,3,size(t,2));
for timeNo = 1:size(t,2)
    if movingNodeNo ~= 1
        nodePositionXY_GroundTh(:,:,timeNo) = [fixedNodesPositionXY ; movingNodePositionXY(:,:,timeNo)];
    else
        nodePositionXY_GroundTh(:,:,timeNo) = fixedNodesPositionXY;
    end
end

%% CALCULATE LINKS  AND OTHERS VARIABLES NEEDED FOR THE LAYOUT
links = [];
graphEdeges_m_filt = [];
for nodeNo_1 = 1:size(nodePositionXY_GroundTh,1)-1
    for nodeNo_2 = nodeNo_1+1:size(nodePositionXY_GroundTh,1)
        graphEdeges_m_filt_link = [];
        links = cat(2,links,[nodePositionXY_GroundTh(nodeNo_1,1,1);nodePositionXY_GroundTh(nodeNo_2,1,1)]);
        for timeIndexNo = 1 : size(nodePositionXY_GroundTh,3)
            d = sqrt( (nodePositionXY_GroundTh(nodeNo_2,2,timeIndexNo) - nodePositionXY_GroundTh(nodeNo_1,2,timeIndexNo))^2 + (nodePositionXY_GroundTh(nodeNo_2,3,timeIndexNo) - nodePositionXY_GroundTh(nodeNo_1,3,timeIndexNo))^2 );
            graphEdeges_m_filt_link = cat(1,graphEdeges_m_filt_link,d);
        end
        graphEdeges_m_filt =  cat(2,graphEdeges_m_filt,graphEdeges_m_filt_link);
    end
end
LINKS_UNRELIABLITY = zeros(size(t,2),size(links,2));
AVAILABLE_IDs = nodePositionXY_GroundTh(:,1,1);

noise = rand(size(graphEdeges_m_filt)) * NOISE_AMPL - NOISE_AMPL/2;
graphEdeges_m_filt = graphEdeges_m_filt + noise;
%% PLAYBACK THE GENERATED DATA
figure(2)
filename = '../output/fakeData.gif';
fps = 1/Ts*5;
colorlist2 = hsv( size(nodePositionXY_GroundTh,1) );
squareDim = 50;
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


