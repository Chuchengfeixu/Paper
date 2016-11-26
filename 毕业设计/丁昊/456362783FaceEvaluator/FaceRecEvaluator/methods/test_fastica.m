%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Face Recognition Evaluator -> train_fastica.m: Runs ICA (Independent
% Component Analysis) using FastICA. 
%
% NOTE: This algorithm is not fully working! Behavior not optimal yet. You
% have been warned.
%
% This is usually called during a fbRun, and a number of variables are
% already loaded and ready. See test_pca.m for more details
%
% Uses code from: http://www.cis.hut.fi/projects/ica/fastica/
%
% A. Hyvärinen. Fast and Robust Fixed-Point Algorithms for Independent
% Component Analysis. IEEE Transactions on Neural Networks 10(3):626-634,
% 1999. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Authors:                           Brian C. Becker @ www.BrianCBecker.com
% Copyright (c) 2007-2008          Enrique G. Ortiz @ www.EnriqueGOrtiz.com
%
% License: You are free to use this code for academic and non-commercial
% use, provided you reference the following paper in your work.
%
% Becker, B.C., Ortiz, E.G., "Evaluation of Face Recognition Techniques for 
% Application to Facebook," in Proceedings of the 8th IEEE International
% Automatic Face and Gesture Recognition Conference, 2008.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:size(fbgTestImgs,2)
	fbgTestImgs(:,i) = fbgTestImgs(:,i) - fbgAvgFace;
end

testWeights = v'*fbgTestImgs;
testlen = size(testWeights,2);
trainlen = size(trainWeights,2);
index = zeros(testlen,1);
x2 = sum(testWeights.^2)';
y2 = sum(trainWeights.^2);
for i = 1:testlen
    z = testWeights(:,i)'*trainWeights;
    z = repmat(x2(i),1,trainlen) + y2 - 2*z;
    [C, index(i)] = min(z);
end

% Store the number of correct
correct = find(fbgTrainIds(index) - fbgTestIds == 0);
fbgAccuracy = 100* size(correct,1) / size(fbgTestIds,1);

if resetNumVectors, clear numVectors; end
if resetEigWeights, clear eigWeights; end


return;



for i = 1:size(fbgTestImgs,2)
	fbgTestImgs(:,i) = fbgTestImgs(:,i) - fbgAvgFace;
end

fbgTestImgs = fbgTestImgs';
Rtest = fbgTestImgs*V;
Ftest = Rtest * inv(w*wz);

trainWeights = F(:,discardTopEigs+1:end)';
testWeights = Ftest(:,discardTopEigs+1:end)';

testlen = size(testWeights,2);
trainlen = size(trainWeights,2);
index = zeros(testlen,1);
x2 = sum(testWeights.^2)';
y2 = sum(trainWeights.^2);
for i = 1:testlen
    z = testWeights(:,i)'*trainWeights;
    z = repmat(x2(i),1,trainlen) + y2 - 2*z;
    [C, index(i)] = min(z);
end

% Store the number of correct
correct = find(fbgTrainIds(index) - fbgTestIds == 0);
fbgAccuracy = 100* size(correct,1) / size(fbgTestIds,1);

%pc = nnClassFn(trainWeights,testWeights,trainClass,fbgTestIds')*100
%fbgAccuracy = 100*pc;

if resetNumVectors, clear numVectors; end
if resetEigWeights, clear discardTopEigs; end