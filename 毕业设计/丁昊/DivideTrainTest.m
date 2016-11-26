%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%[TrainFaces,TestFaces,Ids]=DivideTrainTest(path,TrainRatio,ext,threshold)
%���������ڽ�ͼ�����趨�����ָ�Ϊѵ��ͼ�������ͼ��
%����ѵ���ķ�����ͳ������ʹ�ã�����src�����У�ֻ��Ҫ��ʱ��������ѵ�����ɴ�ɸߵ�ʶ����
%path:          ����ͼ��·��
%TrainRatio:    ���õ�ѵ��������ͼ�������ѵ������Խ�󣬲���׼ȷ��Խ��
%ext:           ����Ѱ��ͼ��ĸ�ʽ
%threshold:     ÿ��Id��Ӧ����ͼ�����ֵ
%TrainFaces:    
%TestFaces:
%Ids:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [TrainFaces,TestFaces,Ids]=DivideTrainTest(path,TrainRatio,ext,threshold);

    files=dir([path '/*.' ext]);
	if isempty(files)       %ָ���ļ�����û����Ѱ�Ҹ�ʽ���ļ����򷵻ؿ�ֵ
		TrainFaces = 0;
		TestFaces = 0;
		Ids = 0;
		return;
	end
    
	%�����ݿ�������ͼƬ����������ʽ���н�������������������all��
    Ids = [];
    all = [];
    for i = 1:length(files)
        %���ļ������н�������ͼƬ����������͸���ݵĵ�ǰͼƬ����
        [all(i).id, all(i).num] = getID(files(i).name);
        all(i).file = files(i);
	end
    
	%��all�е���Ϣ����Ϊ��λ�����everybody��
    %everybody�е�һ��Ԫ�ض�Ӧ���˵�����ͼƬ�������Ϣ
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

	%��ÿ���˵�ͼƬ����ָ��������������ָ�Ϊѵ�����ֺͲ��Բ���
    ctr = 1;
    for i = 1:size(everybody,2)
        len = length(everybody(i).face);
        
        %������ĳ�˵�ͼƬ�������ڸ�����ֵ,����Ը���
        if len < threshold
            continue;
        end
        
        Ids(ctr) = str2double(everybody(i).id);
        ctr = ctr + 1;
        
		%�ָ�ѵ���Ͳ��Բ���
                       
        indexes = randperm(len);    %���ѡȡ
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