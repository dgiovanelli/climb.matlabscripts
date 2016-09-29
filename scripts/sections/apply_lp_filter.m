%FILTERING: TO CHECK, RECREATE SAMPLES IF MISSING, IT IS WRONG TO SET IT TO
%250 METERS
if TREAT_AS_STATIC == 1
    graphEdeges_m_filt = graphEdeges_m;
    for i_link=1:size(graphEdeges_m,2)
        graphEdeges_m_filt(:,i_link) = ones(size(graphEdeges_m_filt,1),1).*mean(graphEdeges_m(graphEdeges_m(:,i_link) ~= Inf & ~isnan(graphEdeges_m(:,i_link)) , i_link));
    end
else
    if F_filt ~= 0
        fs = 1/(2*winc_sec);
        [b,a] = butter(n_filt,F_filt / fs,'low');  %create filter
        graphEdeges_m(graphEdeges_m == Inf) = 300; %This sets the maximum edge length (used for filtering) to 300 meters, if this is removed the filter output could be NaN. To see this simply remove this line and look the differences between graphEdeges_m_filt and graphEdeges_m
        graphEdeges_m(isnan(graphEdeges_m)) = 300;
        graphEdeges_m_filt = filter(b,a,graphEdeges_m); %apply the filter
        graphEdeges_m_filt(graphEdeges_m == Inf) = Inf; %Restore Infs to avoid introducing errors due to edge length underestimation
        graphEdeges_m_filt(isnan(graphEdeges_m)) = Inf; % This avoid NaNs that can be problematic during energy count
        if PLOT_VERBOSITY > 1
            figure
            plot(T_TAG*TICK_DURATION,zeros(size(T_TAG)),'ro', t_w*TICK_DURATION, graphEdeges_m_rec);
            figure
            plot(T_TAG*TICK_DURATION,zeros(size(T_TAG)),'ro', t_w*TICK_DURATION, graphEdeges_m_filt);
        end
    else
        graphEdeges_m_filt = graphEdeges_m;
    end
end