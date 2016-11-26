%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Face Recognition Evaluator -> test_ccipca.m: Tests the original
% 'eigenface' method using Incremental Principal Component Analysis (IPCA).
% Works the same way as PCA for recognition.
%
% This is usually called during a fbRun, and a number of variables are
% already loaded and ready. See test_pca.m for more details
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

for i = 1:size(fbgTestImgs,2)
	fbgTestImgs(:,i) = fbgTestImgs(:,i) - avgFace;
end

testWeights = v'*fbgTestImgs;

% Recognize IDs using nearest neighbor between testWeights and trainWeights
classify_nearest;

if resetNumVectors, clear numVectors; end
if resetEigWeights, clear eigWeights; end