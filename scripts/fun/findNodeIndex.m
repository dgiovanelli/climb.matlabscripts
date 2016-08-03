function index = findNodeIndex( MATRIX, ID )
    %inf = 4294967295;
    index = 2;
    while (index <= size(MATRIX,1)) && ( (MATRIX(index,1,1) ~= ID && MATRIX(index,1,1) ~= -Inf) )
        index = index + 1;
    end
    
end