%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Face Recognition Evaluator -> test_ccipca_libsvm.m: Tests SVMs on
% faces which have been reduced in dimensionality with CCIPCA. 
%
% This is usually called during a fbRun, and a number of variables are
% already loaded and ready. See train_pca.m for more details.
%
% Uses CCIPCA code from: www.cse.msu.edu/~weng/research/
% Uses LIBSVM code from: www.csie.ntu.edu.tw/~cjlin/libsvm/
%
% J. Weng, Y. Zhang, and W. S. Hwang, "Candid Covariance-Free Incremental
% Principal Component Analysis," IEEE TPAMI, vol. 25, pp. 1034-1040, 2003.
%
% G. Guo, S. Z. Li, and K. Chan, "Face Recognition By Support Vector
% Machines," Image and Vision Computing, vol. 19, pp. 631-638, 2001.
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

% Normalize images by subtracting out the average face
for i = 1:size(fbgTestImgs,2)
	fbgTestImgs(:,i) = fbgTestImgs(:,i) - fbgAvgFace;
end

% We have to do this otherwise the memory count is messed up. fbgTestImgs
% isn't counted towards the memory quota so if we overwrite it with
% something smaller we'll wind up with a negative memory usage
fbgTestImgs_old = fbgTestImgs;
fbgTestImgs_old(1,1) = 0; % Force copy on write

% Feed the weights of the images in CCIPCA substace to LIBSVM
fbgTestImgs = v'*fbgTestImgs;
test_libsvm;