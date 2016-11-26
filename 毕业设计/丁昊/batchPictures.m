%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Face Recognition Evaluator -> batchPictures: Loads a list of files into a
% single matrix, calculating the average as well. All images must be the
% same size for this to work.
%
% [pics,id,avg] = batchPictures(path, files, side, rowVecFlag)
% 
% 'path'       - Path to the files
% 'files'      - List of files to load
% 'side'       - Resizes largest side to this, preserving aspect ratio
% 'rowVecFlag' - Load images as rows (vs columns)
% 'fbgVerbose' - Be quiet when running (no progress bar as images load)
%
% 'pics'       - Matrix of images, with each image in a row/column
% 'id'         - The ID of each image (person the face belongs to)
% 'avg'        - The mean face calculated from the loaded pictures
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [pics,id,avg] = batchPictures(path, files)

	id = ones(length(files), 1);

	%�����һ��ͼ���Ի��ͼ��ߴ�(ͬʱ���лҶȡ��ߴ��һ��)
    %Ĭ�ϻҶȹ�һ��Ĭ�Ϲ�һ��ƽ�����Ⱥ����ȷ���(��������Homomorphic Filtering�����������)
    %�ߴ��һ����ͼ�񳤱ߴ�С��Ϊ����ֵ�����ֳ����
	img = getImageN(path, files(1));
	[rows, cols] = size(img);

	%��������ͼƬ
	len = length(files);
	numDots = 50;
	dots = 0;	
	pics = zeros(rows*cols,length(files));

    %����Ϊ��λ����ͼƬ
	for i = 1:len
		if i / len > dots / numDots
     	   dots = dots + 1;
           
	    end       
		img = getImageN(path, files(i));
	    pics(:,i) = reshape(img',1,rows*cols);
	    id(i) = str2double(getID(files(i).name));

		avg = mean(pics ,2);
    end
	
return