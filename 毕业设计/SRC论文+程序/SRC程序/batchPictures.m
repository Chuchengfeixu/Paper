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
%                                                                                                                            
% 'rowVecFlag' - Load images as rows (vs columns)
% 'fbgVerbose' - Be quiet when running (no progress bar as images load)
%
% 'pics'       - Matrix of images, with each image in a row/column
% 'id'         - The ID of each image (person the face belongs to)
% 'avg'        - The mean face calculated from the loaded pictures
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [pics,id,avg] = batchPictures(path, files, side, rowVecFlag, fbgVerbose)

	id = ones(length(files), 1);

	%读入第一个图像以获得图像尺寸(同时进行灰度、尺寸归一化)
    %默认灰度归一化默认归一化平均亮度和亮度方差(还给出了Homomorphic Filtering方法→需测试)
    %尺寸归一化将图像长边大小设为给定值并保持长宽比
	img = getImageN(path, files(1), side);
	[rows, cols] = size(img); 

	%载入其他图片并显示进度条
	len = length(files);
	numDots = 50;
	if fbgVerbose
		begLine = sprintf('Loading %d pictures', len);
		fprintf('%s\n', [begLine repmat(' ', 1, numDots - length(begLine) + 1) '|'])
    end

	dots = 0;
	if rowVecFlag %图片以行为单位存储
		pics = zeros(length(files),rows*cols);

		for i = 1:len
		   if i / len > dots / numDots
			   dots = dots + 1;
			   if fbgVerbose
				   fprintf('.');
                   endd
		   end

		   img = getImageN(path, files(i), side);
		   pics(i,:) = reshape(img',1,rows*cols);
		   id(i) = str2double(getID(files(i).name));
		end

		avg = mean(pics,1);
    else %图片以列为单位存储
		pics = zeros(rows*cols,length(files));

		for i = 1:len

		   if i / len > dots / numDots
			   dots = dots + 1;
			   if fbgVerbose
				   fprintf('.');
			   end
		   end       
		   img = getImageN(path, files(i), side);
		   pics(:,i) = reshape(img',1,rows*cols);
		   id(i) = str2double(getID(files(i).name));
		end    

		avg = mean(pics,2);
	end
	
	%确认进度条显示完整
	if fbgVerbose
		while dots <= 50
			fprintf('.');
			dots = dots + 1;
		end
	fprintf('|\n');
	end
	
return