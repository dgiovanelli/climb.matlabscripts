if PLOT_VERBOSITY > 0
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
    max_spring_en = max(max(spring_En));
    max_nodes_en = max(max(nodes_En(2,:,:)));
    max_link_unrel = max(max(LINKS_UNRELIABLITY));  
    avg_spring_en = mean2(spring_En);
    avg_nodes_en = mean2(nodes_En(2,:,:));
    avg_link_unrel = mean2(LINKS_UNRELIABLITY);
    fprintf('PLOTTING AND SAVING NODE MAP:\n');
    if TREAT_AS_STATIC == 0
        amountOfTimeSamples = size(nodePositionXY,3);
    else
        amountOfTimeSamples = 1;
    end
    for timeIndexNo = 1 : amountOfTimeSamples
        nodePositionXY_temp = nodePositionXY(nodePositionXY(:,1,timeIndexNo) ~= 0,:, timeIndexNo);
        spring_En_temp = spring_En(timeIndexNo, :);
        nodes_En_temp = nodes_En(:,:,timeIndexNo);
        link_unreliability_temp = LINKS_UNRELIABLITY(timeIndexNo,:);
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
        set(h, 'Position', [10 35 1350 640])
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
                %
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
        %hold off;
        
        subplot(1,2,2);
        xlabel('[m]');
        ylabel('[m]');
        grid on;
        title('Post localization clustering');
        %hold off;
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
        
        %plot links energy
        str = [];
        for linkNo=1:size(links,2)
            
            node_1_id = links(1,linkNo);
            node_2_id = links(2,linkNo);
            
            node_1_pos =  nodePositionXY_temp(nodePositionXY_temp(:,1) == node_1_id,2:3);
            node_2_pos =  nodePositionXY_temp(nodePositionXY_temp(:,1) == node_2_id,2:3);
            
            link_energy = spring_En_temp(linkNo);
            if link_energy > 0.4*max_spring_en
                if ~isempty(node_1_pos) && ~isempty(node_2_pos)
                    subplot(1,2,1);
                    plot([node_1_pos(1), node_2_pos(1)],[node_1_pos(2), node_2_pos(2)],'LineWidth', 4*link_energy/max_spring_en);
                    subplot(1,2,2);
                    plot([node_1_pos(1), node_2_pos(1)],[node_1_pos(2), node_2_pos(2)],'LineWidth', 4*link_energy/max_spring_en);
                    if isempty(str)
                        str = sprintf('Highlighting links with energy > 0.4*max spring en');
                        subplot(1,2,1);
                        text(-squareDim+squareDim*0.1,-squareDim+squareDim*0.2,str,'FontSize',10,'FontWeight','bold');
                        subplot(1,2,2);
                        text(-squareDim+squareDim*0.1,-squareDim+squareDim*0.2,str,'FontSize',10,'FontWeight','bold');
                    end
                else
                    warning('A node found in links has not been found in nodePositionXY_temp!!!');
                end
            end
        end
        
       %plot nodes energy
        str = [];
        for nodeNo=1:size(nodes_En,1)
            node_id = nodes_En(nodeNo,1,timeIndexNo);
            node_En = nodes_En(nodeNo,2,timeIndexNo);
            if node_En > 0.5*max_nodes_en
                node_pos = nodePositionXY_temp(nodePositionXY_temp(:,1) == node_id,2:3);
                if ~isempty(node_1_pos)
                    subplot(1,2,1);
                    plot(node_pos(1),node_pos(2),'o','MarkerSize', 20*node_En/max_nodes_en,'LineWidth', 3,'Color', [51/256,102/256,0/256]);
                    subplot(1,2,2);
                    plot(node_pos(1),node_pos(2),'o','MarkerSize', 20*node_En/max_nodes_en,'LineWidth', 3,'Color', [51/256,102/256,0/256]);
                    if isempty(str)
                        str = sprintf('Highlighting nodes with associated energy > 0.5*max nodes energy');
                        subplot(1,2,1);
                        text(-squareDim+squareDim*0.1,-squareDim+squareDim*0.1,str,'FontSize',10,'FontWeight','bold');
                        subplot(1,2,2);
                        text(-squareDim+squareDim*0.1,-squareDim+squareDim*0.1,str,'FontSize',10,'FontWeight','bold');
                    end
                end
            end
        end
        
        %plot links unreliability
%         str = [];
%         for linkNo=1:size(links,2)
%             node_1_id = links(1,linkNo);
%             node_2_id = links(2,linkNo);
%             
%             node_1_pos =  nodePositionXY_temp(nodePositionXY_temp(:,1) == node_1_id,2:3);
%             node_2_pos =  nodePositionXY_temp(nodePositionXY_temp(:,1) == node_2_id,2:3);
%             
%             link_unreliability = link_unreliability_temp(linkNo);
%             if link_unreliability > 0.5*max_link_unrel
%                 if ~isempty(node_1_pos) && ~isempty(node_2_pos)
%                     %subplot(1,2,1);
%                     %plot([node_1_pos(1), node_2_pos(1)],[node_1_pos(2), node_2_pos(2)],'LineWidth', 4*link_unreliability/max_link_unrel);
%                     subplot(1,2,2);
%                     plot([node_1_pos(1), node_2_pos(1)],[node_1_pos(2), node_2_pos(2)],'LineWidth', 4*link_unreliability/max_link_unrel);
%                     
%                     if isempty(str)
%                         str = sprintf('Showing links with unreliability > 0.5*max link unrel');
%                         text(-squareDim+squareDim*0.1,-squareDim+squareDim*0.2,str,'FontSize',10,'FontWeight','bold');
%                     end
%                 else
%                     warning('A node found in links has not been found in nodePositionXY_temp!!!');
%                 end
%             end
%         end
        
        subplot(1,2,1);
        hold off
        subplot(1,2,2);
        hold off
        
        if TREAT_AS_STATIC == 0
            str = sprintf('Time = %.0f\n %d nodes inside the sqare\n %d nodes outside the square',(start_selected_cut_index+timeIndexNo*DECIMATION_AFTER_FILT_FACTOR)*winc_sec,nodeNo-nodesOutsideSquare,nodesOutsideSquare);
        else
            str = sprintf('%d nodes inside the sqare\n %d nodes outside the square',nodeNo-nodesOutsideSquare,nodesOutsideSquare);
        end
        h = subplot(1,2,1);
        text(-squareDim+squareDim*0.1,squareDim-squareDim*0.2,str,'FontSize',10,'FontWeight','bold');
        axis([-squareDim squareDim -squareDim squareDim]);
        set(h, 'Position', [0.04 0.08 0.46 0.92]);
        h = subplot(1,2,2);
        text(-squareDim+squareDim*0.1,squareDim-squareDim*0.2,str,'FontSize',10,'FontWeight','bold');
        axis([-squareDim squareDim -squareDim squareDim]);
        set(h, 'Position', [0.54 0.08 0.46 0.92]);
        
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
end
