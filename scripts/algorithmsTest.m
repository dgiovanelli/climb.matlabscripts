close all;
clear all;

%% INITIALIZATION
FOCUS_ID_1 = 0;
FOCUS_ID_2 = 0;
PLOT_NODE_LABELS = 1;
LAYOUT_ALGORITHM = 2;
CENTER_ON_ID = 100;
NOISE_AMPL = 2;

firstNodeId = 100;
duration_s = 10;
Ts = 0.2;
t = 0:Ts:duration_s;

%% GENERATE DATA
generateSampleData

%% ADD NOISE
noise = rand(size(graphEdeges_m_filt)) * NOISE_AMPL - NOISE_AMPL/2;
graphEdeges_m_filt = graphEdeges_m_filt + noise;

%% PROCESS GENERATED DATA
processSampleData

%% ERROR CALCULATION
calculateError