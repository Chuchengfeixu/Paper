% Test on two classes

% Don't clear the training images, they form our support vectors
fbgClearTrainImgs = 0;

type = 1;
scale = 1;
C = 1;

dosvmtrain2 = 0;
dorealinc = 1;
reduce = 0;

if reduce
	load('liz_v.mat'); % load v
	fbgTrainImgs = v'*fbgTrainImgs;
end

% svmFolder = 'isvm';
% if ~exist(svmFolder, 'dir')
% 	mkdir(svmFolder);
% end
% 
% svmUserFolder = sprintf('%s/%s', svmFolder, fbgDataset);
% if ~exist(svmUserFolder, 'dir')
% 	mkdir(svmUserFolder);
% end

% Normalize between [0...1]
fbgTrainImgs = fbgTrainImgs / 255;

A = cell(length(fbgIds),1);
B = cell(length(fbgIds),1);
IND = cell(length(fbgIds),1);
Y_MER = cell(length(fbgIds),1);
IX = cell(length(fbgIds),1);

for i = 1:length(fbgIds)
	c1 = i;
	
	A{i} = cell(length(fbgIds)-i,1);
	B{i} = cell(length(fbgIds)-i,1);
	IND{i} = cell(length(fbgIds)-i,1);
	Y_MER{i} = cell(length(fbgIds)-i,1);
	IX{i} = cell(length(fbgIds)-i,1);
	
	for j = i+1:length(fbgIds)
		c2 = j;

		trainIndex1 = find(fbgTrainIds == fbgIds(c1));
		trainIndex2 = find(fbgTrainIds == fbgIds(c2));
		trainIndex = [trainIndex1; trainIndex2];
		trainClass1 = repmat(-1, size(trainIndex1));
		trainClass2 = repmat(1, size(trainIndex2));
		%trainData1 = fbgTrainImgs(:, trainIndex1);
		%trainData2 = fbgTrainImgs(:, trainIndex2);
		trainData = fbgTrainImgs(:, trainIndex);
		trainClass = [trainClass1; trainClass2];

		if dosvmtrain2
			[a,b,g,ind,uind,x_mer,y_mer,rs,q] = svmtrain2(trainData, trainClass, C, type, scale);
		elseif ~dorealinc
			[a,b,g,ind,uind,x_mer,y_mer,rs,q] = isvmtrain(trainData, trainClass, C, type, scale);
		else
			[a,b,g,ind,uind,x_mer,y_mer,rs,q] = isvmtrain(trainData(:, 1), trainClass(1), C, type, scale);
			for m = 2:length(trainClass)
				[a,b,g,ind,uind,x_mer,y_mer,rs,q] = isvmtrain(trainData(:, m), trainClass(m), C);
			end
		end
		A{i}{j-i} = a;
		B{i}{j-i} = b;
		IND{i}{j-i} = ind;
		Y_MER{i}{j-i} = y_mer;
		
		% Don't really need these except to retrain
		%G{i}{j-i} = g;
		%RS{i}{j-i} = rs;
		%Q{i}{j-i} = q;
		%UIND{i}{j-i} = uind;
		%X_MER{i}{j-i} = x_mer;
		
		ix = zeros(size(x_mer,2),1);
		len = size(trainData,1);
		for m = 1:size(x_mer,2)
			for n = m:size(trainData,2)
				if sum(x_mer(:,m) == trainData(:,n)) == len
					ix(m) = trainIndex(n);
					break;
				end
			end
			if ix(m) == 0
				fprintf('Error: Should have found support vector already!\n');
				for n = 1:n
					if x_mer(:,m) == trainData(:,n)
						ix(m) = trainIndex(n);
						break;
					end
				end
			end
		end
		
		IX{i}{j-i} = ix;
		
		clear a b g ind uind x_mer y_mer rs q;
	end
end

fbgTrainMem{1} = {A B IND Y_MER IX};
fbgTrainMem{2} = fbgIds;