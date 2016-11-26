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

function [trainFaces,testFaces,ids]=getTrainTestSet(path,trainPercent,ext,omitThresh)

    files=dir([path '/*.' ext]);
	
    %指定数据库文件夹下无任何文件
	if isempty(files)
		trainFaces = 0;
		testFaces = 0;
		ids = 0;
		return;
	end
    
	%将数据库中所有图片按照命名方式进行解析并将解析结果存放在all中
    ids = [];
    all = [];
    for i = 1:length(files)
        %从文件名称中解析出该图片的身份索引和该身份的当前图片索引
        [all(i).id, all(i).num] = getID(files(i).name);
        all(i).file = files(i);
	end
    
	%将all中的信息以人为单位存放在everybody中
    %everybody中的一个元素对应该人的所有图片及相关信息
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
    
    rand('twister',mod(floor(now*8640000),2^31-1));

	%将每个人的图片按照指定比例（随机）分割为训练部分和测试部分
    ctr = 1;
    for i = 1:size(everybody,2)
        len = length(everybody(i).face);
        
        %若库中某人的图片数量少于给定阈值,则忽略该人
        if len < omitThresh
            continue;
        end
        
        ids(ctr) = str2double(everybody(i).id);
        ctr = ctr + 1;
        
		%分割训练和测试部分
                        %非随机选取
            indexes = 1:len;
        
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