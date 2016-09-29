
% if sum(size(nodePositionXY_GroundTh)  ~= size(nodePositionXY))
%     error('size(nodePositionXY_GroundTh)  ~= size(nodePositionXY)');
% end

meanPositioningError = zeros(size(nodePositionXY,3),1);
nodePositionXY_transform = zeros(size(nodePositionXY));
nodePositionXY_transform(:,1,:) = nodePositionXY(:,1,:);
if ENABLE_FREE_TRANSFORMATION
    A_store = zeros(3,2,size(nodePositionXY,3));
else
    A_store = zeros(2,2,size(nodePositionXY,3));
end
link_length_mi_error = zeros(6,size(links,2),size(nodePositionXY_transform,3));

%A_store = zeros(1,1,size(nodePositionXY,3));
% if xstop_index > size(nodePositionXY_GroundTh,3)
%     xstop_index = size(nodePositionXY_GroundTh,3);
% end
if TREAT_AS_STATIC == 0
    amountOfTimeSamples = size(graphEdeges_m_filt,1);
else
    amountOfTimeSamples = 1;
end
%% CALCULATING TRANSFORMATION MATRIX
for timeNo = 1 : amountOfTimeSamples
    %opts = optimset('Algorithm','lm-line-search');
    if ENABLE_FREE_TRANSFORMATION
        positiongErrorCost_an = @(A)positiongErrorCost_FreeTrans( A,nodePositionXY_GroundTh(:,:,timeNo), nodePositionXY(:,:,timeNo) );
    else
        positiongErrorCost_an = @(A)positiongErrorCost_RotRefTrasl( A,nodePositionXY_GroundTh(:,:,timeNo), nodePositionXY(:,:,timeNo) );
    end
    options = optimset('Display','notify');
    if timeNo == 1
        if ENABLE_FREE_TRANSFORMATION
            [A,fval] = fminsearch(positiongErrorCost_an,[eye(2);0,0],options);
        else
            [A,fval] = fminsearch(positiongErrorCost_an,[0,0;0,0],options);
        end
        %[A,fval] = fminsearch(positiongErrorCost_an,0,options);
    else
        [A,fval] = fminsearch(positiongErrorCost_an,A_store(:,:,timeNo-1),options);
    end
    A_store(:,:,timeNo) = A;
    meanPositioningError(timeNo) = fval;
    for nodeNo = 1:size(nodePositionXY,1)
        %nodePositionXY(nodeNo,2:3,timeNo) = ((A(1:2,1:2)*nodePositionXY(nodeNo,2:3,timeNo)')+ A(3,:)')';
        %nodePositionXY(nodeNo,2:3,timeNo) = ([-cos(A) , sin(A); sin(A),cos(A)]*nodePositionXY(nodeNo,2:3,timeNo)')';
        if ENABLE_FREE_TRANSFORMATION
            nodePositionXY_transform(nodeNo,2:3,timeNo) = ((A(1:2,1:2)*nodePositionXY(nodeNo,2:3,timeNo)')+ A(3,:)')';
        else %only rotation/reflection/translation are allowed
            if A(1,2) > 0
                nodePositionXY_transform(nodeNo,2:3,timeNo) = ([cos(2*A(1,1)) , sin(2*A(1,1)); sin(2*A(1,1)),-cos(2*A(1,1))]*nodePositionXY(nodeNo,2:3,timeNo)')- A(2,:)';
            else
                nodePositionXY_transform(nodeNo,2:3,timeNo) = ([cos(A(1,1)) , -sin(A(1,1)); sin(A(1,1)),cos(A(1,1))]*nodePositionXY(nodeNo,2:3,timeNo)')- A(2,:)';
            end
        end
        
    end
    
    linkNo_link_length_mi_error = 1;
    for nodeNo_m_GT = 1:size(nodePositionXY_GroundTh(:,:,1),1)-1
        nodeNo_m_LAY = find(nodePositionXY_transform(:,1,timeNo) == nodePositionXY_GroundTh(nodeNo_m_GT,1,timeNo));
        if length(nodeNo_m_LAY) == 1
            for nodeNo_i_GT = nodeNo_m_GT+1:size(nodePositionXY_GroundTh(:,:,1),1)
                nodeNo_i_LAY = find(nodePositionXY_transform(:,1,timeNo) == nodePositionXY_GroundTh(nodeNo_i_GT,1,timeNo));
                if length(nodeNo_i_LAY) == 1
                    link_length_mi_GT = sqrt( (nodePositionXY_GroundTh(nodeNo_m_GT,2,timeNo)-nodePositionXY_GroundTh(nodeNo_i_GT,2,timeNo))^2 + (nodePositionXY_GroundTh(nodeNo_m_GT,3,timeNo)-nodePositionXY_GroundTh(nodeNo_i_GT,3,timeNo))^2 );
                    link_length_mi_LAY = sqrt( (nodePositionXY_transform(nodeNo_m_LAY,2,timeNo)-nodePositionXY_transform(nodeNo_i_LAY,2,timeNo))^2 + (nodePositionXY_transform(nodeNo_m_LAY,3,timeNo)-nodePositionXY_transform(nodeNo_i_LAY,3,timeNo))^2 );
                    
                    linkNo_ACQ = find((links(1,:) == nodePositionXY_GroundTh(nodeNo_m_GT,1,timeNo)) & (links(2,:) == nodePositionXY_GroundTh(nodeNo_i_GT,1,timeNo)) | (links(2,:) == nodePositionXY_GroundTh(nodeNo_m_GT,1,timeNo)) & (links(1,:) == nodePositionXY_GroundTh(nodeNo_i_GT,1,timeNo)));
                    if length(linkNo_ACQ) == 1
                        link_length_mi_ACQ = graphEdeges_m_filt(timeNo,linkNo_ACQ);
                        link_length_mi_error(5, linkNo_link_length_mi_error, timeNo) = link_length_mi_ACQ - link_length_mi_GT;
                        link_length_mi_error(6, linkNo_link_length_mi_error, timeNo) = (link_length_mi_ACQ - link_length_mi_GT)/link_length_mi_GT;
                    else
                        warning('The same link has been found twice in graphEdeges_m_filt or it is not present');
                    end
                    
                    link_length_mi_error(3, linkNo_link_length_mi_error, timeNo) = link_length_mi_LAY - link_length_mi_GT;
                    link_length_mi_error(4, linkNo_link_length_mi_error, timeNo) = (link_length_mi_LAY - link_length_mi_GT)/link_length_mi_GT;
                    link_length_mi_error(1, linkNo_link_length_mi_error, timeNo) = nodePositionXY_GroundTh(nodeNo_m_GT,1,timeNo);
                    link_length_mi_error(2, linkNo_link_length_mi_error, timeNo) = nodePositionXY_GroundTh(nodeNo_i_GT,1,timeNo);
                    linkNo_link_length_mi_error = linkNo_link_length_mi_error + 1;
                else
                    warning('A node is missing from nodePositionXY or is repeated more than once');
                end
            end
        else
            warning('A node is missing from nodePositionXY or is repeated more than once');
        end
    end
    
end

fprintf('Error for all nodes for the whole duration (method 1 - position based): %.2f m\n',mean(meanPositioningError,1));
fprintf('Error for all nodes for the whole duration (method 2 - link length based): %.2f m, or %.2f percent\n',mean(mean(link_length_mi_error(3,:,:))),100*mean(mean(link_length_mi_error(4,:,:))));
fprintf('Link length error prior localization: %.2f m, or %.2f percent\n',mean(mean(link_length_mi_error(5,:,:))),100*mean(mean(link_length_mi_error(6,:,:))));

%uncomment the next line to see the error ditribution (only for methode 2)
%hist(reshape(link_length_mi_error(3,:,1:xstop_index),[numel(link_length_mi_error(3,:,1:xstop_index)),1]));

%% PLOTTING AND EXPORTING NODES LAYOUT
figure(215)
filename = '../output/output_Animation_sampleData.gif';
fps = 1/winc_sec*5;
colorlist2 = hsv( size( nodePositionXY_transform,1) );
squareDim = SQUARE_SIZE_M/2;
for timeIndexNo = 1 : amountOfTimeSamples
    nodePositionXY_temp = nodePositionXY_transform(nodePositionXY_transform(:,1,timeIndexNo) ~= 0,:, timeIndexNo);
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
    str = sprintf('Time = %.0f\n %d nodes inside the sqare\n %d nodes outside the square',(start_selected_cut_index+timeIndexNo)*winc_sec,nodeNo-nodesOutsideSquare,nodesOutsideSquare);
    text(-squareDim+squareDim*0.1,squareDim-squareDim*0.2,str,'FontSize',10,'FontWeight','bold');
    axis([-squareDim squareDim -squareDim squareDim]);
    
    drawnow
    frame = getframe(215);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if timeIndexNo == 1
        imwrite(imind,cm,filename,'gif', 'Loopcount',Inf,'delaytime',1/fps);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append','delaytime',1/fps);
    end
end

