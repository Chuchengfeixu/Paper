
% 搜索当前目录下的图片统一resize    
          files=dir('*.jpg');
   for i=1:length(files)
        ImgTmp=imread(files(i).name);
        ImgTmp=imresize(ImgTmp,[165,120],'bilinear');
        imwrite(ImgTmp,['F:\学习\陈天娇 试验程序\datasets\ExtendedYaleB\YALEB\',files(i).name]);
   end