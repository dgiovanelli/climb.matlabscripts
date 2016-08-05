
% if sum(size(nodePositionXY_GroundTh)  ~= size(nodePositionXY))
%     error('size(nodePositionXY_GroundTh)  ~= size(nodePositionXY)');
% end

meanPositioningError = zeros(size(nodePositionXY,3),1);
nodePositionXY_transform = zeros(size(nodePositionXY));
nodePositionXY_transform(:,1,:) = nodePositionXY(:,1,:);
if ENABLE_FULL_TRANSFORMATION
    A_store = zeros(3,2,size(nodePositionXY,3));
else
    A_store = zeros(2,2,size(nodePositionXY,3));
end
%A_store = zeros(1,1,size(nodePositionXY,3));
if xstop_index > size(nodePositionXY_GroundTh,3)
    xstop_index = size(nodePositionXY_GroundTh,3);
end
%% CALCULATING TRANSFORMATION MATRIX
for timeNo = xstart_index : xstop_index
    %opts = optimset('Algorithm','lm-line-search');
    if ENABLE_FULL_TRANSFORMATION
        positiongErrorCost_an = @(A)positiongErrorCost_FreeTrans( A,nodePositionXY_GroundTh(:,:,timeNo), nodePositionXY(:,:,timeNo-xstart_index+1) );
    else
        positiongErrorCost_an = @(A)positiongErrorCost_RotRefTrasl( A,nodePositionXY_GroundTh(:,:,timeNo), nodePositionXY(:,:,timeNo-xstart_index+1) );
    end
    options = optimset('Display','notify');
    if timeNo == xstart_index
        if ENABLE_FULL_TRANSFORMATION
            [A,fval] = fminsearch(positiongErrorCost_an,[eye(2);0,0],options);
        else
            [A,fval] = fminsearch(positiongErrorCost_an,[0,0;0,0],options);
        end
        %[A,fval] = fminsearch(positiongErrorCost_an,0,options);
    else
        [A,fval] = fminsearch(positiongErrorCost_an,A_store(:,:,timeNo-xstart_index),options);
    end
    A_store(:,:,timeNo-xstart_index+1) = A;
    meanPositioningError(timeNo-xstart_index+1) = fval;
    for nodeNo = 1:size(nodePositionXY,1)
        %nodePositionXY(nodeNo,2:3,timeNo-xstart_index+1) = ((A(1:2,1:2)*nodePositionXY(nodeNo,2:3,timeNo-xstart_index+1)')+ A(3,:)')';
        %nodePositionXY(nodeNo,2:3,timeNo-xstart_index+1) = ([-cos(A) , sin(A); sin(A),cos(A)]*nodePositionXY(nodeNo,2:3,timeNo-xstart_index+1)')';
        if ENABLE_FULL_TRANSFORMATION
            nodePositionXY_transform(nodeNo,2:3,timeNo-xstart_index+1) = ((A(1:2,1:2)*nodePositionXY(nodeNo,2:3,timeNo-xstart_index+1)')+ A(3,:)')';
        else
            if A(1,2) > 0
                nodePositionXY_transform(nodeNo,2:3,timeNo-xstart_index+1) = ([cos(2*A(1,1)) , sin(2*A(1,1)); sin(2*A(1,1)),-cos(2*A(1,1))]*nodePositionXY(nodeNo,2:3,timeNo-xstart_index+1)')- A(2,:)';
            else
                nodePositionXY_transform(nodeNo,2:3,timeNo-xstart_index+1) = ([cos(A(1,1)) , -sin(A(1,1)); sin(A(1,1)),cos(A(1,1))]*nodePositionXY(nodeNo,2:3,timeNo-xstart_index+1)')- A(2,:)';
            end
        end
        
    end
end

fprintf('AverageError for all nodes for the whole duration: %.2f m\n',mean(meanPositioningError,1));

%% PLOTTING AND EXPORTING NODES LAYOUT
figure(215)
filename = '../output/output_Animation_sampleData.gif';
fps = 1/winc_sec*5;
colorlist2 = hsv( size( nodePositionXY_transform,1) );
squareDim = SQUARE_SIZE_M/2;
for timeIndexNo = xstart_index : xstop_index
    nodePositionXY_temp = nodePositionXY_transform(nodePositionXY_transform(:,1,timeIndexNo-xstart_index+1) ~= 0,:, timeIndexNo-xstart_index+1);
    nodePositionXY_GroundTh_temp = nodePositionXY_GroundTh(nodePositionXY_GroundTh(:,1,timeIndexNo) ~= 0,:, timeIndexNo);
    
    regularNodesPositionXY_temp =  nodePositionXY_temp(nodePositionXY_temp(:,1)~=254 & nodePositionXY_temp(:,1)~=FOCUS_ID_1 & nodePositionXY_temp(:,1)~=FOCUS_ID_2,:);
    regularNodesPositionXY_GroundTh_temp =  nodePositionXY_GroundTh_temp(nodePositionXY_GroundTh_temp(:,1)~=254 & nodePositionXY_GroundTh_temp(:,1)~=FOCUS_ID_1 & nodePositionXY_GroundTh_temp(:,1)~=FOCUS_ID_2,:);
    
    masterNodePositionXY_temp = nodePositionXY_temp(nodePositionXY_temp(:,1)==254,:);
    masterNodePositionXY_GroundTh_temp = nodePositionXY_GroundTh_temp(nodePositionXY_GroundTh_temp(:,1)==254,:);
    
    focusNodesPositionXY_temp = nodePositionXY_temp(nodePositionXY_temp(:,1)==FOCUS_ID_1 | nodePositionXY_temp(:,1)==FOCUS_ID_2,:);
    focusNodesPositionXY_GroundTh_temp = nodePositionXY_temp(nodePositionXY_GroundTh_temp(:,1)==FOCUS_ID_1 | nodePositionXY_GroundTh_temp(:,1)==FOCUS_ID_2,:);
    
    plot(regularNodesPositionXY_GroundTh_temp(:,2),regularNodesPositionXY_GroundTh_temp(:,3),'ro',masterNodePositionXY_GroundTh_temp(:,2),masterNodePositionXY_GroundTh_temp(:,3),'y.',focusNodesPositionXY_GroundTh_temp(:,2),focusNodesPositionXY_GroundTh_temp(:,3),'r.','LineWidth',3);
    hold on;
    plot(regularNodesPositionXY_temp(:,2),regularNodesPositionXY_temp(:,3),'bo',masterNodePositionXY_temp(:,2),masterNodePositionXY_temp(:,3),'ro',focusNodesPositionXY_temp(:,2),focusNodesPositionXY_temp(:,3),'go','LineWidth',3);
    hold off;
    xlabel('[m]?');
    ylabel('[m]?');
    grid on;
    
    nodesOutsideSquare = 0;
    for nodeNo = 1 : size(nodePositionXY_temp,1)
        if PLOT_NODE_LABELS == 1
            str = sprintf('%x',nodePositionXY_temp(nodeNo,1));
            text(nodePositionXY_temp(nodeNo,2)+3,nodePositionXY_temp(nodeNo,3),str,'Color',colorlist2(nodeNo,:),'FontSize',10,'FontWeight','bold');
        end
        if nodePositionXY_temp(nodeNo,2) > squareDim || nodePositionXY_temp(nodeNo,2) < -squareDim || nodePositionXY_temp(nodeNo,3) > squareDim || nodePositionXY_temp(nodeNo,3) < -squareDim
            nodesOutsideSquare = nodesOutsideSquare + 1;
        end
    end
    str = sprintf('Time = %.0f\n %d nodes inside the sqare\n %d nodes outside the square',(xstart_index+timeIndexNo)*winc_sec,nodeNo-nodesOutsideSquare,nodesOutsideSquare);
    text(-squareDim+squareDim*0.1,squareDim-squareDim*0.2,str,'FontSize',10,'FontWeight','bold');
    axis([-squareDim squareDim -squareDim squareDim]);
    
    drawnow
    frame = getframe(215);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if timeIndexNo == xstart_index
        imwrite(imind,cm,filename,'gif', 'Loopcount',Inf,'delaytime',1/fps);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append','delaytime',1/fps);
    end
end

