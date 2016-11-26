%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%main: 人脸识别测试平台
%pca算法(主成分分析)可给出若干的最优结果，
%但svm算法（支持向量机）只能给出一个结果,因此CountTopX变量暂时未使用
%似乎基于lda的方法总体上好于pca
%lda+-svm似乎影响不大
%pca算法默认去除前10个特征向量（因其主要表示亮度），但若不去除将大幅提高识别率
%需要测试不同尺度下,pca特征向量个数下...的识别率并绘制曲线
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
clear all
close all

%%
%指定数据库
DataSetsPath='.\datasets';
Datasets={'ORL'};             %{'AR','ORL','ExtendedYaleB'}
%指定识别算法
Algorithms={'SRC'};% {'SRC','GSRC','fGSRC'}      
%Algorithms={'pca', 'batch_ccipca', 'ind_ccipca', 'ica', 'lda' , 'libsvm', 'pca_libsvm', 'lda_libsvm', 'isvm','pca_mayi'};
%Algorithms={'batch_ilda', 'ccipca_libsvm', 'ilda_libsvm', 'ilda', 'ind_batch_ccipca', 'ica_libsvm'};
%全局参数
ImgNormSize=18;                 %图片归一化缩放后的最大边长度,我的程序中基本用不到这个，都是直接在getImageN.m修改,
                                %ImgNormSize这个参数在getImageN.m里面有
TrainPercent=50;                %训练数据所占比例(近似)
RandSelectTrainFaces=1;         %是否随机选择训练数据
RunTimes=1;                     %各算法在同一数据库上的运行次数(当训练库选择随机时可用于生成统计结果)
CountTopX=1;                    %如果正确结果在前X个识别结果中,认为是正确识别
MinImgsPerUser=5;               %数据库中每个人的最少图                                  片数(少于该值的视为无效)taiwan_crop=5

%输出选择的数据库和算法信息
fprintf('Using Datasets: [%s',Datasets{1});
for i=2:length(Datasets)
	fprintf(', %s',Datasets{i});
end
fprintf(']\n');
fprintf('Running Algorithms: [%s',Algorithms{1});
for i=2:length(Algorithms)
	fprintf(', %s',Algorithms{i});
end
fprintf(']\n\n');

