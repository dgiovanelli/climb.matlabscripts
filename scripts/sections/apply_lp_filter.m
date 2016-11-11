%FILTERING: TO CHECK, RECREATE SAMPLES IF MISSING, IT IS WRONG TO SET IT TO
%250 METERS
if TREAT_AS_STATIC == 1
    GRAPH_EDGES_M_FILT = GRAPH_EDGES_M;
    for i_link=1:size(GRAPH_EDGES_M,2)
        GRAPH_EDGES_M_FILT(:,i_link) = ones(size(GRAPH_EDGES_M_FILT,1),1).*mean(GRAPH_EDGES_M(GRAPH_EDGES_M(:,i_link) ~= Inf & ~isnan(GRAPH_EDGES_M(:,i_link)) , i_link));
    end
else
    if F_FILT_HZ ~= 0
        fs = 1/(2*W_INCR_S);
        [b,a] = butter(N_FILT,F_FILT_HZ / fs,'low');  %create filter
        infs_indexes = find(GRAPH_EDGES_M_REC == Inf);
        nans_indexes = isnan(GRAPH_EDGES_M_REC);
        GRAPH_EDGES_M_REC(infs_indexes) = 150; %This sets the maximum edge length (used for filtering) to 300 meters, if this is removed the filter output could be NaN. To see this simply remove this line and look the differences between GRAPH_EDGES_M_FILT and GRAPH_EDGES_M
        GRAPH_EDGES_M_REC(nans_indexes) = 150;
        GRAPH_EDGES_M_FILT = filter(b,a,GRAPH_EDGES_M_REC); %apply the filter
        GRAPH_EDGES_M_FILT(infs_indexes) = Inf; %Restore Infs to avoid introducing errors due to edge length underestimation
        GRAPH_EDGES_M_FILT(nans_indexes) = NaN; % This avoid NaNs that can be problematic during energy count, NOTE: if the link recostruction uses fillgaps function, no nan should be present
        if PLOT_VERBOSITY > 1
            figure
            plot(unixToMatlabTime(T_TAG),zeros(size(T_TAG)),'ro', unixToMatlabTime(T_TICKS), GRAPH_EDGES_M_REC);
            datetick('x',DATE_FORMAT);
            figure
            plot(unixToMatlabTime(T_TAG),zeros(size(T_TAG)),'ro', unixToMatlabTime(T_TICKS), GRAPH_EDGES_M_FILT);
            datetick('x',DATE_FORMAT);
        end
    else
        GRAPH_EDGES_M_FILT = GRAPH_EDGES_M_REC;
    end
end

i = find((LINKS(1,:) == FOCUS_ID_1) & (LINKS(2,:) == FOCUS_ID_2) | (LINKS(1,:) == FOCUS_ID_2) & (LINKS(2,:) == FOCUS_ID_1));
if size(i,2) == 1
    figure;
    plot(unixToMatlabTime(T_TICKS),GRAPH_EDGES_M_FILT(:,i))
    grid on;
    title('Distance between two nodes under focus');
    datetick('x',DATE_FORMAT);
    legend('signal after: merge, link reconstruction and low pass filtering');
else
    if size(i,2) > 1
        warning('the same link is inserted twice! check LINKS');
    end
end
