function X=my_normalized(X)
Nway = size(X);
for i=1:Nway(3)
    X(:,:,i) = X(:,:,i)/max(max(X(:,:,i)));
end
end


% Nway = size(X);
% for i=1:Nway(3)
%     X(:,:,i) = (X(:,:,i)-min(min(X(:,:,i))))/(max(max(X(:,:,i)))-min(min(X(:,:,i))));
% end
% end