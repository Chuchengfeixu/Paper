%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Face Recognition Evaluator -> fbInit: Initializes paths and global
% parameters. Use to change face recognition parameters, such as where the
% face datasets are stored.
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

if exist('fbDoNotInit', 'var') && fbDoNotInit == 1
	return;
end

% These are the datasets we want to run the face recognition algorithms on
fbgDatasets = {'att', 'ifd'};

% These are the face recognition algorithms to run. For each <name>, the
% train_<name>.m and test_<name>.m will be run from the "methods" folder
fbgAlgorithms = {'pca', 'lda'};
%fbgAlgorithms = {'pca', 'batch_ccipca', 'ind_ccipca', 'ica', 'lda' , 'libsvm', 'pca_libsvm', 'lda_libsvm', 'isvm'};
%fbgAlgorithms = {'batch_ilda', 'ccipca_libsvm', 'ilda_libsvm', 'ilda', 'ind_batch_ccipca', 'ica_libsvm'};

% Constant variables that don't change during a run
WINDOWS = 1;
LINUX = 2;

% Change this to swap between Linux and Windows (for monitoring memory)
fbgPlatform = WINDOWS;

% fbgBasePath: Base path is where the face datasets are stored
fbgBasePath = './datasets';

% Every folder in fbgBasePath is a face dataset, which can contain raw and
% intermediate files. The final faces are stored in fbgImgFolder
fbgImgFolder = '_csu7';

% What format are the final faces in? Can be any common type
fbgImgExt = 'jpg';

% fbgImgSide: Resize the images so the largest side is this value 
fbgImgSide = 18;

% fbgTrainPercent: Splits the data into training/testing set randomly. This
% value is only approximate because you might not be able to split evenly.
fbgTrainPercent = 60;

% fbgRandTrainFaces: Boolean that randomizes the training faces so any
% incremental methods aren't biased 
fbgRandTrainFaces = 1;

% fbgRecordMem: Boolean value that specifies whether to record the memory
% of the algorithms being run.
fbgRecordMem = 0;

% fbgCacheDataset: Boolean that specifies whether to cache the dataset to
% disc as a 'MAT' file when running multiple algorithms on the same dataset
fbgCacheDataset = 1;

% fbgMinImgsPerUser: Set the minimum number of images per person. Any
% person in the dataset with less than this number of images is excluded
fbgMinImgsPerUser = 10;

% Generate HTML table of faces, the test face and the top guesses
% If fbgUseAbsPaths = 1, then the paths are encoded using fbgBasePath,
% otherwise new faces are written with relative paths. One consequence of
% setting fbgUseAbsPath = 0 is that images are resized to fbgImgSize 
fbgGenHTMLResults = 0;
fbgUseAbsPaths = 1;

% Try to find a threshold that gives us this accuracy
fbgMakeAccuracy = -1;%0.90;

% Make stuff quiet, if possible
fbgVerbose = 0;

% If the correct face is in the top X matches, count match as a success
% By default this should be 1 (only add to success if top match is correct)
fbgCountTopX = 1;

% Global variables that you shouldn't really need to change
fbgStatsFolder = 'stats';
fbgMFolder = 'methods';
fbgUtilsFolder = 'utils';
fbgShellFolder = 'shell';
fbgLinMemScript = 'logmem.sh';
fbgWinMemScript = 'logmem.bat';
fbgConserveMem = 0;
fbgForceReload = 0;
fbgBackupFolder = 'backup';
fbgTempFolder = 'tmp';
fbgDoneFile = [fbgTempFolder '/done.mat'];
fbgStatusFile = [fbgStatsFolder '/status.mat'];
fbgTrainDataset = [fbgTempFolder '/train.mat'];
fbgTestDataset = [fbgTempFolder '/test.mat'];

% For building filenames
fbgTrainDataStr = '_train_data_';
fbgTrainMemStr = '_train_mem_';
fbgTestMemStr = '_test_mem_';
fbgAccuracyStr = '_accuracy_';
fbgTrainTimeStr = '_train_time_';
fbgTestTimeStr = '_test_time_';
fbgTrainSizeStr = '_train_size_';

fbgTrainPrefixStr = 'train_';
fbgTestPrefixStr = 'test_';

fbgMiscInfoStr = '_misc_';
fbgTableFile = 'results table.txt';
fbgStatsFile = 'stats.mat';

% Custom libsvm parameter codes to optimize memory usage
OPT_SET_DATA                    = 1;
OPT_TRAIN                       = 2;
OPT_CLEAR_DATA                  = 3; % Don't use!
OPT_CLEAR_MODEL                 = 4; % Don't use!
OPT_EXPORT_MODEL                = 5;
OPT_PREDICT                     = 6;
OPT_CLEAR                       = 7;
OPT_SAVE                        = 8;
OPT_LOAD                        = 9;

% Adds sub directories to the path so we can organize things nicely
if ~exist('fbgInit', 'var')
	addpath(fbgMFolder);
	addpath(fbgUtilsFolder);
	addpath(fbgShellFolder);
	
	fbFiles = dir(fbgMFolder);
	for fbI = 1:length(fbFiles)
		fbF = fbFiles(fbI);
		if fbF.isdir == 1
			if strcmp(fbF.name, '.') || strcmp(fbF.name, '..')
				continue;
			end
			
			addpath([fbgMFolder '/' fbF.name]);
		end
	end
	
	fbgInit = true;
end