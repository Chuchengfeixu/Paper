fbgCountImgMem = 0; % This is a purely incremental version

resetEigWeights = 0;
if ~exist('eigWeights', 'var')
	eigWeights(1:1000) = 1;
	eigWeights(1:1) = 0; % Ignore first X eigenfaces
	resetEigWeights = 1;
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

avgFace = {};
v = {};
for i = 1:length(fbgIds)
    index = find(fbgTrainIds == fbgIds(i));
	trainImgs = fbgTrainImgs(:,index);
 	avgFace{i} = mean(trainImgs(:,1:numVectors),2);
 	for j = 1:numVectors
 		trainImgs(:,j) = trainImgs(:,j) - avgFace{i};
	end
	[v{i},d,n] = ccipca(trainImgs, numVectors);
	
	for j = numVectors+1:size(trainImgs,2)
		avgFace{i} = ((j-1)/j)*avgFace{i} + (1/j)*trainImgs(:,j);
	% 		imagesc(reshape(avgFace, fbgCols, fbgRows)');
	% 		drawnow;
		trainImgs(:,j) = trainImgs(:,j) - avgFace{i};
		[v{i},d,n]=ccipca(trainImgs(:,j), numVectors, 1, v{i}, n);
	end	
end

% Apply weights to the eigenvalues
for i = 1:length(fbgIds)
	for j = 1:numVectors
		v{i}(:,j) = v{i}(:,j)*eigWeights(j);
	end
end

% This is the data we need to perform recognition (during testing phase)
fbgTrainMem{1} = v;
fbgTrainMem{2} = avgFace;