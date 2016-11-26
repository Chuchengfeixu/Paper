%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Face Recognition Evaluator -> train_ccipca.m: Trains the original
% 'eigenface' method using Incremental Principle Component Analysis
% (IPCA). Specifically, the Candid Covariance-Free IPCA method, for which
% Matlab code is available. IPCA trains one image at a time, but depends on
% the mean face being subtracted out first. Thus, in this method, we
% subtract out the mean as we go, after doing a batch training on the first
% hundred or so images.
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

fbgCountImgMem = 0; % This is a purely incremental version

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

len = size(fbgTrainImgs,2);

% Incremental mode: Calculate average face as we go
%   - Do batch on the first numVectors images to get started
%   - Then process each of the faces incrementally
%avgFace = load('genavgface.mat');
%avgFace = avgFace.fbgAvgFace;
%avgFace = fbgAvgFace;
avgFace = fbgTrainImgs(:,1);
%avgFace = zeros(size(fbgAvgFace));
for i = 2:numVectors
	avgFace = ((i-1)/i)*avgFace + (1/i)*fbgTrainImgs(:,i);
end
for i = 1:numVectors
	fbgTrainImgs(:,i) = fbgTrainImgs(:,i) - avgFace;
end

% First numVectors we do batch
[v,d,n]=ccipca(fbgTrainImgs(:,1:numVectors), numVectors);

% Process the rest individually, updating average as we go
for i = numVectors+1:size(fbgTrainImgs,2)
	avgFace = ((i-1)/i)*avgFace + (1/i)*fbgTrainImgs(:,i);
	
	% Subtract incrementally updated mean and train
	fbgTrainImgs(:,i) = fbgTrainImgs(:,i) - avgFace;
	[v,d,n]=ccipca(fbgTrainImgs(:,i), numVectors, 1, v, n);
end

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
fbgTrainMem{4} = avgFace;