clear
forlda = false;

% Very important!!!
clear ids everybody allFiles;

ego = false;
if ego
    path = '..\..\..\_at&t\';
else
    user = 'G:\fb\ssb\';
    %user = 'c:\fbego\';
    %user = 'c:\fbssb\';
    
    %path = [user '_allfaces\'];
    %path = [user 'a7_csu\'];
	path = 'D:\facerec\data\fbtest\_test\a7_allfaces\';

    ext = 'jpg';
    %ext = 'pgm';    
    %ext = 'png';
    
    %path = 'c:\fborg2\_manual\';        
    %path = 'c:\fborg2\_at&t\';    
end

%outpath = [user 'a7_csu\'];
outpath = 'D:\facerec\data\fbtest\_test\_csu7\';

side = 100;
trainPercent = 60;
randSeed = 0; % -1 means use random seed
numVectors = 100;
threshold = -1;
genpic = true;

seed = randSeed;

fpCoords = fopen([outpath 'coords.txt'], 'wb');
fpTrain = fopen([outpath 'train.srt'], 'wb');
fpTest = fopen([outpath 'test.srt'], 'wb');
fpAll = fopen([outpath 'all.srt'], 'wb');

if forlda
    omitThresh = 5; % Omit people with less than this # of face images
else
    omitThresh = 0;
end

files = dir([path '*.' ext]);

ids = [];    
for i = 1:length(files)
    [all(i).id, all(i).num] = getID(files(i).name);
    all(i).file = files(i);
end

for i = 1:size(all,2)
    if i == 1
        everybody(1).id = all(1).id;
        everybody(1).face(1) = all(1);
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
    end
end

rand('seed', seed);

ctr = 1;
for i = 1:size(everybody,2)
    len = length(everybody(i).face);

    if len < omitThresh
        continue;
    end

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
        fprintf(fpTrain, '%s ', regexprep(trainFaces(index).name, 'pgm', 'sfi'));
        fprintf(fpAll, '%s ', regexprep(trainFaces(index).name, 'pgm', 'sfi'));
        
        allFiles(ctr) = trainFaces(index);
        ctr = ctr + 1;
    end
    for j = 1:length(testIndex)
        if exist('testFaces') == 0 %i == 1 && j == 1
            index = 1;
        else
            index = length(testFaces)+1;
        end
        testFaces(index) = everybody(i).face(testIndex(j)).file;
        fprintf(fpAll, '%s ', regexprep(testFaces(index).name, 'pgm', 'sfi'));
        fprintf(fpTest, '%s\n', regexprep(testFaces(index).name, '.pgm', ''));
        
        allFiles(ctr) = testFaces(index);
        ctr = ctr + 1;
    end
    
    fprintf(fpTrain, '\n');
    fprintf(fpAll, '\n');
end

for i = 1:length(allFiles)
     img = imread([path allFiles(i).name]);
     outfilename = regexprep(allFiles(i).name, 'pgm', 'pgm');
 	[rows, cols, channels] = size(img);
% 	if channels == 3
% 		img = rgb2gray(img);
%     end
%     imwrite(img, [outpath outfilename], 'MaxValue', 255, 'Encoding', 'rawbits');
    
    fprintf(fpCoords, '%s %d %d %d %d\n', regexprep(allFiles(i).name, ['.' ext], ''), int32(cols/2*0.70), int32(rows/2*0.70), int32(cols - cols/2*0.70), int32(rows/2*.70));
end

fclose(fpCoords);
fclose(fpTrain);
fclose(fpTest);
fclose(fpAll);