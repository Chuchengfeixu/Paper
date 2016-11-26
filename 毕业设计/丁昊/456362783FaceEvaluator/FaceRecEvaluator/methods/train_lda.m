%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Face Recognition Evaluator -> train_lda.m: Trains using the Fisherfaces
% algorithm (Linear Discriminant Analysis => LDA). This method does quite
% well, although is more computationally expensive. The trick to this
% method is to reduce the dimensionality of the images first using PCA and
% then do LDA on the PCA weights.
%
% This is usually called during a fbRun, and a number of variables are
% already loaded and ready. See train_pca.m for more details.
%
% Uses LDA code from:
% http://dailyburrito.com/projects/facerecog/FaceRecReport.html
%
% P. N. Belhumeur, J. P. Hespanha, and D. J. Kriegman, "Eigenfaces vs.
% Fisherfaces: Recognition Using Class Specific Linear Projection," in IEEE
% TPAMI. vol. 19, 1997, pp. 711-720 
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
resetDiscardTopEigs = 0;

if ~exist('numVectors', 'var')
	numVectors = 100;
	resetNumVectors = 1;
end
% Slightly different from other algorithms, here we actually discard the
% top eigenvectors instead of just setting them to zero. 
if ~exist('discardTopEigs', 'var')
	discardTopEigs = 0;
	resetDiscardTopEigs = 1;
end

% You definitely want to do this
reduceDim = 1;

% Find the image size, [Nx Ny], and the number of training images, M
Nx = fbgCols;
Ny = fbgRows;
NxNy = Nx*Ny;
M = length(fbgTrainIds);
me = fbgAvgFace;

for i = 1:size(fbgTrainImgs, 2)
	fbgTrainImgs(:,i) = fbgTrainImgs(:,i) - fbgAvgFace;
end

% Reduce the dimensionality of the faces using SVD
[U,sigma,coeff] = svd(fbgTrainImgs,'econ');

% Calculate the number of classes (number of unique people)
trainClasses = unique(fbgTrainIds);
numOfClass = length(trainClasses);
trainClassMean = cell(numOfClass,1);

% The dimensionality of LDA is the number of classes, so make sure we don't
% try to reduce the dimensionality below that before doing LDA.
if numOfClass > numVectors
	numVectors = numOfClass;
end

if discardTopEigs > 0
	numVectors = numVectors + discardTopEigs;
end

P0 = U(:,discardTopEigs+1:numVectors);

% Yes you want to do this
if reduceDim
	fbgTrainImgs = P0'*fbgTrainImgs;
	me = mean(fbgTrainImgs,2);
	NxNy = numVectors - discardTopEigs;
end

% Run SVD again
[U,sigma,coeff] = svd(fbgTrainImgs,'econ');
P1 = U;

% Calculate the mean for each person
for i = 1:numOfClass
    index = find(fbgTrainIds == trainClasses(i));
    trainClassMean{i} = mean(fbgTrainImgs(:,index), 2);
end

% Calculate the between-class scatter matrix, Sb
%       and the within-class scatter matrix,  Sw
prod = zeros(NxNy);
Sb = zeros(NxNy);
for i = 1:numOfClass
    row = trainClassMean{i} - me;
    prod = row * row';
    Sb = Sb + prod;
end

Sw = zeros(NxNy);
for i = 1:numOfClass
    index = find(fbgTrainIds == trainClasses(i));
    for j = 1:length(index)
        row = fbgTrainImgs(:,index(j)) - trainClassMean{i};
        prod = row * row';
        Sw = Sw + prod;
    end
end
clear prod row;

% Use PCA to project into subspace
Sbb = P1.'*Sb*P1; 
Sww = P1.'*Sw*P1;
clear Sb Sw % save memory

% Current decomposition method: (from class)
% Find generalized eigenvalues & eigenvectors using eig(A,B)
[V,D] = eig(Sbb,Sww);

% Another possible method: (from class)
% 1. Note that we only care about the direction of Sw*W on m1-m2
% 2. Guess w = Sw^-1 * (m1-m2), then iterate ???

% One more possible method: (from Duda book)
% 1. Find the eigenvalues as the roots of the characteristic
%    polynomial:  
%       det(Sb - lambda(i)*Sw) = 0
% 2. Then solve for the eigenvectors w(i) directly using:
%       (Sb - lambda(i)*Sw)*w(i) = 0

% Extract eigenvalues and sort largest to smallest
Ds = diag(D);
[tmp,ndx] = sort(abs(Ds));
ndx = flipud(ndx);
% get sorted eigenvalues (diag of E) and 
% eigenvectors (project V back into full space using P1)
eigVals = Ds(ndx);
eigVecs = P1*V(:,ndx);
clear D Ds V % save a little memory

% Only keep numOfClass-1 weights, and
% Scale to make eigenvectors normalized => sum(P(:,1).^2)==1
Mp = numOfClass-1;      
lambda = eigVals(1:Mp); % output weights
P = eigVecs(:,1:Mp);    % ouput fisherfaces
v = P./repmat(sum(P.^2).^0.5,NxNy,1); % normalize

trainWeights = v'*fbgTrainImgs;

% This is the data we need to perform recognition (during testing phase)
fbgTrainMem{1} = v;
fbgTrainMem{2} = fbgTrainIds;
fbgTrainMem{3} = trainWeights;
fbgTrainMem{4} = fbgAvgFace;
fbgTrainMem{5} = P0;