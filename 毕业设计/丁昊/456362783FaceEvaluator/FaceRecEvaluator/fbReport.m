%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Face Recognition Evaluator -> fbReport: Once the face recognition
% algorithms have been run using fbRun, this takes all the output data
% files and generates a report that summarizes the accuracy, train/test
% times, train/test memory usage, and model sizes.
%
% The code here is slightly messy because we used it to custom generate
% some reports and account for bugs in fbRun that have since been fixed.
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

fbInit;

if(exist([fbgStatsFolder '/plots'],'dir'))
    rmdir([fbgStatsFolder '/plots'], 's');
end

% Where the statistics folder is located
algoFolders = dir([fbgStatsFolder '/*']);

% Titles for the tables
titles = {'Accuracy (%)', 'Training Time (ms/img)', 'Testing Time (ms/img)', 'Total Execution Time (ms/img)', 'Training Memory (MB)', 'Testing Memory (MB)', 'Total Memory (MB)', 'Model Size (MB)'};
fileNames = {'acc', 'trainTime', 'testTime', 'totalTime', 'trainMem', 'testMem', 'totalMem', 'modelSize'};

% Create directory
if(~exist([fbgStatsFolder '/plots'],'dir'))
    mkdir([fbgStatsFolder '/plots']);
end

datasets = {};
algos = {};

resAccuracy = {};
resTrainTime = {};
resTestTime = {};
resTotalTime = {};
resTrainMem = {};
resTestMem = {};
resTotalMem = {};
resModelSize = {};

% Locate and organize all the output files used to generate the report
for anaA = 1:length(algoFolders)
	algo = algoFolders(anaA).name;
	if strcmp(algo, '.') || strcmp(algo, '..') || ~algoFolders(anaA).isdir
		continue;
	end
	
	% Add to the current list of algorithms
	algos{length(algos)+1} = algo;
	
	load([fbgStatsFolder '/' algo '/' fbgStatsFile]);

	for anaD = 1:length(fbgDatasets)
		dataset = fbgDatasets(anaD);
		
		% See if we have this dataset yet
		found = -1;
		for i = 1:length(datasets)
			if strcmp(datasets{i}, dataset)
				found = i;
			end
		end
		if found < 0
			found = length(datasets)+1;
			datasets{found} = dataset;
		end
	end
end

% Initialize the arrays that hold the data
for i = 1:length(datasets)
	resAccuracy{i} = {};
	resTrainTime{i} = {};
	resTestTime{i} = {};
    resTotalTime{i} = {};
	resTrainMem{i} = {};
	resTestMem{i} = {};
    resTotalMem{i} = {};
	resModelSize{i} = {};
	for j = 1:length(algos)
		resAccuracy{i}{j} = [];
		resTrainTime{i}{j} = [];
		resTestTime{i}{j} = [];
        resTotalTime{i}{j} = [];
		resTrainMem{i}{j} = [];
		resTestMem{i}{j} = [];
        resTotalMem{i}{j} = [];
		resModelSize{i}{j} = [];
	end
end

% Load the files, calculate the results, and store
for anaA = 1:length(algos)
	algo = algos(anaA);
	
	fbgOutFolder = [fbgStatsFolder '/' algo{1} '/'];
	load([fbgStatsFolder '/' algo{1} '/' fbgStatsFile]);

	for anaD = 1:length(fbgDatasets)
		dataset = fbgDatasets(anaD);
		dataset = dataset{1};
		
		% See if we have this dataset yet
		index = -1;
		for i = 1:length(datasets)
			if strcmp(datasets{i}, dataset)
				index = i;
			end
		end	
		
		if index < 0 || index > length(datasets)
			fprintf('Error, index out of bounds');
			return;
		end
		
		for anaR = 1:fbgNumRuns
			itr = ['_' int2str(anaR)];
			
			% This is where any training data should get saved
			fbgTrainDataFile = [fbgOutFolder fbgTrainDataStr dataset itr '.mat'];
			fbgTrainMemFile = [fbgOutFolder fbgTrainMemStr dataset itr '.txt'];
			fbgTestMemFile = [fbgOutFolder fbgTestMemStr dataset itr '.txt'];
			fbgAccuracyFile = [fbgOutFolder fbgAccuracyStr dataset itr '.txt'];
			fbgTrainTimeFile = [fbgOutFolder fbgTrainTimeStr dataset itr '.txt'];
			fbgTestTimeFile = [fbgOutFolder fbgTestTimeStr dataset itr '.txt'];
			fbgTrainSizeFile = [fbgOutFolder fbgTrainSizeStr dataset itr '.txt'];
			
			fbgMethod = algos(anaA);
			fbgMethod = fbgMethod{1};
			load([fbgStatsFolder '/' fbgMethod '/' fbgStatsFile]);
			
			accuracy = load(fbgAccuracyFile);
			trainTime = load(fbgTrainTimeFile) / fbgNumTrainImgs * 1000;
			testTime = load(fbgTestTimeFile) / fbgNumTestImgs * 1000;
			resAccuracy{index}{anaA} = [resAccuracy{index}{anaA} accuracy];
			resTrainTime{index}{anaA} = [resTrainTime{index}{anaA} trainTime ];
			resTestTime{index}{anaA} = [resTestTime{index}{anaA} testTime];
            resTotalTime{index}{anaA} = [resTotalTime{index}{anaA} trainTime+testTime];
			
			f = dir(fbgTrainDataFile);
			modelSize = f(1).bytes / 1024 / 1024;
			load(fbgTrainDataFile); % gets fbgCountImgMem
			if exist(fbgTrainSizeFile, 'file')
				modelSize = modelSize + load(fbgTrainSizeFile) / 1024 / 1024;
			end
			resModelSize{index}{anaA} = [resModelSize{index}{anaA} modelSize];
			
			trainMem = -1;
			if exist(fbgTrainMemFile, 'file')
				trainMem = load(fbgTrainMemFile);
				trainMem = (mean(trainMem(2:end)) - trainMem(1) + fbgCountImgMem) / 1024 / 1024;
			end
			resTrainMem{index}{anaA} = [resTrainMem{index}{anaA} trainMem];

			testMem = -1;
			if exist(fbgTestMemFile, 'file')
				testMem = load(fbgTestMemFile);
				testMem = (mean(testMem(2:end)) - testMem(1)) / 1024 / 1024;
				testMem = testMem + modelSize;				
			end
			resTestMem{index}{anaA} = [resTestMem{index}{anaA} testMem];
            
            totalMem = trainMem+testMem;
            resTotalMem{index}{anaA} = [resTotalMem{index}{anaA} totalMem];
		end
	end
