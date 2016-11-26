
if reduce
	load('ssb_v.mat'); % load v
	fbgTestImgs = v'*fbgTestImgs;
end

% Normalize
fbgTestImgs = fbgTestImgs / 255;

right = 0;
for i = 1:length(fbgTestIds)
	img = fbgTestImgs(:, i);
	id = fbgTestIds(i);
	
	% We want to pairwise classification across all possible people
	testIds = 1:length(fbgIds);
	% Compete a pair, remove the loser, repeat until we have only one left
	while length(testIds) > 1
		c1 = testIds(1);
		c2 = testIds(end);
		
		a = A{c1}{c2-c1};
		b = B{c1}{c2-c1};
		%g = G{c1}{c2-c1};
		ind = IND{c1}{c2-c1};
		%uing = UIND{c1}{c2-c1};
		%x_mer = X_MER{c1}{c2-c1};
		y_mer = Y_MER{c1}{c2-c1};
		%rs = RS{c1}{c2-c1};
		%q = Q{c1}{c2-c1};
		ix = IX{c1}{c2-c1};
		
		x_mer = fbgTrainImgs(:,ix);
		
		[f,K] = svmeval(img, a,b,ind,x_mer,y_mer,type,scale);
		%f
		if f <= 0
			% c1 wins so remove c2 from the end of the array
			testIds = testIds(1:end-1);
		else
			% c2 wins so remove c1 from the beginning of the array
			testIds = testIds(2:end);
		end
	end
	
	% Last class left standing wins
	winner = fbgIds(testIds(1));
	
	%fprintf('%d => %d\n', find(fbgIds == id), testIds(1));
	
	if winner == id
		right = right + 1;
	end
end

fbgAccuracy = 100 * right / length(fbgTestIds);

return;

for i = 1:length(fbgIds)
	c1 = i;
	
	for j = i:length(fbgIds)
		c2 = 2;
		
		testIndex1 = find(fbgTestIds == fbgIds(c1));
		testIndex2 = find(fbgTestIds == fbgIds(c2));

		testData1 = fbgTestImgs(:, testIndex1);
		testData2 = fbgTestImgs(:, testIndex2);
		testClass1 = repmat(-1, size(testIndex1));
		testClass2 = repmat(1, size(testIndex2));
		testData = [testData1 testData2];
		testClass = [testClass1; testClass2];

		[f,K] = svmeval(testData, a,b,ind,X_mer,y_mer,type,scale);
		results = sign(f);
	end
end

x = 1;
