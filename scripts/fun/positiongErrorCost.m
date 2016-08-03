function El = positiongErrorCost( A, XY_groundTruth, XY_layout )

El = 0;
nodesAmount = size(XY_groundTruth,1);
for nodeNo = 1:(nodesAmount)
        XY_diff = ((XY_groundTruth(nodeNo,2:3)' - A*XY_layout(nodeNo,2:3)'));
        dist = sqrt(XY_diff(1)^2 + XY_diff(2)^2);
        El = El + dist;
end
El = El/nodesAmount;

end