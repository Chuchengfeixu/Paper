% Subtract out average face
for i = 1:size(fbgTestImgs,2)
	fbgTestImgs(:,i) = fbgTestImgs(:,i) - fbgAvgFace;
end

fbgTestImgs = fbgTestImgs';
Rtest = fbgTestImgs*V;
Ftest = Rtest * inv(w*wz);

% We have to do this otherwise the memory count is messed up. fbgTestImgs
% isn't counted towards the memory quota so if we overwrite it with
% something smaller we'll wind up with a negative memory usage
fbgTestImgs_old = fbgTestImgs;
fbgTestImgs_old(1,1) = 0;

fbgTestImgs = Ftest';

test_libsvm