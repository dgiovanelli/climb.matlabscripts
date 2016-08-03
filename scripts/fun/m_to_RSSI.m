% function RSSI = m_to_RSSI( meters, k_TF)
% 
%     RSSI = ((meters/k_TF(1)-k_TF(3)).^(1/k_TF(2))) .* k_TF(4);
% 
% end
function RSSI = m_to_RSSI( meters, k_TF,txPwr_10m)

    RSSI =  txPwr_10m+1.2*k_TF(1)*log10(meters/10);%((meters/k_TF(1)-k_TF(3)).^(1/k_TF(2))) .* k_TF(4);%RSSI = ((meters/k_TF(1)-k_TF(3)).^(1/k_TF(2))) .* k_TF(4);

end