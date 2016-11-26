%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Face Recognition Evaluator -> test_batch_ilda.m: Tests the Fisherface
% algorithm using the ILDA method. Works the same way as PCA for
% recognition. 
%
% This is usually called during a fbRun, and a number of variables are
% already loaded and ready. See test_pca.m for more details
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

% Normalize test images by subtracting average face from training images
for i = 1:size(fbgTestImgs,2)
	fbgTestImgs(:,i) = fbgTestImgs(:,i) - fbgAvgFace;
end

testWeights = v'*fbgTestImgs;

% Recognize IDs using nearest neighbor between testWeights and trainWeights
classify_nearest;
