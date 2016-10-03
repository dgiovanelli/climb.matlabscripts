%DECIMATION AFTER LP_FILTERING
graphEdeges_m_filt_dec = graphEdeges_m_filt(1:DECIMATION_AFTER_FILT_FACTOR:end,:);
t_w_dec = t_w(1:DECIMATION_AFTER_FILT_FACTOR:end);

if PLOT_VERBOSITY > 1
    figure
    plot(T_TAG*TICK_DURATION,zeros(size(T_TAG)),'ro', t_w*TICK_DURATION, graphEdeges_m_filt);
    figure
    plot(T_TAG*TICK_DURATION,zeros(size(T_TAG)),'ro', t_w_dec*TICK_DURATION, graphEdeges_m_filt_dec);
end

graphEdeges_m_filt = graphEdeges_m_filt_dec;
t_w = t_w_dec;