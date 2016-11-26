for i = 1:size(fbgTestImgs,2)
	fbgTestImgs(:,i) = fbgTestImgs(:,i) - fbgAvgFace;
end

% Calculate the weights
if reduceDim
	testWeights = P0'*fbgTestImgs;
	testWeights = v'*testWeights;
else
	testWeights = v'*fbgTestImgs;
end

% We have to do this otherwise the memory count is messed up. fbgTestImgs
% isn't counted towards the memory quota so if we overwrite it with
% something smaller we'll wind up with a negative memory usage
fbgTestImgs_old = fbgTestImgs;
fbgTestImgs_old(1,1) = 0;

fbgTestImgs = testWeights;

test_libsvm