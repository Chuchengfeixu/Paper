%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Face Recognition Evaluator -> fbPreRun: Does some stuff before the main
% running of algorithm (stop memory monitoring, create stats dir, print out
% summary of what fbRun is going to do, etc).
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

% Print header information
fprintf('Running Face Recognition Evaluator (c) Brian C. Becker & Enrique G. Ortiz\n');
fprintf('More info at www.BrianCBecker.com and www.EnriqueGOrtiz.com\n');

% Print the Algorithms being used
fprintf(['Running Algorithms: ' fbgAlgorithms{1}]);
for i = 2:length(fbgAlgorithms)
	fprintf([', ' fbgAlgorithms{i}]);
end
fprintf('\n');

% Print the Datasets we are using
fprintf(['Using Datasets: ' fbgDatasets{1}]);
for i = 2:length(fbgDatasets)
	fprintf([', ' fbgDatasets{i}]);
end
fprintf('\n\n');

if ~exist(fbgTempFolder, 'dir')
	mkdir(fbgTempFolder);
end

if ~exist(fbgBackupFolder, 'dir')
	mkdir(fbgBackupFolder);
end

% Stop the scripts recording the memory usage
% Sorry, I think this kills all shell scripts :'(
% fbStopMem % We don't do this because of the pause
if fbgPlatform == LINUX
	system('killall sh');
else
	tmpNonsense = 0;
	save(fbgDoneFile, 'tmpNonsense');
	clear tmpNonsense;
end

% Create the stats folder if it doesn't exist, back it up if it does
if exist(fbgStatsFolder, 'dir')
	% We went to a lot of work to generate these silly results, don't
	% delete them! Just rename them with the current timestamp
	timestamp = datestr(now);
	timestamp(find(timestamp == ':')) = '.';
	
	% This is retarded, but sometimes Matlab thinks the folder exists after
	% it has been deleted or moved. To remedy this, use a try-catch
	try, movefile(fbgStatsFolder, [fbgBackupFolder '/' fbgStatsFolder ' ' timestamp]); catch, end;
	clear timestamp;
end

% Make new stats folder
mkdir(fbgStatsFolder);

if ~exist('tmp', 'dir')
	mkdir('tmp');
end