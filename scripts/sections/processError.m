%ERRORS PLOT
if PLOT_VERBOSITY > 2
    t_plot = (ANALYSIS_START_INDEX+(error_calculation_startSample:1:size(link_length_mi_error,3)))*(W_INCR_S*DECIMATION_AFTER_FILT_FACTOR);
    figure(401);
    plot(t_plot, permute(max(link_length_mi_error(3,:,error_calculation_startSample:end)),[3,2,1]), 'b.', t_plot, permute(mean(link_length_mi_error(3,:,error_calculation_startSample:end)),[3,2,1]), 'g.', t_plot, permute(min(link_length_mi_error(3,:,error_calculation_startSample:end)),[3,2,1]), 'r.');
    grid on;
    title('Link length errors after localization [m]');
    xlabel('Time [s]');
    legend('max','mean', 'min');
    
    figure(402);
    plot(t_plot, permute(max(link_length_mi_error(4,:,error_calculation_startSample:end)),[3,2,1]), 'b.', t_plot, permute(mean(link_length_mi_error(4,:,error_calculation_startSample:end)),[3,2,1]), 'g.', t_plot, permute(min(link_length_mi_error(4,:,error_calculation_startSample:end)),[3,2,1]), 'r.');
    grid on;
    title('Link length errors after localization %');
    xlabel('Time [s]');
    legend('max','mean', 'min');
    
    figure(403);
    plot(t_plot, permute(max(link_length_mi_error(5,:,error_calculation_startSample:end)),[3,2,1]), 'b.', t_plot, permute(mean(link_length_mi_error(5,:,error_calculation_startSample:end)),[3,2,1]), 'g.', t_plot, permute(min(link_length_mi_error(5,:,error_calculation_startSample:end)),[3,2,1]), 'r.');
    grid on;
    title('Link length errors before localization [m]');
    xlabel('Time [s]');
    legend('max','mean', 'min');
    
    figure(404);
    plot(t_plot, permute(max(link_length_mi_error(6,:,error_calculation_startSample:end)),[3,2,1]), 'b.', t_plot, permute(mean(link_length_mi_error(6,:,error_calculation_startSample:end)),[3,2,1]), 'g.', t_plot, permute(min(link_length_mi_error(6,:,error_calculation_startSample:end)),[3,2,1]), 'r.');
    grid on;
    title('Link length errors before localization %');
    xlabel('Time [s]');
    legend('max','mean', 'min');
end
outlier_treshold = 100;

%%ERROR SNRQ
rmse_after_loc = zeros(1,size(link_length_mi_error,3)-error_calculation_startSample+1);
rmse_after_loc_percent = zeros(1,size(link_length_mi_error,3)-error_calculation_startSample+1);
for timeNo = error_calculation_startSample:size(link_length_mi_error,3)
    rmse_after_loc(timeNo-error_calculation_startSample+1) = sum(link_length_mi_error(3,:,timeNo).^2)/size(link_length_mi_error,2);
    rmse_after_loc_percent(timeNo-error_calculation_startSample+1) = sum(link_length_mi_error(4,:,timeNo).^2)/size(link_length_mi_error,2);
end
rmse_after_loc_no_outlier = rmse_after_loc(rmse_after_loc < outlier_treshold); %remove outlier
rmse_after_loc_no_outlier_percent =  rmse_after_loc_percent(rmse_after_loc < outlier_treshold); %remove outlier
if size(rmse_after_loc_no_outlier,2) < 0.9*size(rmse_after_loc,2)
    warning('More than 10% are marked as outlier!!!');
end
%%ERROR SNRQ
rmse_before_loc = zeros(1,size(link_length_mi_error,3)-error_calculation_startSample+1);
rmse_before_loc_percent = zeros(1,size(link_length_mi_error,3)-error_calculation_startSample+1);
for timeNo = error_calculation_startSample:size(link_length_mi_error,3)
    rmse_before_loc(timeNo-error_calculation_startSample+1) = sum(link_length_mi_error(5,:,timeNo).^2)/size(link_length_mi_error,2);
    rmse_before_loc_percent(timeNo-error_calculation_startSample+1) = sum(link_length_mi_error(6,:,timeNo).^2)/size(link_length_mi_error,2);
end
rmse_before_loc_no_outlier = rmse_before_loc(rmse_before_loc < outlier_treshold); %remove outlier
rmse_before_loc_no_outlier_percent = rmse_before_loc_percent(rmse_before_loc < outlier_treshold); %remove outlier
if size(rmse_before_loc_no_outlier,2) < 0.9*size(rmse_before_loc,2)
    warning('More than 10% are marked as outlier!!!');
end

if PLOT_VERBOSITY > 2
    figure(405);
    plot(t_plot, rmse_after_loc, 'r.',t_plot, rmse_before_loc, 'b.');
    %axis([min(t_plot); max(t_plot); 0; outlier_treshold])
    grid on;
    title('RMSE');
    legend('After localization','Before localization');
end

fprintf('Mean link length error after localization (averaged over the whole duration): %.2f m\n', mean(mean(link_length_mi_error(3,:,error_calculation_startSample:end))) );
fprintf('Mean link length error after localization (averaged over the whole duration): %.2f %%\n', mean(mean(link_length_mi_error(4,:,error_calculation_startSample:end)))*100 );
fprintf('Mean link length error before localization (averaged over the whole duration): %.2f m\n', mean(mean(link_length_mi_error(5,:,error_calculation_startSample:end))) );
fprintf('Mean link length error before localization (averaged over the whole duration): %.2f %%\n\n', mean(mean(link_length_mi_error(6,:,error_calculation_startSample:end)))*100 );
fprintf('RMSE after localization (averaged over the whole duration): %.2f m\n', mean(rmse_after_loc_no_outlier) );
fprintf('RMSE after localization (averaged over the whole duration): %.2f %%\n', mean(rmse_after_loc_no_outlier_percent)*100 );
fprintf('RMSE before localization (averaged over the whole duration): %.2f m\n', mean(rmse_before_loc_no_outlier));
fprintf('RMSE before localization (averaged over the whole duration): %.2f %%\n\n', mean(rmse_before_loc_no_outlier_percent)*100 );
fprintf('RMSE gain absolute (meters): %.2f\n', mean(rmse_before_loc_no_outlier)/mean(rmse_after_loc_no_outlier));
fprintf('RMSE gain relative (%%): %.2f\n\n', mean(rmse_before_loc_no_outlier_percent)/mean(rmse_after_loc_no_outlier_percent));