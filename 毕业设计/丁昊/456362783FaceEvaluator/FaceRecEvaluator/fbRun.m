%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Face Recognition Evaluator -> fbRun: The heart of the package. Modify the
% parameters if fbInit.m to your liking and then run this to test the
% algorithms on your datasets. This may take a long time to run and may
% take a lot of memory depending on the dataset size. 
%
% I have tested all the algorithms with up to a 18,000 face (56x64 pixels)
% dataset on a Windows XP 32-bit machine running Matlab R2007a with the 3GB
% of RAM and the /3gb boot option enabled. Make sure you have several GB of
% harddisk space to save the output (and intermediate) files.
%
% This script runs fbReport afterwards so you can find the results of the
% algorithm runs in "stats\report.csv." Accuracies are printed out as the
% script runs, as are times.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Authors:                           Brian C. Becker @ www.BrianCBecker.com
% Copyright (c) 2007-2008          Enrique G. Ortiz @ www.EnriqueGOrtiz.com
%
% License: You are free to use this code for academic and non-commercial
% use, provided you reference the following paper in your work.
%
% Becker, B.C., Ortiz, E.G., "Evaluation of Face Recognition Techniques for 
%   Application to Facebook," in Proceedings of the 8th IEEE International
%   Automatic Face and Gesture Recognition Conference, 2008.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
fbgNumRuns = 1;

% Initialize global variables
fbInit
fbgGlobalTimer = timetic;
tic(fbgGlobalTimer);

% Do some pre-run stuff (print info, prepare folders, etc)
fbPreRun;

