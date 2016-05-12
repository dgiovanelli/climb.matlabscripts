function new_MATRIX = addTimeSample( MATRIX )

%inf = 4294967295;

new_MATRIX = cat(3,MATRIX,-Inf*double(ones(size(MATRIX,1))));
new_MATRIX(:,1,end) = MATRIX(:,1,end);
new_MATRIX(1,:,end) = MATRIX(1,:,end);

% for index = 1:1:size(MATRIX,1)
%     new_MATRIX(index,index,end) = MATRIX(index,index,end);
% end

end


