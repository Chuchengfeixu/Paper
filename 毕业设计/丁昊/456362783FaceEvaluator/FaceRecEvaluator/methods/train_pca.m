%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Face Recognition Evaluator -> train_pca.m: Trains the original
% 'eigenface' method using Principle Component Analysis (PCA). PCA usually
% involves calculating the covariance matrix, which is extremely large if
% training on a lot of images, so we get around that by using SVD (singular
% value decomposition) instead. 100 eigenfaces (eigenvectors) are used,
% and the top 10 are set to zero (ignored). It is often good to discard
% (ignore) the top eigenfaces because they encode illumination variations.
% This is often not true for small or consistently illuminated datasets.
% These parameters (numVectors  and eigWeights) can be varied for different
% recognition accuracy rates. For instance, try commenting out line 48.
%
% This is usually called during a fbRun, and a number of variables are
% already loaded and ready:
%  - fbgTrainImgs: The training images, arranged in columns.
%  - fbgTrainIds: The IDs of the training images (identity of faces)
%  - fbgAverageFace: The mean face of all the training images
%  - fbgRows/fbgCols: The size of images trained on
%  - fbgTrainMem: Store any training memory necessary to do recognition
%    here in cell arrays
%
% M. A. Turk and A. P. Pentland, "Face Recognition Using Eigenfaces," in
% IEEE CVPR), 1991, pp. 586-591.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Authors:                           Brian C. Becker @ www.BrianCBecker.com
% Copyright (c) 2007-2008          Enrique G. Ortiz @ www.EnriqueGOrtiz.com
%
% License: You are free to use this code for academic and non-commercial
% use, provided you reference the following paper in your work.
%
% Becker, B.C., Ortiz, E.G., "Evaluation of Face Recognition Techniques for 
%   Application to Facebook," in Proceedings of the 8th IEEE International
%   Automatic Face and Gesture Recognition Conference, 2008.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% If you want to set these values before each run you can and we won't
% overwrite them
resetNumVectors = 0;
resetEigWeights = 0;

% By default use 100 eigenvectors (eigenfaces)
if ~exist('numVectors', 'var')
	numVectors = 100;
	resetNumVectors = 1;
end

% Ignore the first 10 eigenfaces
if ~exist('eigWeights', 'var')
	eigWeights(1:numVectors) = 1;
	eigWeights(1:10) = 0; % Ignore first 10 eigenfaces by setting to zero
	resetEigWeights = 1;
end

% Remove the mean of the images (definitely batch mode)
for i = 1:size(fbgTrainImgs, 2)
	fbgTrainImgs(:,i) = fbgTrainImgs(:,i) - fbgAvgFace;
end

% Do PCA using SVD (Singular Value Decomposition)
[U,SV] = svd(fbgTrainImgs,'econ');
v = U(:,1:numVectors); % Take the top eigenvectors as eigenfaces

% Apply weights to the eigenvectors (so we can ignore the top 10)
if exist('eigWeights')
    for i = 1:numVectors
        v(:,i) = v(:,i)*eigWeights(i);
    end
end

% Create training weights for each image (representation of each face in
% the eigenspace) as a linear combination of each eigenface.
trainWeights = v'*fbgTrainImgs;

% This is the data we need to perform recognition (during testing phase)
fbgTrainMem{1} = v;
fbgTrainMem{2} = fbgTrainIds;
fbgTrainMem{3} = trainWeights;
fbgTrainMem{4} = fbgAvgFace;