end

% Combine each evaluation in to a single variable
table = {};
table{1} = resAccuracy;
table{2} = resTrainTime;
table{3} = resTestTime;
table{4} = resTotalTime;
table{5} = resTrainMem;
table{6} = resTestMem;
table{7} = resTotalMem;
table{8} = resModelSize;

% Transfer cell array table into a 3D array results
% results = zeros(length(table), length(algos), length(datasets));
results = zeros(length(table), length(datasets), length(algos));
xlabels = {};
legends = {};
for i = 1:length(table)
	for j = 1:length(algos)
		for k = 1:length(datasets)
			results(i, k, j) = table{i}{k}{j};
			xlabels{k} = upper(datasets{k}{1});
		end
		legends{j} = upper(regexprep(algos{j}, '_', ' '));
	end
end

colors = [
    255 0 0;        % Red
    0 255 0;        % Green
    0 0 255;        % Blue
    221 113 219;    % Purple
    209 207 32;     % Green yellow
    0 201 203;      % Cyan
    85 85 85;       % Dark Grey
    255 162 0       % Orange
    ];
colors = colors ./ 255;

% Example plotting code
close all
for i = 1:size(results,1)
	if i == 1, figure, else, clf, end
	data = squeeze(results(i, :, :));
	% Supid squeeze hack compressing our data too much
	if length(algos) == 1
		data = data';
	end
    hold on;
    for j = 1:length(algos)
        plot(data(:,j), '-o', 'LineWidth', 2, 'Color', colors(j,:));
	end
	
	yl = ylim;
	if i == 1
		ylim([0 100]);
	elseif yl(1) > 0
		ylim([0 yl(2)]);
	end
    hold off;
	%plot(data, '-o', 'LineWidth', 2);
    if(strcmp(titles{i}, 'Accuracy (%)'))
        legend(legends, 'Location', 'NorthEastOutside');
        %set(gca, 'Position', [100,100,600,300]);
    else
        legend(legends, 'Location', 'NorthWest');
    end
	title(sprintf('%s vs. Datasets', titles{i}), 'FontSize', 15, 'FontWeight', 'bold');
    xlabel('Datasets', 'FontSize', 15, 'FontWeight', 'bold');
    ylabel(titles{i}, 'FontSize', 15, 'FontWeight', 'bold');
	set(gca,'XTickLabel', xlabels, 'FontSize', 12)
	set(gca,'XTick',[1:length(xlabels)]);
    
%     print(gcf, '-djpeg90', '-r300', filename);
    filename = sprintf('%s/plots/%s.eps', fbgStatsFolder, fileNames{i});
    print(gcf, '-depsc', filename);
	filename = sprintf('%s/plots/%s.jpg', fbgStatsFolder, fileNames{i});
    print(gcf, '-djpeg', filename);
end
close
%close all;

% Log data to CSV file
fp = fopen([fbgStatsFolder '/report.csv'], 'wb');
for anaI = 1:length(table)
	fprintf(fp, '%s\n', titles{anaI});
	
	fprintf(fp, 'Dataset, ');
	for anaD = 1:length(datasets)
		fprintf(fp, '%s, ', upper(datasets{anaD}{1}));
	end
	fprintf(fp, '\n');
	
	for anaA = 1:length(algos)
		algo = algos(anaA);

		fprintf(fp, '%s, ', algo{1});
		for anaD = 1:length(datasets)
			val = table{anaI}{anaD}{anaA};
			if val < 100
				fprintf(fp, '%0.1f, ', val);
			else
				fprintf(fp, '%0.0f, ', val);
			end
		end
		fprintf(fp, '\n');
	end
	
	fprintf(fp, '\n');
end
fclose(fp);

% Clean up
%clear i j found index itr table fp normFaces titles;
