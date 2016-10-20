nextPercentPlotIndex = 0;
percent_str = [];
fprintf('ERROR CALCULATION:\n');
nans_infs_count = 0;
% if sum(size(nodePositionXY_GroundTh)  ~= size(nodePositionXY))
%     error('size(nodePositionXY_GroundTh)  ~= size(nodePositionXY)');
% end

if TREAT_AS_STATIC == 0
    if size(graphEdeges_m_filt,1) < size(graphEdeges_m_GroundTh,1)
        amountOfTimeSamples = size(graphEdeges_m_filt,1);
    else
        amountOfTimeSamples = size(graphEdeges_m_GroundTh,1);
        warning('The ground truth signal is shorter than the acquired one, the analysis will be restricted!');
    end
else
    amountOfTimeSamples = 1;
end

meanPositioningError = Inf(size(nodePositionXY,3),1);
nodePositionXY_transform = zeros(size(nodePositionXY));
nodePositionXY_transform(:,1,:) = nodePositionXY(:,1,:);
if ENABLE_FREE_TRANSFORMATION
    A_store = zeros(3,2,size(nodePositionXY,3));
else
    A_store = zeros(2,2,size(nodePositionXY,3));
end
link_length_mi_error = Inf(6,size(links,2),amountOfTimeSamples); %[node_id_1, node_id_2, link_length_error_1, link_length_error_1_percent,  link_length_error_2, link_length_error_2_percent ]

% node_id_1 : the id of the first node of the link
% node_id_2 : the id of the second node of the link
% link_length_error_1 : error on link lenght after localization [meter]
% link_length_error_1_percent : link_length_error_1 in percent
% link_length_error_2 : error on link lenght before localization, raw data [meter]
% link_length_error_2_percent : link_length_error_2 in percent

%A_store = zeros(1,1,size(nodePositionXY,3));
% if xstop_index > size(nodePositionXY_GroundTh,3)
%     xstop_index = size(nodePositionXY_GroundTh,3);
% end