%%
%依次在指定数据库上测试指定算法
cell_AllResult=[];%存放所有算法在不同数据库中每次的识别结果
for iter_dataset=1:length(Datasets)
	dataset=Datasets{iter_dataset};
    
    %在每个数据库上各算法执行RunTimes次
    for iter_runtimes=1:RunTimes 	
        %按指定比例（随机）分割为训练和测试图片（图片命名规则为:ID-index.jpg）
        c=clock;seed=c(end)+iter_runtimes;clear c;%指定随机数产生器种子
        imagepath=[DataSetsPath '/' dataset];
        %注意图片格式的修改，是jpg还是其他格式？
        [TrainFiles,TestFiles,Ids]=getTrainTestSet(imagepath,TrainPercent,'jpg',seed,MinImgsPerUser,RandSelectTrainFaces);
        fprintf('->split train/test [%d/%d%%]=[%d/%d]of %d peoples in [%s], run [%d]...\n',TrainPercent,100-TrainPercent,length(TrainFiles),length(TestFiles),length(Ids),dataset,iter_runtimes);

        %读入训练数据
        %将训练图片以列为单位存储为矩阵并归一化(rgb2gray,resize,normalize)
        %归一化方法参考: http://www.pages.drexel.edu/~sis26/Eigenface%20Tutorial.htm
        rowVecFlag=0;   %图片以列为单位存储
        Verbose=0;   %不显示中间信息
        [TrainImgs,TrainIds,AvgFace]=batchPictures(imagepath,TrainFiles,ImgNormSize,rowVecFlag,Verbose);
                % Get the rows & cols for the pictures loaded对于一些用得到长和宽的算法可以保留这2个参数
				tmpImg = getImageN(imagepath, TrainFiles(1), ImgNormSize);
				[fbgRows, fbgCols] = size(tmpImg);
				clear tmpImg;
        fprintf('->load [%d] training image...\n',length(TrainIds));
        %读入测试数据
        rowVecFlag=0;
        Verbose=0;
        [TestImgs,TestIds]=batchPictures(imagepath,TestFiles,ImgNormSize,rowVecFlag,Verbose);
        fprintf('->load [%d] testing  image...\n',length(TestIds));

        %在相同数据库上依次运行不同算法
        for iter_algorithm=1:length(Algorithms)
            tStart=tic;
            Method=Algorithms{iter_algorithm};

            %--------------------------------------------------------------
            %执行训练
            if(strcmp(Method,'pca'))
                numVectors=143;             %取前numVectors个eigenvectors作为eigenfaces
                 eigWeights=[];              %各eigenvectors上投影权重(pca算法默认去除前10个特征向量)→default
                %eigWeights=ones(1,1000);    %如果全取的话会大幅提高识别率!!!
                [v,trainWeights]=train_pca(TrainImgs,TrainIds,AvgFace,numVectors,eigWeights);
            elseif(strcmp(Method,'SRC'))  %列的归一化
                TrainImgs=train_SRC(TrainImgs);
            end
			
            %--------------------------------------------------------------
            %执行测试
            if(strcmp(Method,'pca'))
                [resultIds]=test_pca(TestImgs,AvgFace,CountTopX,v,trainWeights,TrainIds);
            elseif(strcmp(Method,'SRC'))  
                dim=40;
                [resultIds]=test_SRC(TestImgs,TrainImgs,TestIds,TrainIds,dim); 
            end
            %--------------------------------------------------------------
            %统计识别率
            if(CountTopX>1)
                resultMatrix=(resultIds==repmat(TestIds,1,CountTopX));
                results=max(resultMatrix,[],2);
            else
                resultMatrix=(resultIds==TestIds);%识别正确的为1,错误的为0
                results=max(resultMatrix,[],2);
            end
            correct=find(results==1);                       %获得识别正确的测试图像索引
            Accuracy=100*length(correct)/size(TestIds,1);	%计算正确识别率
            
            tElapsed=toc(tStart);
            fprintf('\t->%0.2f%% accuracy from "%10s" on dataset "%s" in %.3fs\n',Accuracy,Method,dataset,tElapsed);
            
            %--------------------------------------------------------------
            %记录测试结果
            cell_Result{iter_runtimes}.id=resultIds;
            cell_Result{iter_runtimes}.trainfile=TrainFiles;
            cell_Result{iter_runtimes}.trainid=TrainIds;
            cell_Result{iter_runtimes}.testfile=TestFiles;
            cell_Result{iter_runtimes}.testid=TestIds;
            cell_Result{iter_runtimes}.accuracy=Accuracy;
            
            cell_AllMethod{iter_algorithm}.method=Method;
           cell_AllMethod{iter_algorithm}.result{iter_runtimes}=cell_Result{iter_runtimes};%修改的部分
            
            cell_AllResult{iter_dataset}.dataset=dataset;
            cell_AllResult{iter_dataset}.allmethod=cell_AllMethod;
            
            %--------------------------------------------------------------
            %输出错误识别的测试图像和对应训练图像→以便于发现问题
        			
        end %for iter_algorithm=1:length(Algorithms)
        fprintf('\n');
    end  %for iter_runtimes=1:RunTimes
    
end %for iter_dataset=1:length(Datasets)
% save('allresult.mat','*');

%%
%测试结果统计
% clear all
% load('allresult.mat');

%统计各算法在不同数据库上的平均识别率(各算法100次以上随机识别结果才有意义!)
n_dataset=length(cell_AllResult);
for iter_dataset=1:n_dataset
    fprintf('results on dataset [%s]:\n',cell_AllResult{iter_dataset}.dataset);
    n_method=length(cell_AllResult{iter_dataset}.allmethod);
    for iter_algorithm=1:n_method
        avgaccuracy=0;
        n_runtime=length(cell_AllResult{iter_dataset}.allmethod{iter_algorithm}.result);
        for iter_runtimes=1:n_runtime
            avgaccuracy=avgaccuracy+cell_AllResult{iter_dataset}.allmethod{iter_algorithm}.result{iter_runtimes}.accuracy;
        end
        avgaccuracy=avgaccuracy/n_runtime;
        fprintf('\taverage accuracy of [%15s] on [%d] tests: [%.3f%%]\n',cell_AllResult{iter_dataset}.allmethod{iter_algorithm}.method,n_runtime,avgaccuracy);  
    end
end

%生成html报告
 %bcorrect=0;%1:产生正确识别的报告; 0:产生错误识别的报告
% genHtmlReport(cell_AllResult,DataSetsPath,bcorrect);

%需要显示处理后图像而不是原始图像→以便观察→todo