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

	%�����һ��ͼ���Ի��ͼ��ߴ�(ͬʱ���лҶȡ��ߴ��һ��)
    %Ĭ�ϻҶȹ�һ��Ĭ�Ϲ�һ��ƽ�����Ⱥ����ȷ���(��������Homomorphic Filtering�����������)
    %�ߴ��һ����ͼ�񳤱ߴ�С��Ϊ����ֵ�����ֳ����
	img = getImageN(path, files(1), side);
	[rows, cols] = size(img); 

	%��������ͼƬ����ʾ������
	len = length(files);
	numDots = 50;
	if fbgVerbose
		begLine = sprintf('Loading %d pictures', len);
		fprintf('%s\n', [begLine repmat(' ', 1, numDots - length(begLine) + 1) '|'])
    end

	dots = 0;
	if rowVecFlag %ͼƬ����Ϊ��λ�洢
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
    else %ͼƬ����Ϊ��λ�洢
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
	
	%ȷ�Ͻ�������ʾ����
	if fbgVerbose
		while dots <= 50
			fprintf('.');
			dots = dots + 1;
		end
	fprintf('|\n');
	end
	
return