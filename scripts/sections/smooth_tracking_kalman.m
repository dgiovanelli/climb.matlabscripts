%USE KALMAN FILTERS TO SMOOTH THE TRACKING

param.motionModel           = 'ConstantVelocity';
param.initialLocation       = 'Same as first detection';
param.initialEstimateError  = [1, 1];
param.motionNoise           = [0.1, 0.1];
param.measurementNoise      = 1;


nodePositionXY_kalman_smooth = zeros(size(nodePositionXY));
nodePositionXY_kalman_smooth(:,1,:) = nodePositionXY(:,1,:);
nodesAmount = size(nodePositionXY,1);
amountOfTimeSamples = size(nodePositionXY,3);


for nodeNo = 1 : nodesAmount
    
    node_detected_positions = permute(nodePositionXY(nodeNo,2:3,:),[2,3,1]);
    
    %node_tracked_positions = zeros(size(node_detected_positions));
    isTrackInitialized = false;
    
    for timeNo = 1:amountOfTimeSamples
        
        % Detect the ball.
        detectedLocation = node_detected_positions(:,timeNo);
        isObjectDetected = true;
        
        if ~isTrackInitialized
            if isObjectDetected
                % Initialize a track by creating a Kalman filter when the ball is
                % detected for the first time.
                initialLocation = detectedLocation;
                %initialLocation =
                %permute(nodePositionXY_GroundTh(nodeNo,2:3,timeNo),[2,3,1]); %use this to set the initial position with zero error
                kalmanFilter = configureKalmanFilter(param.motionModel, initialLocation, param.initialEstimateError, param.motionNoise, param.measurementNoise);
                
                isTrackInitialized = true;
                trackedLocation = correct(kalmanFilter, detectedLocation);
                label = 'Initial';
            else
                trackedLocation = [];
                label = '';
            end
            
            
        else
            % Use the Kalman filter to track the ball.
            if isObjectDetected % The ball was detected.
                % Reduce the measurement noise by calling predict followed by
                % correct.
                predict(kalmanFilter);
                trackedLocation = correct(kalmanFilter, detectedLocation);
                label = 'Corrected';
            else % The ball was missing.
                % Predict the ball's location.
                trackedLocation = predict(kalmanFilter);
                label = 'Predicted';
            end
        end
        
        %node_tracked_positions(:,timeNo) = trackedLocation;
        nodePositionXY_kalman_smooth(nodeNo,2:3,timeNo) = trackedLocation;
    end % for
end


%PLOT DIFFERENCES
if PLOT_VERBOSITY > 0
    %% PLOTTING AND EXPORTING NODES LAYOUT
    % h = figure(205);
    % set(get(h,'Children'),'HitTest','off');
    nodeMap_gif_filename = '../output/nodesMap_animation_kalman.gif';
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
        
        nodePositionXY_kalman_smooth_temp = nodePositionXY_kalman_smooth(nodePositionXY_kalman_smooth(:,1,timeIndexNo) ~= 0,:, timeIndexNo);
        spring_En_temp = spring_En(timeIndexNo, :);
        nodes_En_temp = nodes_En(:,:,timeIndexNo);
        link_unreliability_temp = LINKS_UNRELIABLITY(timeIndexNo,:);
        nodesOutsideSquare = 0;
        
        h=figure(211);
        set(get(h,'Children'),'HitTest','off');
        set(h, 'Position', [300 35 720 640]);
        
        subplot(1,1,1);
        plot(nodePositionXY_temp(:,2),nodePositionXY_temp(:,3),'o','Color',[51/256,102/256,0/256],'LineWidth', 3);
        hold on;
        plot(nodePositionXY_kalman_smooth_temp(:,2),nodePositionXY_kalman_smooth_temp(:,3),'o','Color', [200/256,0/256,200/256],'LineWidth', 3);
        legend('Before kalman','After kalman');
        xlabel('[m]');
        ylabel('[m]');
        grid on;
        
        axis([-squareDim squareDim -squareDim squareDim]);
        %hold off;
        
        
        subplot(1,1,1);
        hold off
        
        if TREAT_AS_STATIC == 0
            str = sprintf('Time = %.0f\n %d nodes inside the sqare\n %d nodes outside the square',(start_selected_cut_index+timeIndexNo*DECIMATION_AFTER_FILT_FACTOR)*winc_sec,nodeNo-nodesOutsideSquare,nodesOutsideSquare);
        else
            str = sprintf('%d nodes inside the sqare\n %d nodes outside the square',nodeNo-nodesOutsideSquare,nodesOutsideSquare);
        end
        h = subplot(1,1,1);
        text(-squareDim+squareDim*0.1,squareDim-squareDim*0.2,str,'FontSize',10,'FontWeight','bold');
        axis([-squareDim squareDim -squareDim squareDim]);
        set(h, 'Position', [0.04 0.08 0.92 0.92]);
        
        drawnow
        frame = getframe(211);
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
