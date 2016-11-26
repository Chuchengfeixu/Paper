for i = 1:size(fbgTestImgs,2)
	fbgTestImgs(:,i) = fbgTestImgs(:,i) - avgFace;
end

testWeights = v'*fbgTestImgs;

classify_nearest;

