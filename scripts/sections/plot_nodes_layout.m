%% PLOTTING AND EXPORTING NODES LAYOUT
figure(205)
filename = '../output/output_Animation.gif';
fps = 1/winc_sec*3;
colorlist2 = hsv( size(nodePositionXY,1) );
colorlist3 = hsv( max(max(IDX)) + 1 );
squareDim = SQUARE_SIZE_M/2;
if TREAT_AS_STATIC == 0
    amountOfTimeSamples = size(nodePositionXY,3);
else
    amountOfTimeSamples = 1;
end
for timeIndexNo = 1 : amountOfTimeSamples
    nodePositionXY_temp = nodePositionXY(nodePositionXY(:,1,timeIndexNo) ~= 0,:, timeIndexNo);
    nodesOutsideSquare = 0;
    %     regularNodesPositionXY_temp =  nodePositionXY_temp(nodePositionXY_temp(:,1)~=254 & nodePositionXY_temp(:,1)~=FOCUS_ID_1 & nodePositionXY_temp(:,1)~=FOCUS_ID_2,:);
    %     masterNodePositionXY_temp = nodePositionXY_temp(nodePositionXY_temp(:,1)==254,:);
    %     focusNodesPositionXY_temp = nodePositionXY_temp(nodePositionXY_temp(:,1)==FOCUS_ID_1 | nodePositionXY_temp(:,1)==FOCUS_ID_2,:);
    %     figure(205)
    %     plot(regularNodesPositionXY_temp(:,2),regularNodesPositionXY_temp(:,3),'bo',masterNodePositionXY_temp(:,2),masterNodePositionXY_temp(:,3),'ro',focusNodesPositionXY_temp(:,2),focusNodesPositionXY_temp(:,3),'go','LineWidth',3);
    %     xlabel('[m]');
    %     ylabel('[m]');
    %     grid on;
    for cluserNo = 1:numberOfClusters(timeIndexNo)
        figure(205);
        plot(nodePositionXY_temp(IDX(:,timeIndexNo) == cluserNo,2),nodePositionXY_temp(IDX(:,timeIndexNo) == cluserNo,3),'o','Color',colorlist3(cluserNo,:));
        hold on
        xlabel('[m]');
        ylabel('[m]');
        grid on;
        for nodeNo = 1 : size(nodePositionXY_temp,1)
            if IDX(nodeNo,timeIndexNo) == cluserNo
                if PLOT_NODE_LABELS == 1
                    str = sprintf('%x',nodePositionXY_temp(nodeNo,1));
                    text(nodePositionXY_temp(nodeNo,2)+1,nodePositionXY_temp(nodeNo,3),str,'Color',colorlist3(cluserNo,:),'FontSize',14,'FontWeight','bold');
                end
                if nodePositionXY_temp(nodeNo,2) > squareDim || nodePositionXY_temp(nodeNo,2) < -squareDim || nodePositionXY_temp(nodeNo,3) > squareDim || nodePositionXY_temp(nodeNo,3) < -squareDim
                    nodesOutsideSquare = nodesOutsideSquare + 1;
                end
            end
        end
    end
    hold off
    
    if TREAT_AS_STATIC == 0
        str = sprintf('Time = %.0f\n %d nodes inside the sqare\n %d nodes outside the square',(start_selected_cut_index+timeIndexNo)*winc_sec,nodeNo-nodesOutsideSquare,nodesOutsideSquare);
    else
        str = sprintf('%d nodes inside the sqare\n %d nodes outside the square',nodeNo-nodesOutsideSquare,nodesOutsideSquare);
    end
    text(-squareDim+squareDim*0.1,squareDim-squareDim*0.2,str,'FontSize',10,'FontWeight','bold');
    axis([-squareDim squareDim -squareDim squareDim]);
    
    drawnow
    frame = getframe(205);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if timeIndexNo == 1;
        imwrite(imind,cm,filename,'gif', 'Loopcount',Inf,'delaytime',1/fps);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append','delaytime',1/fps);
    end
end
