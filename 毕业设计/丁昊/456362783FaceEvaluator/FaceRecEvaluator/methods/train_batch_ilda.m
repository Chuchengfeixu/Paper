%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Face Recognition Evaluator -> train_batch_ilda.m: Calculates subspace
% using Linear Discriminant Analysis (Fisherfaces) using an incremental
% method run in batch mode.
%
% This is usually called during a fbRun, and a number of variables are
% already loaded and ready. See train_pca.m for more details.
%
% Uses ILDA code from: http://svr-www.eng.cam.ac.uk/~tkk22/code.htm
%
% T. K. Kim, S. F. Wong, B. Stenger, J. Kittler, and R. Cipolla,
% "Incremental Linear Discriminant Analysis Using Sufficient Spanning Set
% Approximations," in IEEE CVPR, 2007, pp. 1-8.
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

% Normalize images by subtracting out the mean face of training images
for i = 1:size(fbgTrainImgs,2)
	fbgTrainImgs(:,i) = fbgTrainImgs(:,i) - fbgAvgFace;
end

eigenThreshold = 0;
DeigenThreshold = 0;

% Calculate eigenvectors and eigenvalues by SVD rather than the normal way
% This is much faster and less memory intensive
%[m_1, M_1, TeigenVect_1, TeigenVal_1] = fGetStModel(fbgTrainImgs, eigenThreshold);
[m_1, M_1] = size(fbgTrainImgs);
[TeigenVect_1, TeigenVal_1] = svd(fbgTrainImgs, 'econ');

% Finish off ILDA
[m_1, M_1, BeigenVect_1, BeigenVal_1, samplePerClass_1, meanPerClass_1] = fGetSbModel(fbgTrainImgs, fbgTrainIds', eigenThreshold);
[DiscriminativeComponents, D] = fGetDiscriminativeComponents(TeigenVect_1, TeigenVal_1, BeigenVect_1, BeigenVal_1, M_1, DeigenThreshold, 100);
v = DiscriminativeComponents;

% Calculate training weights in the LDA subspace
trainWeights = v'*fbgTrainImgs;

% This is the data we need to perform recognition (during testing phase)
fbgTrainMem{1} = v;
fbgTrainMem{2} = fbgTrainIds;
fbgTrainMem{3} = trainWeights;
fbgTrainMem{4} = fbgAvgFace;