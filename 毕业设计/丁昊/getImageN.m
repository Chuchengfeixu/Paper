 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Face Recognition Evaluator -> getImageN: Gets a single image, converts it
% to grayscale, and resizes it (optionally normalizes it).
%
% [img] = getImageN(path, file, side, keepAspectRatio)
%
% 'path'            - Path to the image
% 'file'            - Name of the face image to load
% 'side'            - Resize so the largest side is this
% 'keepAspectRatio' - Keeps the aspect ratio when resizing
%
% 'img'             - The output image
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

function [img] = getImageN(path, file,keepAspectRatio)
	um=100;
	ustd=80;
	normalize = 1; % Don't normalize, already done
	runDCT = 0;
	runHomomorph = 0;
	
	%默认保持图像长宽比
	if nargin == 3
		keepAspectRatio = 1;
    end
	    
    %读入图像
	img = imread([path '\' file.name]);
	[rows, cols, channels] = size(img);
	if channels == 3
		img = rgb2gray(img);
	end
    
    img = double(img);
    
    %%
	if normalize
		temp=reshape(img, rows*cols,1);
        m=mean(temp);
        st=std(temp);
        img=reshape((temp-m)*ustd/st+um,rows,cols);
    end
	
    if runHomomorph
		img = filterHomomorph(img);
	end
	
	if runDCT
		img = dct2(img);
    end
