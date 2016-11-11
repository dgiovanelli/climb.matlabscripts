if TREAT_AS_STATIC == 0
    h = figure(200);
    if exist('T_TAG','var')
        plot(unixToMatlabTime(T_TAG),zeros(size(T_TAG)),'ro', unixToMatlabTime(T_TICKS), GRAPH_EDGES_M);
    else
        plot(unixToMatlabTime(T_TICKS), GRAPH_EDGES_M);
    end
    set(get(h,'Children'),'HitTest','off');
    xlabel('Time [s]');
    ylabel('distance [m]');
    legend('TAGs','distance');
    datetick('x',DATE_FORMAT);
    title('All LINKS');
    grid on;
    hold off;
    
    if 0
        fprintf('Click on the analysis bounds!\n');
        [x1,~] = ginput(1);
        [x2,~] = ginput(1);
        if x1 > x2
            xstop = matlabToUnixTime(x1);
            xstart = matlabToUnixTime(x2);
        else
            xstop = matlabToUnixTime(x2);
            xstart = matlabToUnixTime(x1);
        end
    else
        x1 = T_TAG(5);
        x2 = T_TAG(end);
        
        xstart = x1;
        xstop = x2;
    end
    
    tmp = abs(T_TICKS - xstart);
    [ ~ , ANALYSIS_START_INDEX] = min(tmp);
    tmp = abs(T_TICKS - xstop);
    [ ~ , ANALYSIS_STOP_INDEX] = min(tmp);
    
    GRAPH_EDGES_M = GRAPH_EDGES_M(ANALYSIS_START_INDEX:ANALYSIS_STOP_INDEX,:);
    T_TICKS = T_TICKS(ANALYSIS_START_INDEX:ANALYSIS_STOP_INDEX);
else
    ANALYSIS_START_INDEX = 1;
    ANALYSIS_STOP_INDEX = 1;
end
