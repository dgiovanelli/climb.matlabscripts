% function m_signal = RSSI_to_m( RSSI_SIGNAL, k_TF )
% 
% %k_TF = [0.5567    8.9384    0.7404  -21.919];%old parameters (use only some RSSI data) [1.4695    6.8996   -0.4064];
% %txPwr_1m = -48.2351;
% 
% m_signal = k_TF(1) * (RSSI_SIGNAL./k_TF(4)).^k_TF(2) + k_TF(3);
% 
% %m_signal(ISNAN(RSSI_SIGNAL)) = Inf;
% 
% end
function m_signal = RSSI_to_m( RSSI_SIGNAL, k_TF, txPwr_10m )

%k_TF = [0.5567    8.9384    0.7404];%old parameters (use only some RSSI data) [1.4695    6.8996   -0.4064];
%txPwr_1m = -48.2351;

m_signal = 10*10.^((RSSI_SIGNAL-txPwr_10m)/(k_TF(1)));%k_TF(1) * (RSSI_SIGNAL./txPwr_1m).^k_TF(2) + k_TF(3);
%m_signal(m_signal > 100) = NaN;
%m_signal(ISNAN(RSSI_SIGNAL)) = Inf;

end