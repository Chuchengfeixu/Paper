%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Face Recognition Evaluator -> train_ccipca_libsvm.m: Trains SVMs on
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

% Train with CCIPCA, then use the weights as inputs to LIBSVM
train_batch_ccipca;
fbgTrainImgs = trainWeights;
train_libsvm;