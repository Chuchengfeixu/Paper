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

function [img] = getImageN(path, file, side, keepAspectRatio)
	um=100;
	ustd=80;
	normalize = 1; % Don't normalize, already done
	runDCT = 0;
	runHomomorph = 0;
	
	% By default, keep the aspect ratio
	if nargin == 3
		keepAspectRatio = 1;
	end
	
	img = imread([path '/' file.name]);
	[rows, cols, channels] = size(img);
	if channels == 3
		img = rgb2gray(img);
	end
    
    img = double(img);
    
	% Normalize if turned on, this normalization from
	% http://www.pages.drexel.edu/~sis26/Eigenface%20Tutorial.htm
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

	% Resize image
	if side ~= -1 & [rows, cols] ~= [side, side]
        if keepAspectRatio
            if rows >= cols
                img = imresize(img, [side, NaN], 'bilinear');
            else
                img = imresize(img, [NaN, side], 'bilinear');
            end
        else
            img = imresize(img, [side, side], 'bilinear');
        end
	end
end