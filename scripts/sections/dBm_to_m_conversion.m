% NOTE: GRAPH_EDGES_RSSI is already filtered with sliding window
GRAPH_EDGES_M = RSSI_to_m(GRAPH_EDGES_RSSI,k_TF_1 , txPwr_10m_1);
GRAPH_EDGES_M(GRAPH_EDGES_RSSI == -Inf) = Inf;