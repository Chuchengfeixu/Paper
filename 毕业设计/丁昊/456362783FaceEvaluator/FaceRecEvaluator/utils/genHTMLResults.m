%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Face Recognition Evaluator -> genHTMLResults: Generates a table of each
% test face and the corresponding "best guess faces" from the training
% data.
% 
% See parameters fbgUseAbsPath in the fbInit.m for more info about the
% parameters. The HTML files are written to the stats folder with the name
% of the dataset. The name of the dataset and algorithm used are encoded
% the filename and title of the page. Each test image is displayed
% vertically down on the left hand side. Depending on the value of
% fbgCountTopX, the top X guesses will be displayed on the right. Correct
% matches will be displayed in a red rectangle. 
% 
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

htmlFolder = [fbgStatsFolder '/' fbgDataset];
if fbgUseAbsPaths
	absFolder = [fbgBasePath '/' fbgDataset '/' fbgImgFolder];
	relFolder = absFolder;
	ext = 'jpg';%fbgImgExt;
else
	absFolder = [fbgStatsFolder '/' fbgDataset '/images'];
	relFolder = ['./' fbgDataset '/images'];
	ext = 'jpg';
	if ~exist(absFolder, 'dir')'
		mkdir(absFolder);
	end
end

fp = fopen([htmlFolder '_' fbgAlgorithm '.html'], 'wb');
if fp
	
	fprintf(fp, '<html><head><title>%s - %d</title></head><body>\n', fbgDataset, fbgAlgorithm);
	fprintf(fp, '<table>');
	for i = 1:size(resultIds, 1)
		if fbgUseAbsPaths
			parts = strsplit('.', testFiles(i).name);
			basefile = [parts{1} '.' ext];
			filename = sprintf('file://%s/%s', relFolder, basefile);
			filename = strrep(filename, '/', '\');
		else
			basefile = sprintf('test%d.%s', i, ext);
			filename = [absFolder '/' basefile];
			img = fbgTestImgs(:,i) + fbgAvgFace;
			img = reshape(img, fbgCols, fbgRows)' / max(img(:));
			imwrite(img, filename);
			filename = [relFolder '/' basefile]; % for URL
		end
		fprintf(fp, '<tr><td><img src="%s" /></td><td>=></td>', filename);
		for j = 1:topX
			if fbgUseAbsPaths
				parts = strsplit('.', fbgTrainFiles(index(i, j)).name);
				basefile = [parts{1} '.' ext];
				filename = sprintf('file://%s/%s', relFolder, basefile);
				filename = strrep(filename, '/', '\');
			else
				basefile = sprintf('train%d.%s', index(i, j), ext);
				filename = [absFolder '/' basefile];
				if ~exist(filename, 'file')
					img = fbgTrainImgs(:,index(i, j)) + fbgAvgTrainFace;
					img = reshape(img, fbgCols, fbgRows)' / max(img(:));
				end
				imwrite(img, filename);
				filename = [relFolder '/' basefile]; % for URL
			end
			if resultMatrix(i, j) ~= 0
				fprintf(fp, '<td><img src="%s" style="border: 1px solid red;"/></td>', filename);
			else
				fprintf(fp, '<td><img src="%s"/></td>', filename);
			end
		end
		
		fprintf(fp, '</tr>\n');
	end
	fprintf(fp, '</table></body></html>');
	
	fclose(fp);
end