%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Face Recognition Evaluator -> test_ica2.m: Tests ICA (Independent
% Component Analysis) using Bartlett's Architecture II.
%
% This is usually called during a fbRun, and a number of variables are
% already loaded and ready. See test_pca.m for more details
%
% M. S. Bartlett, J. R. Movellan, and T. J. Sejnowski, "Face Recognition by
% Independent Component Analysis," IEEE Transactions on Neural Networks,
% vol. 13, pp. 1450-1464, 2002. 
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

% Subtract out mean face
for i = 1:size(fbgTestImgs,2)
	fbgTestImgs(:,i) = fbgTestImgs(:,i) - fbgAvgFace;
end

fbgTestImgs = fbgTestImgs';
Rtest = fbgTestImgs*V;

% Subtract mean from representation
rmean = mean(Rtest, 2);
for i = 1:size(Rtest,2)
	Rtest(:,i) = Rtest(:,i) - rmean;
end

%Ftest = Rtest * inv(w*wz);
Ftest = (w * wz * zeroMn(Rtest'))';

% We've already discarded the top eigenvectors
trainWeights = F';%(:,discardTopEigs+1:end)';
testWeights = Ftest';%(:,discardTopEigs+1:end)';

% Recognize IDs using nearest neighbor between testWeights and trainWeights
classify_nearest;

% This code is for a cos distance, vectorized which means too memory
% intensive for very large datasets
%pc = nnClassFn(trainWeights,testWeights,trainClass,fbgTestIds')*100
%fbgAccuracy = 100*pc;

if resetNumVectors, clear numVectors; end
if resetEigWeights, clear discardTopEigs; end