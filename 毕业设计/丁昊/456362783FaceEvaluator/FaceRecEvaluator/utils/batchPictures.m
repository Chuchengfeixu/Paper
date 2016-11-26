%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Face Recognition Evaluator -> batchPictures: Loads a list of files into a
% single matrix, calculating the average as well. All images must be the
% same size for this to work.
%
% [pics,id,avg] = batchPictures(path, files, side, rowVecFlag)
% 
% 'path'       - Path to the files
% 'files'      - List of files to load
% 'side'       - Resizes largest side to this, preserving aspect ratio
% 'rowVecFlag' - Load images as rows (vs columns)
% 'fbgVerbose' - Be quiet when running (no progress bar as images load)
%
% 'pics'       - Matrix of images, with each image in a row/column
% 'id'         - The ID of each image (person the face belongs to)
% 'avg'        - The mean face calculated from the loaded pictures
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
function [pics,id,avg] = batchPictures(path, files, side, rowVecFlag, fbgVerbose)

	% By default, load images in as row vectors
	if nargin <= 3
		rowVecFlag = true;
	end
	if nargin <= 4
		fbgVerbose = 1;
	end

	id = ones(length(files), 1);

	% Load first image to check the size of the images
	img = getImageN(path, files(1), side);
	[rows, cols] = size(img);

	% Loading lots of pictures can be really time consuming so use a
	% progress bar to print dots as the images are loaded
	len = length(files);
	numDots = 50;
	if fbgVerbose
		begLine = sprintf('Loading %d pictures', len);
		fprintf('%s\n', [begLine repmat(' ', 1, numDots - length(begLine) + 1) '|'])
	end

	dots = 0;
	if rowVecFlag
		pics = zeros(length(files),rows*cols);

		for i = 1:len
		   if i / len > dots / numDots
			   dots = dots + 1;
			   if fbgVerbose
				   fprintf('.');
			   end
		   end

		   img = getImageN(path, files(i), side);
		   pics(i,:) = reshape(img',1,rows*cols);
		   id(i) = str2double(getID(files(i).name));
		end

		avg = mean(pics,1);
	else
		pics = zeros(rows*cols,length(files));

		for i = 1:len

		   if i / len > dots / numDots
			   dots = dots + 1;
			   if fbgVerbose
				   fprintf('.');
			   end
		   end       
		   img = getImageN(path, files(i), side);
		   pics(:,i) = reshape(img',1,rows*cols);
		   id(i) = str2double(getID(files(i).name));
		end    

		avg = mean(pics,2);
	end
	
	% Make sure we have printed all the dots in the progress bar
	if fbgVerbose
		while dots <= 50
			fprintf('.');
			dots = dots + 1;
		end
	fprintf('|\n');
	end
	
return