function [ ID, STATE, RSSI ] = decomposeClimbGattPacket( packet )
ID = uint8.empty;
STATE = uint8.empty;
RSSI = uint8.empty;
for pos = 1:6:length(packet{1})-6
    if( sscanf(packet{1}(pos:pos+1),'%x') ~= 0 ) %estrai solo se l'ID è diverso da zero
        ID = cat(1,ID,sscanf(packet{1}(pos:pos+1),'%x'));
        STATE = cat(1,STATE,sscanf(packet{1}(pos+2:pos+3),'%x'));
        RSSI = cat(1,RSSI,sscanf(packet{1}(pos+4:pos+5),'%x'));
    end
end
RSSI = typecast(RSSI,'int8');