function fbgTrainImgs=train_GSRC(fbgTrainImgs)
for i = 1 : size(fbgTrainImgs,2)
    fbgTrainImgs(:,i) = fbgTrainImgs(:,i) / norm(fbgTrainImgs(:,i));
end