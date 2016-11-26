%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Face Recognition Evaluator -> train_ica.m: Trains faces using ICA
% (Independent Component Analysis), which can better represent
% high-dimensional data because the axis do not have to be perpendicular
% like PCA. This code uses Bartlett's Architecture I methodology.
%
% Because of the learning logistic function (e^x) executing a fixed number
% of times, there is a large time constant in the algorithm.
%
% Uses ICA code from: http://www.cnl.salk.edu/~marni/icaPapers.html
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

resetNumVectors = 0;
resetEigWeights = 0;

if ~exist('numVectors', 'var')
	numVectors = 100;
	resetNumVectors = 1;
end

% Slightly different from other algorithms, here we actually discard the
% top eigenvectors instead of just setting them to zero. 
if ~exist('discardTopEigs', 'var')
	discardTopEigs = 10;
end

% Normalize by subtracting the mean
for i = 1:size(fbgTrainImgs,2)
	fbgTrainImgs(:,i) = fbgTrainImgs(:,i) - fbgAvgFace;
end

trainIds = fbgTrainIds;
trainClass = trainIds';

% Calculate PCA rep with SVD
% Don't use [V,R,E] = pcabigFn(C); as it is too memory intensive
[N,P] = size(fbgTrainImgs);
[V, E, U] = svd(fbgTrainImgs, 'econ');
D = diag(E);
R = fbgTrainImgs'*V;  % Rows of R are pcarep of each image.

numEig = numVectors;

%If PCA generalizes better by dropping first few eigenvectors, ICA will too
x = V(:,discardTopEigs+1:numEig)'; 		% x is 200x3600
runica 				% calculates wz, w and uu. The matrix x gets 
				% overwritten by a sphered version of x. 
F = R(:,discardTopEigs+1:numEig) * inv(w*wz); 	% F is 500x200 and each row contains the 
			    	% ICA1 rep of an image
					
V = V(:,discardTopEigs+1:numEig);

% This is the data we need to perform recognition (during testing phase)
fbgTrainMem{1} = V;
fbgTrainMem{2} = w;
fbgTrainMem{3} = wz;
fbgTrainMem{4} = F;
fbgTrainMem{5} = fbgAvgFace;
