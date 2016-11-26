%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Face Recognition Evaluator -> test_fastica.m: Runs ICA (Independent
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

resetNumVectors = 0;
resetEigWeights = 0;

if ~exist('numVectors', 'var')
	numVectors = 100;
	resetNumVectors = 1;
end
if ~exist('discardTopEigs', 'var')
	discardTopEigs = 10;
end

for i = 1:size(fbgTrainImgs,2)
	fbgTrainImgs(:,i) = fbgTrainImgs(:,i) - fbgAvgFace;
end

%v = princomp(fbgTrainImgs, 'econ');
%[U,SV,V] = svd(fbgTrainImgs,'econ');
%v = U(:,1:numVectors);

%[icasig, A, W] = fastica(fbgTrainImgs', 'pcaE', v, 'pcaD', SV);
[E, D] = FASTICA(fbgTrainImgs', 'only', 'pca');
%len = size(fbgTrainImgs,2);
%D = SV;%fliplr(flipud(SV));
%D = D(1:end-1, 1:end-1);
%E = U(len+1
%E = V;%fliplr(flipud(V));
[icasig, A, W] = fastica(fbgTrainImgs', 'verbose', 'off', 'displayMode', 'off', 'pcaE', E, 'pcaD', D);
v = icasig';
trainWeights = v'*fbgTrainImgs;

% This is the data we need to perform recognition (during testing phase)
fbgTrainMem{1} = v;