%% CALCULATING TRANSFORMATION MATRIX
for timeIndexNo = 1 : amountOfTimeSamples
    if PLOT_VERBOSITY > 0
        %opts = optimset('Algorithm','lm-line-search');
        if ENABLE_FREE_TRANSFORMATION
            positiongErrorCost_an = @(A)positiongErrorCost_FreeTrans( A,nodePositionXY_GroundTh(:,:,timeIndexNo), nodePositionXY(:,:,timeIndexNo) );
        else
            positiongErrorCost_an = @(A)positiongErrorCost_RotRefTrasl( A,nodePositionXY_GroundTh(:,:,timeIndexNo), nodePositionXY(:,:,timeIndexNo) );
        end
        options = optimset('Display','notify','MaxFunEvals', 1000);
        if timeIndexNo == 1
            if ENABLE_FREE_TRANSFORMATION
                [A,fval] = fminsearch(positiongErrorCost_an,[eye(2);0,0],options);
            else
                [A,fval] = fminsearch(positiongErrorCost_an,[0,0;0,0],options);
            end
            %[A,fval] = fminsearch(positiongErrorCost_an,0,options);
        else
            [A,fval] = fminsearch(positiongErrorCost_an,A_store(:,:,timeIndexNo-1),options);
        end
        A_store(:,:,timeIndexNo) = A;
        meanPositioningError(timeIndexNo) = fval;
        for nodeNo = 1:size(nodePositionXY,1)
            %nodePositionXY(nodeNo,2:3,timeNo) = ((A(1:2,1:2)*nodePositionXY(nodeNo,2:3,timeNo)')+ A(3,:)')';
            %nodePositionXY(nodeNo,2:3,timeNo) = ([-cos(A) , sin(A); sin(A),cos(A)]*nodePositionXY(nodeNo,2:3,timeNo)')';
            if ENABLE_FREE_TRANSFORMATION
                nodePositionXY_transform(nodeNo,2:3,timeIndexNo) = ((A(1:2,1:2)*nodePositionXY(nodeNo,2:3,timeIndexNo)')+ A(3,:)')';
            else %only rotation/reflection/translation are allowed
                if A(1,2) > 0
                    nodePositionXY_transform(nodeNo,2:3,timeIndexNo) = ([cos(2*A(1,1)) , sin(2*A(1,1)); sin(2*A(1,1)),-cos(2*A(1,1))]*nodePositionXY(nodeNo,2:3,timeIndexNo)')- A(2,:)';
                else
                    nodePositionXY_transform(nodeNo,2:3,timeIndexNo) = ([cos(A(1,1)) , -sin(A(1,1)); sin(A(1,1)),cos(A(1,1))]*nodePositionXY(nodeNo,2:3,timeIndexNo)')- A(2,:)';
                end
            end
            
        end
    end
    linkNo_link_length_mi_error = 1;
    for nodeNo_m_GT = 1:size(nodePositionXY_GroundTh(:,:,1),1)-1
        nodeNo_m_LAY = find(nodePositionXY(:,1,timeIndexNo) == nodePositionXY_GroundTh(nodeNo_m_GT,1,timeIndexNo));
        if length(nodeNo_m_LAY) == 1
            for nodeNo_i_GT = nodeNo_m_GT+1:size(nodePositionXY_GroundTh(:,:,1),1)
                nodeNo_i_LAY = find(nodePositionXY(:,1,timeIndexNo) == nodePositionXY_GroundTh(nodeNo_i_GT,1,timeIndexNo));
                link_length_mi_error(1:2, linkNo_link_length_mi_error, timeIndexNo) = [nodePositionXY_GroundTh(nodeNo_i_GT,1,timeIndexNo), nodePositionXY_GroundTh(nodeNo_m_GT,1,timeIndexNo)];
                if length(nodeNo_i_LAY) == 1
                    % calculate link length on ground truth data (they are also stored in graphEdeges_m_GroundTh, but links_GroundTh has a different order wrt links)
                    link_length_mi_GT = sqrt( (nodePositionXY_GroundTh(nodeNo_m_GT,2,timeIndexNo)-nodePositionXY_GroundTh(nodeNo_i_GT,2,timeIndexNo))^2 + (nodePositionXY_GroundTh(nodeNo_m_GT,3,timeIndexNo)-nodePositionXY_GroundTh(nodeNo_i_GT,3,timeIndexNo))^2 );
                    link_length_mi_LAY = sqrt( (nodePositionXY(nodeNo_m_LAY,2,timeIndexNo)-nodePositionXY(nodeNo_i_LAY,2,timeIndexNo))^2 + (nodePositionXY(nodeNo_m_LAY,3,timeIndexNo)-nodePositionXY(nodeNo_i_LAY,3,timeIndexNo))^2 );
                    
                    linkNo_ACQ = find((links(1,:) == nodePositionXY_GroundTh(nodeNo_m_GT,1,timeIndexNo)) & (links(2,:) == nodePositionXY_GroundTh(nodeNo_i_GT,1,timeIndexNo)) | (links(2,:) == nodePositionXY_GroundTh(nodeNo_m_GT,1,timeIndexNo)) & (links(1,:) == nodePositionXY_GroundTh(nodeNo_i_GT,1,timeIndexNo)));
                    if length(linkNo_ACQ) == 1
                        link_length_mi_ACQ = graphEdeges_m_filt(timeIndexNo,linkNo_ACQ);
                        if link_length_mi_ACQ == Inf || isnan(link_length_mi_ACQ)
                            link_length_mi_ACQ = link_length_mi_GT;
                            nans_infs_count = nans_infs_count + 1;
                        end
                        link_length_mi_error(5, linkNo_link_length_mi_error, timeIndexNo) = (link_length_mi_ACQ - link_length_mi_GT);
                        link_length_mi_error(6, linkNo_link_length_mi_error, timeIndexNo) = (link_length_mi_ACQ - link_length_mi_GT)/link_length_mi_GT;
                    else
                        warning('The same link has been found twice in graphEdeges_m_filt or it is not present');
                    end
                    link_length_mi_error(3, linkNo_link_length_mi_error, timeIndexNo) = (link_length_mi_LAY - link_length_mi_GT); %% error on links length after the layout (the transformation doesn't impacto on this)
                    link_length_mi_error(4, linkNo_link_length_mi_error, timeIndexNo) = (link_length_mi_LAY - link_length_mi_GT)/link_length_mi_GT; %% error on links length after the layout [percent]
                    
                    linkNo_link_length_mi_error = linkNo_link_length_mi_error + 1;
                else
                    warning('A node is missing from nodePositionXY or is repeated more than once');
                end
            end
        else
            warning('A node is missing from nodePositionXY or is repeated more than once');
        end
    end
    
    
    %PLOT PROGRESS PERCENT DATA
    if timeIndexNo > nextPercentPlotIndex
        nextPercentPlotIndex = nextPercentPlotIndex + 0.5*amountOfTimeSamples/100;
        for s=1:length(percent_str)
            fprintf('\b');
        end
        percent_str = sprintf('%.2f percent of error calculation...\n', timeIndexNo / amountOfTimeSamples*100);
        fprintf(percent_str);
    end
end

% node_id_1 : the id of the first node of the link
% node_id_2 : the id of the second node of the link
% link_length_error_1 : error on link lenght after localization [meter]
% link_length_error_1_percent : link_length_error_1 in percent
% link_length_error_2 : error on link lenght before localization, raw data [meter]
% link_length_error_2_percent : link_length_error_2 in percent

% fprintf('Position based error: %.2f m\n',mean(meanPositioningError,1));
% fprintf('Links length error (after localization): %.2f m, or %.2f percent\n',mean(mean(link_length_mi_error(3,:,:))),100*mean(mean(link_length_mi_error(2,:,:))));
% fprintf('Links length error (before localization): %.2f m, or %.2f percent\n',mean(mean(link_length_mi_error(3,:,:))),100*mean(mean(link_length_mi_error(4,:,:))));
if nans_infs_count 
    warning('Some links length seems to be Inf or NaN, the error is set to zero for those sample to avoid Inf in final error calculation\n');
end
fprintf('Nans or Infs count: %d, or %.2f %% of total links samples.\n\n',nans_infs_count,100*nans_infs_count/(size(graphEdeges_m,2)*amountOfTimeSamples));
%uncomment the next line to see the error ditribution (only for methode 2)
%hist(reshape(link_length_mi_error(3,:,1:xstop_index),[numel(link_length_mi_error(3,:,1:xstop_index)),1]));

%% PLOTTING AND EXPORTING NODES LAYOUT
if PLOT_VERBOSITY > 0
    h = figure(215);
    set(h, 'Position', [300 35 720 640]);
    filename = '../output/nodesMap_animation_with_groundTh.gif';
    fps = 1/(winc_sec*DECIMATION_AFTER_FILT_FACTOR)*GIF_SPEEDUP;
    colorlist2 = hsv( size( nodePositionXY_transform,1) );
    squareDim = SQUARE_SIZE_M/2;
        
    max_spring_en = max(max(spring_En));
    max_link_unrel = max(max(LINKS_UNRELIABLITY));
    max_link_error = max(max(link_length_mi_error(3,:,:)));
    avg_spring_en = mean2(spring_En);
    avg_link_unrel = mean2(LINKS_UNRELIABLITY);
    avg_link_error = mean2(link_length_mi_error(3,:,:));
    for timeIndexNo = 1 : amountOfTimeSamples
        nodePositionXY_temp = nodePositionXY_transform(nodePositionXY_transform(:,1,timeIndexNo) ~= 0,:, timeIndexNo);
        nodePositionXY_GroundTh_temp = nodePositionXY_GroundTh(nodePositionXY_GroundTh(:,1,timeIndexNo) ~= 0,:, timeIndexNo);
        spring_En_temp = spring_En(timeIndexNo, :);
        link_unreliability_temp = LINKS_UNRELIABLITY(timeIndexNo,:);
        
        regularNodesPositionXY_temp =  nodePositionXY_temp(nodePositionXY_temp(:,1)~=254 & nodePositionXY_temp(:,1)~=FOCUS_ID_1 & nodePositionXY_temp(:,1)~=FOCUS_ID_2,:);
        regularNodesPositionXY_GroundTh_temp =  nodePositionXY_GroundTh_temp(nodePositionXY_GroundTh_temp(:,1)~=254 & nodePositionXY_GroundTh_temp(:,1)~=FOCUS_ID_1 & nodePositionXY_GroundTh_temp(:,1)~=FOCUS_ID_2,:);
        
        masterNodePositionXY_temp = nodePositionXY_temp(nodePositionXY_temp(:,1)==254,:);
        masterNodePositionXY_GroundTh_temp = nodePositionXY_GroundTh_temp(nodePositionXY_GroundTh_temp(:,1)==254,:);
        
        focusNodesPositionXY_temp = nodePositionXY_temp(nodePositionXY_temp(:,1)==FOCUS_ID_1 | nodePositionXY_temp(:,1)==FOCUS_ID_2,:);
        focusNodesPositionXY_GroundTh_temp = nodePositionXY_temp(nodePositionXY_GroundTh_temp(:,1)==FOCUS_ID_1 | nodePositionXY_GroundTh_temp(:,1)==FOCUS_ID_2,:);
        
        subplot(1,1,1);
        plot(regularNodesPositionXY_GroundTh_temp(:,2),regularNodesPositionXY_GroundTh_temp(:,3),'ro',masterNodePositionXY_GroundTh_temp(:,2),masterNodePositionXY_GroundTh_temp(:,3),'y.',focusNodesPositionXY_GroundTh_temp(:,2),focusNodesPositionXY_GroundTh_temp(:,3),'r.','LineWidth',3);
        hold on;
        subplot(1,1,1);
        plot(regularNodesPositionXY_temp(:,2),regularNodesPositionXY_temp(:,3),'bo',masterNodePositionXY_temp(:,2),masterNodePositionXY_temp(:,3),'ro',focusNodesPositionXY_temp(:,2),focusNodesPositionXY_temp(:,3),'go','LineWidth',3);
        
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
                    subplot(1,1,1);
                    %plot([node_1_pos(1), node_2_pos(1)],[node_1_pos(2), node_2_pos(2)],'LineWidth', 4*link_energy/max_spring_en);
                    plot([node_1_pos(1), node_2_pos(1)],[node_1_pos(2), node_2_pos(2)],'LineWidth', 3, 'Color', [47/256,79/256,79/256]);
                    plot([-squareDim+squareDim*0.1,-squareDim+squareDim*0.15],[-squareDim+squareDim*0.27, -squareDim+squareDim*0.33],'LineWidth', 3, 'Color', [47/256,79/256,79/256]);
                    if isempty(str)
                        str = sprintf('Links with energy > 0.4*max spring en');
                        text(-squareDim+squareDim*0.17,-squareDim+squareDim*0.3,str,'FontSize',10,'FontWeight','bold');
                    end
                else
                    warning('A node found in links has not been found in nodePositionXY_temp!!!');
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
%                     subplot(1,1,1);
%                     plot([node_1_pos(1), node_2_pos(1)],[node_1_pos(2), node_2_pos(2)],'LineWidth', 2,'Color', [255/256,153/256,153/256]);
%                     if isempty(str)
%                         plot([-squareDim+squareDim*0.1,-squareDim+squareDim*0.15],[-squareDim+squareDim*0.17, -squareDim+squareDim*0.23],'LineWidth', 2, 'Color', [255/256,153/256,153/256]);
%                         str = sprintf('Links with unreliability > 0.5*max link unrel');
%                         text(-squareDim+squareDim*0.17,-squareDim+squareDim*0.2,str,'FontSize',10,'FontWeight','bold');
%                     end
%                 else
%                     warning('A node found in links has not been found in nodePositionXY_temp!!!');
%                 end
%             end
%         end

        %plot links errors
        str = [];
        for linkNo=1:size(links,2)
            
            node_1_id = link_length_mi_error(1,linkNo,timeIndexNo);
            node_2_id = link_length_mi_error(2,linkNo,timeIndexNo);
            
            node_1_pos =  nodePositionXY_temp(nodePositionXY_temp(:,1) == node_1_id,2:3);
            node_2_pos =  nodePositionXY_temp(nodePositionXY_temp(:,1) == node_2_id,2:3);
            
            link_error_m = link_length_mi_error(3,linkNo,timeIndexNo);
            if abs(link_error_m) > 1.5
                if ~isempty(node_1_pos) && ~isempty(node_2_pos)
                    subplot(1,1,1);
                    plot([node_1_pos(1), node_2_pos(1)],[node_1_pos(2), node_2_pos(2)],'LineWidth', 1, 'Color', [200/256,0/256,200/256]);
                    if isempty(str)
                        plot([-squareDim+squareDim*0.1,-squareDim+squareDim*0.15],[-squareDim+squareDim*0.07, -squareDim+squareDim*0.13],'LineWidth', 1, 'Color', [200/256,0/256,200/256]);
                        str = sprintf('Links with error > 1.5 m');
                        text(-squareDim+squareDim*0.17,-squareDim+squareDim*0.1,str,'FontSize',10,'FontWeight','bold');
                    end
                else
                    warning('A node found in link_length_mi_error has not been found in nodePositionXY_temp!!!');
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
                    subplot(1,1,1);
                    plot(node_pos(1),node_pos(2),'o','MarkerSize', 20*node_En/max_nodes_en,'LineWidth', 3,'Color', [51/256,102/256,0/256]);
                    if isempty(str)
                        subplot(1,1,1);
                        plot(-squareDim+squareDim*0.12,-squareDim+squareDim*0.2,'o','MarkerSize', 10,'LineWidth', 3,'Color', [51/256,102/256,0/256]);
                        str = sprintf('Nodes with associated energy > 0.5*max nodes energy');
                        text(-squareDim+squareDim*0.17,-squareDim+squareDim*0.2,str,'FontSize',10,'FontWeight','bold');
                    end
                end
            end
        end
        
        
        subplot(1,1,1);
        hold off
        
        if TREAT_AS_STATIC == 0
            str = sprintf('Time = %.0f\n %d nodes inside the sqare\n %d nodes outside the square',(start_selected_cut_index+timeIndexNo*DECIMATION_AFTER_FILT_FACTOR)*winc_sec,nodeNo-nodesOutsideSquare,nodesOutsideSquare);
        else
            str = sprintf('%d nodes inside the sqare\n %d nodes outside the square',nodeNo-nodesOutsideSquare,nodesOutsideSquare);
        end
        text(-squareDim+squareDim*0.1,squareDim-squareDim*0.2,str,'FontSize',10,'FontWeight','bold');
        axis([-squareDim squareDim -squareDim squareDim]);
        h = subplot(1,1,1);
        set(h, 'Position', [0.04 0.08 0.92 0.92]);
                
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
end
