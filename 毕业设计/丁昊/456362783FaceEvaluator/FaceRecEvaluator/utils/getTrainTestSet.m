%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Face Recognition Evaluator -> getTrainTestSet: Divides all the face image
% files in a folder into a train and test set based on a percentage. This
% is actually a pretty inefficient way to do things but hey it works.
%
% [trainFaces, testFaces, ids] = getTrainTestSet(path, trainPercent, ext,
% seed, omitThresh)
%
% 'path'          - Path to the images
% 'trainPercent'  - What percentage of total files to train on
% 'ext'           - The extension to search for face images (pgm, jpg, etc)
% 'seed'          - The random seed that sorts
% 'omitThresh'    - Omits people who don't have at least this many images
%
% 'trainFaces'    - Filenames of images to train on
% 'testFaces'     - Filenames of images to test on
% 'ids'           - All the people who are being trained/tested on
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

function [trainFaces, testFaces, ids] = getTrainTestSet(path, trainPercent, ext, seed, omitThresh)
    defaultOmitThresh = 10; % Omit people with less than this # of face images
    
	% Default some stuff
    if nargin == 2
        ext = 'jpg';
        seed = sum(100*clock);
		omitThresh = defaultOmitThresh;
    elseif nargin == 3 | seed == -1
        seed = sum(100*clock);
		omitThresh = defaultOmitThresh;
	elseif nargin == 4
		omitThresh = defaultOmitThresh;
    end
    
    files = dir([path '/*.' ext]);
	
	% No files means something wasn't specified right (wrong folder/ext)
	if isempty(files)
		trainFaces = 0;
		testFaces = 0;
		ids = 0;
		return;
	end
    
	% Put files into a variable called all
    ids = [];
    all = [];
    for i = 1:length(files)
        [all(i).id, all(i).num] = getID(files(i).name);
        all(i).file = files(i);
	end
    
	% Sort all the files by person into everybody (yeah this could really
	% be sped up with some unique calls probably).
    everybody = [];
    for i = 1:size(all,2)
        if i == 1
            everybody(1).id = all(1).id;
            everybody(1).face(1) = all(1);
            %ids(1) = str2double(all(1).id);
            continue;
        end
        
        found = false;
        for j = 1:size(everybody,2)
            if length(everybody(j).id) == length(all(i).id) & everybody(j).id == all(i).id
                everybody(j).face(size(everybody(j).face,2)+1) = all(i);
                found = true;
                break;
            end
        end
        
        if ~found
            index = size(everybody,2)+1;
            everybody(index).id = all(i).id;
            everybody(index).face(1) = all(i);
            %ids(index) = str2double(all(i).id);
        end
    end
    
    rand('seed', seed);

	% Put files into the train or test bin
    ctr = 1;
    for i = 1:size(everybody,2)
        len = length(everybody(i).face);
        
        if len < omitThresh
            continue;
        end
        
        ids(ctr) = str2double(everybody(i).id);
        ctr = ctr + 1;
        
		% Make the division between test/train sets random
        indexes = randperm(len);
        bound = ceil(trainPercent/100.0*len);
        if bound >= len
            bound = len - 1;
        end
        trainIndex = indexes(1:bound);
        testIndex = indexes(bound+1:end);
        for j = 1:length(trainIndex)
            if exist('trainFaces') == 0 %i == 1 && j == 1
                index = 1;
            else
                index = length(trainFaces)+1;
            end
            trainFaces(index) = everybody(i).face(trainIndex(j)).file;
        end
        for j = 1:length(testIndex)
            if exist('testFaces') == 0 %i == 1 && j == 1
                index = 1;
            else
                index = length(testFaces)+1;
            end
            testFaces(index) = everybody(i).face(testIndex(j)).file;
        end
    end
end