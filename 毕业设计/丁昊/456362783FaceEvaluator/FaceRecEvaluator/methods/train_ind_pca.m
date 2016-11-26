resetEigWeights = 0;
if ~exist('eigWeights', 'var')
	eigWeights(1:1000) = 1;
	eigWeights(1:1) = 1; % Ignore first 10 eigenfaces
	resetEigWeights = 1;
end

for i = 1:size(fbgTrainImgs, 2)
	fbgTrainImgs(:,i) = fbgTrainImgs(:,i) - fbgAvgFace;
end

% We want the number of eigenfaces for each individual to be the same
% (Otherwise some individuals will encode too much information and that
% will bias the classification)
numVectors = 100;
for i = 1:length(fbgIds)
    index = find(fbgTrainIds == fbgIds(i));
    if length(index) < numVectors
        numVectors = length(index);
    end
end

fbgTrainImgs = fbgTrainImgs';

for i = 1:length(fbgIds)
    index = find(fbgTrainIds == fbgIds(i));
    v{i} = princomp(fbgTrainImgs(index,:), 'econ');
	v{i} = v{i}(:,1:numVectors-1);
end

% Apply weights to the eigenvalues
for i = 1:length(fbgIds)
	for j = 1:numVectors-1
		v{i}(:,j) = v{i}(:,j)*eigWeights(j);
	end
end

fbgTrainImgs = fbgTrainImgs';

% This is the data we need to perform recognition (during testing phase)
fbgTrainMem{1} = v;