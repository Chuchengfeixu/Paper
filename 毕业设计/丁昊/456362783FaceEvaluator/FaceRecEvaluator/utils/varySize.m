% For testing purposes only
% This script runs fbRun for increasing sizes of the image in an attempt to
% see what happens to recognition rates as the image size is changed.
% Inital results suggest that there is only a very slight drop in accuracy
% from high (>60) pixel images to low (<20) pixel images. 

clear

sizes = fliplr([64 45 33 25 20 18 15 12]);
mkdir('varyVecResults');

fbInit;

datasets = fbgDatasets;
algos = fbgAlgorithms;

vsAcc = {};

for vsA = 1:length(algos)
	for vsD = 1:length(datasets)
		for vsI = 1:length(sizes)
			fbgOutFolder = [fbgStatsFolder '/' algos{vsA} '/'];
			fbgAccuracyFile = [fbgOutFolder fbgAccuracyStr datasets{vsD} '1.txt'];
			fbDoNotInit = 1; % Don't re-init
			fbgImgSide = sizes(vsI);
			fbgDatasets = {''};
			fbgDatasets{1} = datasets{vsD};
			fbgAlgorithms = {''};
			fbgAlgorithms{1} = algos{vsA};
			fprintf('Face Size: %d\n', fbgImgSide);
			
			save('varyVecResults/varySize.mat', 'sizes', 'vsI', 'datasets', 'vsD', 'vsAcc', 'vsA', 'algos');
			fbRun;
			load('varyVecResults/varySize.mat');

			acc = load(fbgAccuracyFile);
			fprintf('%s %s %d => %f\n', algos{vsA}, datasets{vsD}, sizes(vsI), acc);
			vsAcc{vsD}{vsA}{vsI} = acc;
		end
	end
end

save('varyVecResults/varySize.mat', 'sizes', 'vsI', 'datasets', 'vsD', 'vsAcc', 'vsA', 'algos');