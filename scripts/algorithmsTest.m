close all;
clear all;

%% INITIALIZATION
FOCUS_ID_1 = 0;
FOCUS_ID_2 = 0;
PLOT_NODE_LABELS = 0;
LAYOUT_ALGORITHM = 2;
CENTER_ON_ID = 100;
NOISE_AMPL_dBm = 8;
F_filt = 0; %filter cut off frequency [Hz]. Set this to 0 to disable filtering.
n_filt = 2;
TREAT_AS_STATIC = 0; %when this is set to 1 the link length signals are averaged over the whole test (ignoring Infs)

SQUARE_SIZE_M = 40;   %plot square dimentions (meters)
k_TF_1= [-16.0845];
txPwr_10m_1 = -57.9715;

warning('off','optim:fminunc:SwitchingMethod');

firstNodeId = 100;
duration_s = 1;
Ts = 0.1;
t_w = 0:Ts:duration_s;

winc_sec = Ts;
%% GENERATE DATA
generateSampleData
save last_Generated_Data
%% ADD NOISE
noise_dBm = rand(size(graphEdeges_m)) * NOISE_AMPL_dBm - NOISE_AMPL_dBm/2;
graphEdeges_RSSI_filt = m_to_RSSI(graphEdeges_m,k_TF_1,txPwr_10m_1);   
graphEdeges_m_filt = RSSI_to_m(graphEdeges_RSSI_filt+noise_dBm,k_TF_1,txPwr_10m_1); %noise is in dBm

%apply_lp_filter;

calculate_link_reliability;

layout_nodes;

plot_nodes_layout;


%% ERROR CALCULATION
calculateError