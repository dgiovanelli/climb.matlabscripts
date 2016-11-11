close all;
clear all;

%% INITIALIZATION
FOCUS_ID_1 = 0;
FOCUS_ID_2 = 0;
PLOT_NODE_LABELS = 0;
LAYOUT_ALGORITHM = 2;
CENTER_ON_ID = 5;
NOISE_AMPL_dBm_PP = 16;
F_FILT_HZ = 0; %filter cut off frequency [Hz]. Set this to 0 to disable filtering.
N_FILT = 2;
TREAT_AS_STATIC = 0; %when this is set to 1 the link length signals are averaged over the whole test (ignoring Infs)
SQUARE_SIZE_M = 30;   %plot square dimentions (meters)
k_TF_1= [-21.4014];%[-15.0339]; %[22]
txPwr_10m_1 = -67.3450;%-61.8643;
ENABLE_FREE_TRANSFORMATION = 0; %if this is set to 0, the tranformation to allign estimated positions with the ground truth is rotation+reflection+traslation otherwise also the scaling is done
ENABLE_HIGH_PRECISION_ON_MESH_RELAXATION = 0; % when this is set to 0 the 'second' phase in mesh relaxation is skipped
ENABLE_LINK_RECONSTRUCTION = 0;
DECIMATION_AFTER_FILT_FACTOR = 1;
GIF_SPEEDUP = 1;
PLOT_VERBOSITY = 0;
if PLOT_VERBOSITY > 2
    warning('ATTENTION: setting PLOT_VERBOSITY > 2 could lead to large number of plots if dealing with large networks');
end
warning('off','optim:fminunc:SwitchingMethod');

firstNodeId = 1;
duration_s = 41;
Ts = 1;
T_TICKS = 0:Ts:duration_s-Ts;
W_INCR_S = Ts;

TICK_DURATION_S = Ts;
%% GENERATE DATA
generateSampleData
save last_Generated_Data

%cut_out_data_to_analyze;

%% ADD NOISE
noise_dBm = rand(size(GRAPH_EDGES_M)) * NOISE_AMPL_dBm_PP - NOISE_AMPL_dBm_PP/2;

graphEdeges_RSSI_filt = m_to_RSSI(GRAPH_EDGES_M,k_TF_1,txPwr_10m_1);   
GRAPH_EDGES_M_REC = RSSI_to_m(graphEdeges_RSSI_filt+noise_dBm,k_TF_1,txPwr_10m_1); %noise is in dBm

%%%%%%%%%%%%%%%%%%%link_reconstruction; % non importantissima per il papero, non funziona su algorithmsTest

apply_lp_filter;

decimate_samples;

calculate_link_reliability;

layout_nodes;

recalculate_distance_matrix;

clustering_nodes;

plot_nodes_layout;


%% ERROR CALCULATION
calculateError;

processError;