% Normalize the columns of A to have unit l^2-norm.
for i = 1 : size(fbgTrainImgs,2)
    fbgTrainImgs(:,i) = fbgTrainImgs(:,i) / norm(fbgTrainImgs(:,i));
end