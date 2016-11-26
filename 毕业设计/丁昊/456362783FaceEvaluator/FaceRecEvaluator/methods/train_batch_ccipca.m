%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Face Recognition Evaluator -> train_batch_ccipca.m: Trains the original
% 'eigenface' method using Incremental Principle Component Analysis
% (IPCA). Specifically, the Candid Covariance-Free IPCA method, for which
% Matlab code is available. IPCA trains one image at a time, but depends on
% the mean face being subtracted out first. Thus, this particular
% implementation is a batch mode implementation because we depend on
% knowing all the training images to calculate the mean image. However, the
% running time and memory requirements can be less with this method.
%
% This is usually called during a fbRun, and a number of variables are
% already loaded and ready. See train_pca.m for more details.
%
% Uses CCIPCA code from: www.cse.msu.edu/~weng/research/
%
% J. Weng, Y. Zhang, and W. S. Hwang, "Candid Covariance-Free Incremental
% Principal Component Analysis," IEEE TPAMI, vol. 25, pp. 1034-1040, 2003.
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

resetNumVectors = 0;
resetEigWeights = 0;

if ~exist('numVectors', 'var')
	numVectors = 100;
	resetNumVectors = 1;
end
if ~exist('eigWeights', 'var')
	eigWeights(1:numVectors) = 1;
	eigWeights(1:10) = 0; % Ignore first 10 eigenfaces
	resetEigWeights = 1;
end

% Batch code: This does CCIPCA on all the images
for i = 1:size(fbgTrainImgs,2);
	fbgTrainImgs(:,i) = fbgTrainImgs(:,i) - fbgAvgFace;
end
[v,d,n]=ccipca(fbgTrainImgs, numVectors);

% Apply weights to the eigenvalues
if exist('eigWeights')
    for i = 1:numVectors
        v(:,i) = v(:,i)*eigWeights(i);
    end
end

trainWeights = v'*fbgTrainImgs;

% This is the data we need to perform recognition (during testing phase)
fbgTrainMem{1} = v;
fbgTrainMem{2} = fbgTrainIds;
fbgTrainMem{3} = trainWeights;
fbgTrainMem{4} = fbgAvgFace;