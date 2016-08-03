clear all;
close all;
%clc;

FOCUS_ID_1 = 0;
FOCUS_ID_2 = 0;
IDs_TO_CONSIDER = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]; % set this to empty to select all IDs
%IDs_TO_CONSIDER = [4, 5, 171, 172, 173];
if isempty(IDs_TO_CONSIDER) 
    AMOUNT_OF_NODE = 30;
else
    AMOUNT_OF_NODE = length(IDs_TO_CONSIDER);
end
ANDROID = 1; %set this to 1 if the log has been performed with the android app
SHOW_BATTERY_VOLTAGE = 0; %if this is set to 1 the battery voltage info are plotted (and the packet counter info are discarded)
PLOT_NODE_LABELS = 1; %setting this to 1 node labels are removed from plot, and the master node is plotted in red
CENTER_ON_ID = 1; %the plot will be centered on this node. Set to zero to free layouts
LAYOUT_ALGORITHM = 2; %select the algorithm to use ( 0 -> neato, 1 -> MDS, 2 -> Mesh relaxation
wsize_sec = 15;
winc_sec = 10;
F_filt = 0; %filter cut off frequency [Hz]. Set this to 0 to disable filtering.
n_filt = 2;
TREAT_AS_STATIC = 1; %when this is set to 1 the link length signals are averaged over the whole test (ignoring Infs)

% RSSI to m conversion parameters
k_TF_1= [-16.0845];
txPwr_10m_1 = -57.9715;

%filename = 'D:\Drive\E3DA Shared\Tirocini&Tesi\Stage Superiori giu-2016\CLIMB\LOGS\TEST_MUSE_2016_6_16\DATA\log_168_11.13.26.txt';
filename = 'D:\Drive\CLIMB\WIRELESS\LOG\LOCALIZATION\MUSE_02_08_2016\LOGS\log_215_11.37.0.txt';

delimiter = ' ';
CHECK_FOR_NOT_INCREMENTED_COUNTER = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

acquire_data;

battery_counter_check;

resample_data;

dBm_to_m_conversion;

%link_reconstruction;

apply_lp_filter;

calculate_link_reliability;

layout_nodes;

plot_nodes_layout;

save last_run;



