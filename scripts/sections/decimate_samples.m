%DECIMATION AFTER LP_FILTERING
graph_edeges_m_filt_dec = GRAPH_EDGES_M_FILT(1:DECIMATION_AFTER_FILT_FACTOR:end,:);
t_w_dec = T_TICKS(1:DECIMATION_AFTER_FILT_FACTOR:end);

if PLOT_VERBOSITY > 1
    figure
    plot(unixToMatlabTime(T_TAG),zeros(size(T_TAG)),'ro', unixToMatlabTime(T_TICKS), GRAPH_EDGES_M_FILT);
    datetick('x',DATE_FORMAT);
    figure
    plot(unixToMatlabTime(T_TAG),zeros(size(T_TAG)),'ro', unixToMatlabTime(t_w_dec), graph_edeges_m_filt_dec);
    datetick('x',DATE_FORMAT);
end

GRAPH_EDGES_M_FILT = graph_edeges_m_filt_dec;
T_TICKS = t_w_dec;