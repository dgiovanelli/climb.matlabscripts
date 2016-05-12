function output = timeBasedSlidingAvg(t, signal, wsize, winc) %t, wsize, and winc must have the same unit
    
    t = t-t(1);
    output = double.empty;
    actT = t(1);
    while(actT < max(t))
        output = cat(1, output, mean( signal( t<actT+wsize & t>actT ))); 
        actT = actT + winc;
    end

end