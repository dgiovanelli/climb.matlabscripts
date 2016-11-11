% clear all;
% close all;
% clc;

FOCUS_ID_1 = 0;
FOCUS_ID_2 = 0;

IDs_TO_CONSIDER = [];%[225,226,227,228,229,231,232,233];% 1:1:20;
if isempty(IDs_TO_CONSIDER) 
    AMOUNT_OF_NODE = 30;
else
    AMOUNT_OF_NODE = length(IDs_TO_CONSIDER);
end
ANDROID = 1; %set this to 1 if the log has been performed with the android app
SHOW_BATTERY_VOLTAGE = 0; %if this is set to 1 the battery voltage info are plotted (and the packet counter info are discarded)
PLOT_NODE_LABELS = 0; %setting this to 1 node labels are removed from plot, and the master node is plotted in red
CENTER_ON_ID = 0; %the plot will be centered on this node. Set to zero to free layouts
LAYOUT_ALGORITHM = 2; %select the algorithm to use ( 0 -> neato, 1 -> MDS, 2 -> Mesh relaxation
W_SIZE_S = 5;
W_INCR_S = 1; %%ATTENZIONE: cambiando questo parametro da 0.5 a 1 ci sono delle traslazioni importanti dei segnali (test su file 'F:\GDrive\E3DA Shared\Tirocini&Tesi\Stage Superiori giu-2016\CLIMB\LOGS\TEST_MUSE_2016_6_16\DATA\log_168_11.50.30.txt';) 
F_FILT_HZ = 0; %filter cut off frequency [Hz]. Set this to 0 to disable filtering.
N_FILT = 1;
TREAT_AS_STATIC = 0; %when this is set to 1 the link length signals are averaged over the whole test (ignoring Infs)
SQUARE_SIZE_M = 60;   %plot square dimentions (meters)
ENABLE_FREE_TRANSFORMATION = 0; %if this is set to 0, the tranformation to allign estimated positions with the ground truth is rotation+reflection+traslation otherwise also the scaling is done
ENABLE_HIGH_PRECISION_ON_MESH_RELAXATION = 0; % when this is set to 0 the 'second' phase in mesh relaxation is skipped
ENABLE_LINK_RECONSTRUCTION = 0;
DECIMATION_AFTER_FILT_FACTOR = 1;
NETWORK_DELAY_COMPENSATION_MS = 1000; %this take into account the network latency due to TI ble stack (adv packet update latency). Set it to 0 to disable
GIF_SPEEDUP = 1;
PLOT_VERBOSITY = 1;
ENABLE_SMARTPHONE_RSSI = 0;
if PLOT_VERBOSITY > 2
    warning('ATTENTION: setting PLOT_VERBOSITY > 2 could lead to large number of plots if dealing with large networks');
end
% RSSI to m conversion parameters
k_TF_1= [-21.4014];%[-15.0339]; %[22]
txPwr_10m_1 = -67.3450;%-61.8643;

%filename = 'C:\Users\giova\Downloads\5187f1cf-a6f0-4e4a-a025-cb2fe52a1061_log_316_7.39.9.txt';
filename = 'F:\GDrive\CLIMB\WIRELESS\LOG\LOCALIZATION\MUSE_08_11_2016\LOGS\log_313_17.31.15.txt';
%filename = 'F:\GDrive\CLIMB\WIRELESS\LOG\TEMP\log_315_18.10.30.txt';

delimiter = ' ';
CHECK_FOR_NOT_INCREMENTED_COUNTER = 1;
DATE_FORMAT = 'HH:MM:SS';
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
if exist('GRAPH_EDGES_M_GT','var')
    calculateError;
    processError;
    plot_tajectory;
end

smooth_tracking_kalman;

save last_run;



