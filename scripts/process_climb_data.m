%clear all;
%close all;
%clc;

FOCUS_ID_1 = 0;
FOCUS_ID_2 = 0;
%IDs_TO_CONSIDER = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]; % set this to empty to select all IDs
IDs_TO_CONSIDER = [];%1:1:22;
if isempty(IDs_TO_CONSIDER) 
    AMOUNT_OF_NODE = 30;
else
    AMOUNT_OF_NODE = length(IDs_TO_CONSIDER);
end
ANDROID = 1; %set this to 1 if the log has been performed with the android app
SHOW_BATTERY_VOLTAGE = 0; %if this is set to 1 the battery voltage info are plotted (and the packet counter info are discarded)
PLOT_NODE_LABELS = 0; %setting this to 1 node labels are removed from plot, and the master node is plotted in red
CENTER_ON_ID = 9; %the plot will be centered on this node. Set to zero to free layouts
LAYOUT_ALGORITHM = 2; %select the algorithm to use ( 0 -> neato, 1 -> MDS, 2 -> Mesh relaxation
wsize_sec = 7;
winc_sec = 2;
F_filt = 0; %filter cut off frequency [Hz]. Set this to 0 to disable filtering.
n_filt = 2;
TREAT_AS_STATIC = 0; %when this is set to 1 the link length signals are averaged over the whole test (ignoring Infs)
SQUARE_SIZE_M = 200;   %plot square dimentions (meters)
ENABLE_FREE_TRANSFORMATION = 0; %if this is set to 0, the tranformation to allign estimated positions with the ground truth is rotation+reflection+traslation otherwise also the scaling is done
ENABLE_HIGH_PRECISION_ON_MESH_RELAXATION = 1; % when this is set to 0 the 'second' phase in mesh relaxation is skipped

PLOT_VERBOSITY = 3;
ENABLE_LINK_RECONSTRUCTION = 0;
DECIMATION_AFTER_FILT_FACTOR = 10;
GIF_SPEEDUP = 5;
PLOT_VERBOSITY = 2;
if PLOT_VERBOSITY > 2
    warning('ATTENTION: setting PLOT_VERBOSITY > 2 could lead to large number of plots if dealing with large networks');
end
% RSSI to m conversion parameters
k_TF_1= [-21.4013];%[-15.0339]; %[22]
txPwr_10m_1 = -67.3449;%-61.8643;

filename = 'D:\Drive\CLIMB\WIRELESS\LOG\TEST_FBK\LOGS\19_02_16\log_50_10.49.29.txt';
%filename = 'D:\Drive\CLIMB\WIRELESS\LOG\LOCALIZATION\MUSE_02_08_2016\LOGS\log_215_11.37.0_CUT.txt';

delimiter = ' ';
CHECK_FOR_NOT_INCREMENTED_COUNTER = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

acquire_data;

battery_counter_check;

resample_data;

dBm_to_m_conversion; %cosa succede se questo viene messo prima di resample_data???? PROVARE!!

cut_out_data_to_analyze;

link_reconstruction; % non importantissima per il papero

apply_lp_filter;

decimate_samples;

calculate_link_reliability;

layout_nodes;

recalculate_distance_matrix;

clustering_nodes;

plot_nodes_layout;

%% ERROR CALCULATION
if exist('graphEdeges_m_GroundTh','var')
    calculateError;
    processError;
end

smooth_tracking_kalman;

save last_run;



