function El = positiongErrorCost_FreeTrans( A, XY_groundTruth, XY_layout )

El = 0;
nodesAmount = size(XY_groundTruth,1);
for nodeNo = 1:(nodesAmount)
        nodeNo_XY_layout = find(XY_layout(:,1) == XY_groundTruth(nodeNo,1));
        if size(nodeNo_XY_layout) == 1
            XY_diff = ((XY_groundTruth(nodeNo,2:3)' - (A(1:2,1:2)*XY_layout(nodeNo_XY_layout,2:3)' + A(3,:)')));
            dist = sqrt(XY_diff(1)^2 + XY_diff(2)^2);
            El = El + dist;
        else
            warning('size(nodeNo_XY_layout) ~= 1, the same Id is repeated more then once or it is not found');
        end
        
end
El = El/nodesAmount;

end