% Run over all the datasets (this way we only load each dataset once)
for runD = 1:length(fbgDatasets)
	fbgDataset = fbgDatasets{runD};

	% Run a bunch of different times with different train/split set and
	% average the results to get a better idea of the stats generated
	for runR = 1:fbgNumRuns
		
		% Run each method for each dataset
		for runM = 1:length(fbgAlgorithms)		
		
			fbgRandSeed = runR; % Set random seed to 1, 2, 3, etc...non-biased

			% Load image data
			if runM == 1 && fbgCacheDataset
				fbgCurPath = [fbgBasePath '/' fbgDataset '/' fbgImgFolder];
				fprintf('Separating train/test (%d/%d%%) set images in %s, run %d...\n', fbgTrainPercent, 100 - fbgTrainPercent, fbgCurPath, runR);
				[fbgTrainFiles, fbgTestFiles, fbgIds] = getTrainTestSet(fbgCurPath, fbgTrainPercent, fbgImgExt, fbgRandSeed, fbgMinImgsPerUser);

				if length(fbgIds) <= 1
					fprintf('Error: unable to load images from %s!\n', fbgCurPath);
					continue;
				end
			end
			
			% Run iteration (runM)
	
			fbgMethod = fbgAlgorithms{runM};
			fbgAlgorithm = fbgMethod; % Name makes a bit more sense
			itr = ['_' int2str(runR)];

			% For each method, we will save out a bunch of stats
			fbgOutFolder = [fbgStatsFolder '/' fbgMethod '/'];

			% Make folder (if needed)
			if ~exist(fbgOutFolder, 'dir')
				mkdir(fbgOutFolder);
			end

			% Set global fb variables for each algorithm to access
			fbgAccuracy = -1; % Algorithm should fill this out
			fbgCountImgMem = 1; % Default: count image memory (batch algo)
			fbgTrainMem = {}; % Any data needed for testing should go here
			fbgTrainMemSize = 0;
			fbgGuessIds = [];
			fbgClearTrainImgs = 0;
			fbgThreshold = 0;

			% This is where any training data should get saved
			fbgTrainDataFile = [fbgOutFolder fbgTrainDataStr fbgDataset itr '.mat'];
			fbgTrainMemFile = [fbgOutFolder fbgTrainMemStr fbgDataset itr '.txt'];
			fbgTestMemFile = [fbgOutFolder fbgTestMemStr fbgDataset itr '.txt'];
			fbgAccuracyFile = [fbgOutFolder fbgAccuracyStr fbgDataset itr '.txt'];
			fbgTrainTimeFile = [fbgOutFolder fbgTrainTimeStr fbgDataset itr '.txt'];
			fbgTestTimeFile = [fbgOutFolder fbgTestTimeStr fbgDataset itr '.txt'];
			fbgTrainSizeFile = [fbgOutFolder fbgTrainSizeStr fbgDataset itr '.txt'];

			% Load in train images and clear test  ones 
			clear fbgTestImgs;
			if fbgCacheDataset && runM > 1 && exist(fbgTrainDataset, 'file')
				load(fbgTrainDataset);
			else
				[fbgTrainImgs,fbgTrainIds,fbgAvgFace] = batchPictures(fbgCurPath, fbgTrainFiles, fbgImgSide, 0, fbgVerbose);
				%load('fbtest_train.mat');
				
				if fbgRandTrainFaces
					fbRandFaces;
				end

				% Get the rows & cols for the pictures loaded
				tmpImg = getImageN(fbgCurPath, fbgTrainFiles(1), fbgImgSide);
				[fbgRows, fbgCols] = size(tmpImg);
				clear tmpImg;
				
				if fbgCacheDataset
					save(fbgTrainDataset, 'fbgTrainImgs', 'fbgTrainIds', 'fbgTrainFiles', 'fbgRows', 'fbgCols', 'fbgAvgFace', 'fbgIds');
				end
			end
			fbgTrainImgsSize = size(fbgTrainImgs,1)*size(fbgTrainImgs,2)*8;
			fbgNumTrainImgs = length(fbgTrainIds);

			fprintf('Training algorithm "%s" on dataset "%s"...\n', fbgMethod, fbgDataset);
			% Run the training phase of this algorithm, saving time/mem
			if fbgRecordMem
				fbgMemFile = fbgTrainMemFile;
				fbStartMem;
			end
			
			fbgTimer = timetic;
			tic(fbgTimer);
			
			%try
				eval([fbgTrainPrefixStr fbgMethod]); 
			%catch
			%	if fbgRecordMem, fbStopMem; end % So we don't leave some process hanging
			%	lasterror.stack(1)
			%	rethrow(lasterror)
			%end
			fbgTrainTime = toc(fbgTimer);

			if fbgRecordMem
				fbStopMem;
			end
			
			if fbgCountImgMem
				fbgCountImgMem = fbgTrainImgsSize;
			else
				fbgCountImgMem = 0;
			end
			
			save(fbgTrainTimeFile, 'fbgTrainTime', '-ASCII');
			numImgs = length(fbgIds);
			save(fbgTrainDataFile, 'fbgTrainMem', 'fbgCountImgMem', 'numImgs');
			if fbgTrainMemSize ~= 0
				save(fbgTrainSizeFile, 'fbgTrainMemSize', '-ASCII');
			end
			clear fbgTrainMem;
			
			% Load in test images and clear train ones
			fbgAvgTrainFace = fbgAvgFace;
			if fbgClearTrainImgs && ~fbgGenHTMLResults
				clear fbgTrainImgs;
			end
			if fbgCacheDataset && runM > 1 && exist(fbgTestDataset, 'file')
				load(fbgTestDataset);
			else			
				[fbgTestImgs,fbgTestIds] = batchPictures(fbgCurPath, fbgTestFiles, fbgImgSide, 0, fbgVerbose);
				%load('fbtest_test.mat');
				
				if fbgCacheDataset
					save(fbgTestDataset, 'fbgTestImgs', 'fbgTestIds', 'fbgTestFiles');
				end
			end
			fbgNumTestImgs = length(fbgTestIds);

			fprintf('Testing algorithm "%s" on dataset "%s"...\n', fbgMethod, fbgDataset);
			% Run the testing phase of this algorithm
			if fbgRecordMem
				fbgMemFile = fbgTestMemFile;
				fbStartMem;
			end
			
			fbgTimer = timetic;
			tic(fbgTimer);
			%try
				eval([fbgTestPrefixStr fbgMethod]);
			%catch
			%	if fbgRecordMem, fbStopMem; end % So we don't leave some process hanging
			%	lasterror.stack(1)
			%	rethrow(lasterror)
			%end
			fbgTestTime = toc(fbgTimer);
			
			if fbgRecordMem
				fbStopMem;
			end
			save(fbgTestTimeFile, 'fbgTestTime', '-ASCII');
			save(fbgAccuracyFile, 'fbgAccuracy', '-ASCII');
			
			fprintf('%0.2f%% accuracy from "%s" on dataset "%s" in %0.1f min\n\n', fbgAccuracy, fbgMethod, fbgDataset, (fbgTrainTime + fbgTestTime) / 60.0);
			save([fbgStatsFolder '/' fbgMethod '/' fbgStatsFile], 'fbgNumRuns', 'fbgDatasets', 'fbgRecordMem', 'fbgNumTrainImgs', 'fbgNumTestImgs', 'fbgCountImgMem', 'fbgThreshold');
			
			%return;
			
			% Don't leave junk lying around (C++ habits still strong)
			% This also gets rid of any crud hanging around, cleaning
			% everything out. The exception to this is if we are only
			% tweaking one algorithm on one dataset, then it's redundant to
			% load in new data each time
			% CHANGE: Clear everything anyhow, let's be safe about this
			%if length(fbgDatasets) > 1 || length(fbgAlgorithms) > 1 || length(fbgNumRuns) > 1
				save(fbgStatusFile, 'runD', 'runR', 'runM', 'fbgDatasets', 'fbgAlgorithms', 'fbgNumRuns', 'fbgDataset', 'fbgGlobalTimer');
				clear;
				fbInit;
				load(fbgStatusFile);
			%end
		end
	end
end

delete(fbgStatusFile);
delete(fbgTestDataset);
delete(fbgTrainDataset);
if exist('svm_model.dat', 'file')
	delete('svm_model.dat');
end

fprintf('Algorithm runs done, generating report...\n');
fbReport
fprintf('Report generated, check stats/results.csv for details\n');

time = toc(fbgGlobalTimer);
if time < 60
	fprintf('Face Recognition Evaluator done in %0.1f sec\n\n', time);
elseif time < 60*60
	fprintf('Face Recognition Evaluator done in %0.1f min\n\n', time / 60);
else
	fprintf('Face Recognition Evaluator done in %0.1f hours\n\n', time / 60 / 60);	
end