function output = timeBasedTwoDirectionsMerge(t1, signal1,t2, signal2, wsize, winc) %t, wsize, and winc must have the same unit

if isempty( t1 ) || isempty( t2 )
    if isempty( t1 ) && isempty( t2 )
        output = []; %it should not reach here
        return
    else
        if isempty( t1 )
            ts =  min(t2);
            output = double.empty;
            actT = ts;
            while(actT <= max(t2) )
                %mean of the signal2, since signal1 is empty
                output = cat(1, output, mean2( signal2( t2<=actT+wsize & t2>=actT )));
                actT = actT + winc;
            end
        else %t2 is empty
            ts =  min(t1);
            output = double.empty;
            actT = ts;
            while(actT <= max(t1) )
                %mean of the signal2, since signal1 is empty
                output = cat(1, output, mean2( signal1( t1<=actT+wsize & t1>=actT )));
                actT = actT + winc;
            end
        end
    end
else
    ts = min([t1', t2']);
    output = double.empty;
    actT = ts;
    while(actT <= max( [t1', t2'] ))
        %mean of the two signals
        output = cat(1, output, mean2( [signal1( t1<=actT+wsize & t1>=actT )',signal2( t2<=actT+wsize & t2>=actT )' ] ));
        
        actT = actT + winc;
    end
end

end