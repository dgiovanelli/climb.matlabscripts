function new_MATRIX = addIDtoMatrix( MATRIX, ID )
%inf = 4294967295;

new_MATRIX = double(ones(size(MATRIX,1)+1,size(MATRIX,2)+1,size(MATRIX,3)))*(-Inf);
new_MATRIX(1:size(MATRIX,1),1:size(MATRIX,1),:) = MATRIX;
new_MATRIX(1,size(new_MATRIX,1),:) = ID * double(ones(size(MATRIX,3),1))';
new_MATRIX(size(new_MATRIX,1),1,:) = ID * double(ones(size(MATRIX,3),1));

end