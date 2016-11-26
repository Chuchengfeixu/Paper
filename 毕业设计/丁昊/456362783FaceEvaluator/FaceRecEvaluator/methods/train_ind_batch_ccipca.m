resetEigWeights = 0;
if ~exist('eigWeights', 'var')
	eigWeights(1:1000) = 1;
	eigWeights(1:1) = 1; % Ignore first X eigenfaces
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

for i = 1:length(fbgIds)
    index = find(fbgTrainIds == fbgIds(i));
	v{i} = ccipca(fbgTrainImgs(:,index), numVectors);
end

% Apply weights to the eigenvalues
for i = 1:length(fbgIds)
	for j = 1:numVectors
		v{i}(:,j) = v{i}(:,j)*eigWeights(j);
	end
end

% This is the data we need to perform recognition (during testing phase)
fbgTrainMem{1} = v;