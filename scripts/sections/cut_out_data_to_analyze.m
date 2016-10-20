if TREAT_AS_STATIC == 0
    h = figure(200);
    if exist('T_TAG','var')
        plot(T_TAG*TICK_DURATION,zeros(size(T_TAG)),'ro', t_w*TICK_DURATION, graphEdeges_m);
    else
        plot(t_w*TICK_DURATION, graphEdeges_m);
    end
    set(get(h,'Children'),'HitTest','off');
    xlabel('Time [s]');
    ylabel('distance [m]');
    legend('TAGs','distance');
    title('All links');
    grid on;
    hold off;
    
    fprintf('Click on the analysis bounds!\n');
    [x1,~] = ginput(1);
    [x2,~] = ginput(1);
%     x1 = 20;
%     x2 = 40;
    if x1 > x2
        xstop = x1/TICK_DURATION;
        xstart = x2/TICK_DURATION;
    else
        xstop = x2/TICK_DURATION;
        xstart = x1/TICK_DURATION;
    end
    
    tmp = abs(t_w - xstart);
    [ ~ , start_selected_cut_index] = min(tmp);
    tmp = abs(t_w - xstop);
    [ ~ , stop_selected_cut_index] = min(tmp);
    
    graphEdeges_m = graphEdeges_m(start_selected_cut_index:stop_selected_cut_index,:);
    t_w = t_w(start_selected_cut_index:stop_selected_cut_index);
else
    start_selected_cut_index = 1;
    stop_selected_cut_index = 1;
end
