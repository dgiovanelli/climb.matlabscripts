%% PLOTTING AND EXPORTING NODES TRAJECTORY
% NOTE: for now it can be applied only on nodePositionXY_transform since if there is a rotation during the layout the trajectory has no meaning
if PLOT_VERBOSITY > 0
    figure(34)
    for nodeNo = 1:size(nodePositionXY_transform,1)
        if nodeNo == size(nodePositionXY_transform,1)
            style = '-o';
            plot(permute(nodePositionXY_transform(nodeNo,2,error_calculation_startSample:end),[1,3,2]),permute(nodePositionXY_transform(nodeNo,3,error_calculation_startSample:end),[1,3,2]), style)
        else
            style = '.';
            plot(permute(nodePositionXY_transform(nodeNo,2,error_calculation_startSample:end),[1,3,2]),permute(nodePositionXY_transform(nodeNo,3,error_calculation_startSample:end),[1,3,2]), style)
        end
        axis([-squareDim squareDim -squareDim squareDim]);
        hold on;
    end
    hold off;
    figure(34)
    hold on;
    for nodeNo = 1:size(nodePositionXY_GroundTh,1)
        if nodeNo == size(nodePositionXY_transform,1)
            style = '-o';
        else
            style = 'x';
        end
        plot(permute(nodePositionXY_GroundTh(nodeNo,2,error_calculation_startSample:end),[1,3,2]),permute(nodePositionXY_GroundTh(nodeNo,3,error_calculation_startSample:end),[1,3,2]), style)
        axis([-squareDim squareDim -squareDim squareDim]);
        hold on;
    end
    grid on;
end

hold off;