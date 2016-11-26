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

function [v,trainWeights]=train_lda(fbgrows,fbgcols,fbgTrainImgs,fbgTrainIds,fbgAvgFace,numVectors)

if isempty(numVectors)              %默认使用 100 eigenvectors (eigenfaces)
	numVectors = 100;
end

Nx = fbgcols;
Ny = fbgrows;
NxNy = Nx*Ny;
me = fbgAvgFace;

for i = 1:size(fbgTrainImgs, 2)
	fbgTrainImgs(:,i) = fbgTrainImgs(:,i) - fbgAvgFace;
end

[U,sigma,coeff] = svd(fbgTrainImgs,'econ');     %采用SVD进行降维

uniqueIds = unique(fbgTrainIds);
lenuniIds = length(uniqueIds);
trainClassMean = cell(lenuniIds,1);

if lenuniIds > numVectors                       %lda的维度为uniqueId数，要确保降维前不低于numvectors
	numVectors = lenuniIds;
end

P0 = U(:,1:numVectors);

[U,sigma,coeff] = svd(fbgTrainImgs,'econ');     %再次SVD
P1 = U;

for i = 1:lenuniIds                               %计算每个人的平均值
    index = find(fbgTrainIds == uniqueIds(i));
    trainClassMean{i} = mean(fbgTrainImgs(:,index), 2);
end

% Calculate the between-class scatter matrix, Sb
%       and the within-class scatter matrix,  Sw
prod = zeros(NxNy);
Sb = zeros(NxNy);
for i = 1:lenuniIds
    row = trainClassMean{i} - me;
    prod = row * row';
    Sb = Sb + prod;
end

Sw = zeros(NxNy);
for i = 1:lenuniIds
    index = find(fbgTrainIds == uniqueIds(i));
    for j = 1:length(index)
        row = fbgTrainImgs(:,index(j)) - trainClassMean{i};
        prod = row * row';
        Sw = Sw + prod;
    end
end
clear prod row;

Sbb = P1.'*Sb*P1;           %用pca将其映射到子空间
Sww = P1.'*Sw*P1;
clear Sb Sw 
[V,D] = eig(Sbb,Sww);

Ds = diag(D);
[~,b] = sort(abs(Ds));       %矩阵重排
b = flipud(b);               %翻转矩阵

eigVals = Ds(b);
eigVecs = P1*V(:,b);
clear D Ds V

Mp = lenuniIds-1;      
P = eigVecs(:,1:Mp);    % ouput fisherfaces
v = P./repmat(sum(P.^2).^0.5,NxNy,1); % normalize

trainWeights = v'*fbgTrainImgs;
