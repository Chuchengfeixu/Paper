%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%[TrainFaces,TestFaces,Ids]=DivideTrainTest(path,TrainRatio,ext,threshold)
%本程序用于将图像按照设定比例分割为训练图像与测试图像
%这种训练的方法传统而常被使用，但在src方法中，只需要短时，少量的训练即可达成高的识别率
%path:          输入图像路径
%TrainRatio:    设置的训练，测试图像比例，训练比例越大，测试准确度越高
%ext:           设置寻找图像的格式
%threshold:     每个Id对应人脸图像的阈值
%TrainFaces:    
%TestFaces:
%Ids:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [TrainFaces,TestFaces,Ids]=DivideTrainTest(path,TrainRatio,ext,threshold);

    files=dir([path '/*.' ext]);
	if isempty(files)       %指定文件夹下没有欲寻找格式的文件，则返回空值
		TrainFaces = 0;
		TestFaces = 0;
		Ids = 0;
		return;
	end
    
	%将数据库中所有图片按照命名方式进行解析并将解析结果存放在all中
    Ids = [];
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
        if len < threshold
            continue;
        end
        
        Ids(ctr) = str2double(everybody(i).id);
        ctr = ctr + 1;
        
		%分割训练和测试部分
                       
        indexes = randperm(len);    %随机选取
        bound = ceil(TrainRatio/100.0*len);
        if bound >= len
            bound = len - 1;
        end
        trainIndex = indexes(1:bound);
        testIndex = indexes(bound+1:end);
        for j = 1:length(trainIndex)
            if exist('TrainFaces') == 0 %i == 1 && j == 1
                index = 1;
            else
                index = length(TrainFaces)+1;
            end
            TrainFaces(index) = everybody(i).face(trainIndex(j)).file;
        end
        for j = 1:length(testIndex)
            if exist('TestFaces') == 0 %i == 1 && j == 1
                index = 1;
            else
                index = length(TestFaces)+1;
            end
            TestFaces(index) = everybody(i).face(testIndex(j)).file;
        end
    end
end