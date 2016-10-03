%% PLOTTING AND EXPORTING NODES LAYOUT
% h = figure(205);
% set(get(h,'Children'),'HitTest','off');
nodeMap_gif_filename = '../output/nodesMap_animation.gif';
fps = 1/(winc_sec*DECIMATION_AFTER_FILT_FACTOR)*GIF_SPEEDUP;
max_number_of_Clusters = max(max(IDX_pre_localization(:,2,:))) + 1;
colorlist2 = hsv( size(nodePositionXY,1) );
colorlist3 = hsv( max_number_of_Clusters + 1 );
squareDim = SQUARE_SIZE_M/2;
nextPercentPlotIndex = 0;
percent_str = [];
fprintf('PLOTTING AND SAVING NODE MAP:\n');
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
    h=figure(205);
    set(get(h,'Children'),'HitTest','off');
    for cluserNo = 1:max([IDX_pre_localization(:,2,timeIndexNo);IDX_post_localization(:,2,timeIndexNo)])+ 2
        if (cluserNo-1) == 0 %cluster number 0 represent noise or (maybe) unclustered nodes
            style = 'x';
        else
            style = 'o';
        end
        %plot nodes on pre localization plot
        if sum(IDX_pre_localization(:,2,timeIndexNo) == cluserNo-1)
            subplot(1,2,1);
            plot(nodePositionXY_temp(IDX_pre_localization(:,2,timeIndexNo) == cluserNo-1,2),nodePositionXY_temp(IDX_pre_localization(:,2,timeIndexNo) == cluserNo-1,3),style,'Color',colorlist3(cluserNo,:));
            hold on
        end
        %plot nodes on post localization plot
        if sum(IDX_post_localization(:,2,timeIndexNo) == cluserNo-1)
            subplot(1,2,2);
            plot(nodePositionXY_temp(IDX_post_localization(:,2,timeIndexNo) == cluserNo-1,2),nodePositionXY_temp(IDX_post_localization(:,2,timeIndexNo) == cluserNo-1,3),style,'Color',colorlist3(cluserNo,:));
            hold on
        end
    end
    subplot(1,2,1);
    xlabel('[m]');
    ylabel('[m]');
    grid on;
    title('Pre localization clustering');
    axis([-squareDim squareDim -squareDim squareDim]);
    hold off;
    
    subplot(1,2,2);
    xlabel('[m]');
    ylabel('[m]');
    grid on;
    title('Post localization clustering');
    hold off;
    axis([-squareDim squareDim -squareDim squareDim]);
    for cluserNo = 1:max([IDX_pre_localization(:,2,timeIndexNo);IDX_post_localization(:,2,timeIndexNo)])+ 2
        %print text on pre localization plot
        if sum(IDX_pre_localization(:,2,timeIndexNo) == cluserNo-1)
            for nodeNo = 1 : size(nodePositionXY_temp,1)
                if IDX_pre_localization(nodeNo,2,timeIndexNo) == cluserNo-1
                    if nodePositionXY_temp(nodeNo,2) > squareDim || nodePositionXY_temp(nodeNo,2) < -squareDim || nodePositionXY_temp(nodeNo,3) > squareDim || nodePositionXY_temp(nodeNo,3) < -squareDim
                        nodesOutsideSquare = nodesOutsideSquare + 1;
                    else
                        if PLOT_NODE_LABELS == 1
                            str = sprintf('%x',nodePositionXY_temp(nodeNo,1));
                            subplot(1,2,1);
                            text(nodePositionXY_temp(nodeNo,2)+1,nodePositionXY_temp(nodeNo,3),str,'Color',colorlist3(cluserNo,:),'FontSize',14,'FontWeight','bold');
                        end
                    end
                end
            end
        end
        %print text on post localization plot
        if sum(IDX_post_localization(:,2,timeIndexNo) == cluserNo-1)
            for nodeNo = 1 : size(nodePositionXY_temp,1)
                if IDX_post_localization(nodeNo,2,timeIndexNo) == cluserNo-1
                    if nodePositionXY_temp(nodeNo,2) > squareDim || nodePositionXY_temp(nodeNo,2) < -squareDim || nodePositionXY_temp(nodeNo,3) > squareDim || nodePositionXY_temp(nodeNo,3) < -squareDim
                        %nothing to do
                    else
                        if PLOT_NODE_LABELS == 1
                            str = sprintf('%x',nodePositionXY_temp(nodeNo,1));
                            subplot(1,2,2);
                            text(nodePositionXY_temp(nodeNo,2)+1,nodePositionXY_temp(nodeNo,3),str,'Color',colorlist3(cluserNo,:),'FontSize',14,'FontWeight','bold');
                        end
                    end
                end
            end
        end
    end
    
    if TREAT_AS_STATIC == 0
        str = sprintf('Time = %.0f\n %d nodes inside the sqare\n %d nodes outside the square',(start_selected_cut_index+timeIndexNo*DECIMATION_AFTER_FILT_FACTOR)*winc_sec,nodeNo-nodesOutsideSquare,nodesOutsideSquare);
    else
        str = sprintf('%d nodes inside the sqare\n %d nodes outside the square',nodeNo-nodesOutsideSquare,nodesOutsideSquare);
    end
    subplot(1,2,1);
    text(-squareDim+squareDim*0.1,squareDim-squareDim*0.2,str,'FontSize',10,'FontWeight','bold');
    axis([-squareDim squareDim -squareDim squareDim]);
    subplot(1,2,2);
    text(-squareDim+squareDim*0.1,squareDim-squareDim*0.2,str,'FontSize',10,'FontWeight','bold');
    axis([-squareDim squareDim -squareDim squareDim]);
    
    drawnow
    frame = getframe(205);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if timeIndexNo == 1
        imwrite(imind,cm,nodeMap_gif_filename,'gif', 'Loopcount',Inf,'delaytime',1/fps);
    else
        imwrite(imind,cm,nodeMap_gif_filename,'gif','WriteMode','append','delaytime',1/fps);
    end
    
    %PLOT PROGRESS PERCENT DATA
    if timeIndexNo > nextPercentPlotIndex
        nextPercentPlotIndex = nextPercentPlotIndex + 0.1*amountOfTimeSamples/100;
        for s=1:length(percent_str)
            fprintf('\b');
        end
        percent_str = sprintf('%.2f percent of map plotting done...\n', timeIndexNo / amountOfTimeSamples*100);
        fprintf(percent_str);
    end
end
for s=1:length(percent_str)
    fprintf('\b');
end
fprintf('Done!...\n\n');

