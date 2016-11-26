d = 'D:\facerec\data\bcb\_csu7\';
f = dir([d '*.pgm']);

% Randomize
f = f(randperm(length(f)));

numX = 8;
numY = 6;
numS = 3;
hw = 128;

back = zeros(numY*hw, numX*hw);
ctr = 1;
for i = 1:numS
	for m = 1:numY
		for n = 1:numX
			img = imread([d f(ctr).name]);
			ctr = ctr + 1;
			img = imresize(img, [hw hw]);
			back(1+(m-1)*hw:m*hw, 1+(n-1)*hw:n*hw) = img;
			%imshow(back ./ max(back(:)));
			%drawnow
		end
	end
	imshow(back ./ max(back(:)));
	drawnow
	
	imwrite(back ./ max(back(:)), sprintf('back%d.jpg', i));
end