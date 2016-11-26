%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%main: 基于分组稀疏的人脸识别主程序
%在三个数组库中分别进行测试：AR，ORL，ExtendedYaleB
%测试了SRC，pca，lda的人脸识别方法进行准确性比较
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
clear all
close all

%%
DataBasePath='.\datasets';                      %指定人脸图像路径
Databases={'AR','ORL','ExtendedYaleB'};                              %指定数据库(三个数据库：'AR','ORL','ExtendedYaleB')
Algorithms={'pca'};                             %指定算法(本程序使用了SRC,pca,lda三种方法进行人脸识别)

%全局参数
RunningTimes=10;                                 %每个指定数据库上算法的运行次数
TrainRatio=50;                                  %训练数据占数据库的比例，训练比例越大，算法准确度越高
threshold=5;                                    %人脸图像数阈值，即进行测试，每个Id对应的图像的最少个数
CountTopX=1;

Preprint;                                       %前置输出

%%
%算法部分                         
for perdatabase=1:length(Databases)             %在每个指定的数据库测试算法
    
    database=Databases{perdatabase};             %读取当前数据库到dataset
    imgpath=[DataBasePath '/' database];         %设置imgpath为当前数据库访问路径
    
    %将图片分为训练图像与测试图像
    [TrainFaces,TestFaces,Ids]=DivideTrainTest(imgpath,TrainRatio,'jpg',threshold);
    
    for perrunningtime=1:RunningTimes           %每个数据库，算法执行指定次数
        
        %将训练图像按照列的方式储存
        [TrainImgs,TrainIds,AvgFace]=batchPictures(imgpath,TrainFaces);
			tmpImg = getImageN(imgpath, TrainFaces(1));
			[fbgRows, fbgCols] = size(tmpImg);
        [TestImgs,TestIds]=batchPictures(imgpath,TestFaces);
        Secprint;                               %输出信息
        
        for peralgorithm=1:length(Algorithms)   %运行每个指定算法
            
            tStart=tic;                         %计时开始
            algorithm=Algorithms{peralgorithm};
            
            if(strcmp(algorithm,'pca'))         %pca算法
                numVectors1=143;                 %取前numVectors个eigenvectors作为eigenfaces
                eigWeights=[];                  %各eigenvectors上投影权重，pca算法默认去除前10个特征向量
                %eigWeights=ones(1,1000);       %如果全取的话会大幅提高识别率
                [v1,trainWeights1]=train_pca(TrainImgs,TrainIds,AvgFace,numVectors1,eigWeights);%执行训练
                [resultIds]=test_pca(TestImgs,AvgFace,CountTopX,v1,trainWeights1,TrainIds);    %执行测试
                
            elseif(strcmp(algorithm,'lda'))     %lda算法
                numVectors2=100;
                [v2,trainWeights2]=train_lda(fbgRows,fbgCols,TrainImgs,TrainIds,AvgFace,numVectors2)           %执行训练
                [resultIds]=test_pca(TestImgs,AvgFace,CountTopX,v1,trainWeights1,TrainIds);    %执行测试

            elseif(strcmp(algorithm,'SRC'))     %SRC算法
                [TrainImgs]=train_SRC(TrainImgs);                                              %执行测试
                dim=40;
                [resultIds]=test_SRC(TestImgs,TrainImgs,TestIds,TrainIds,dim);               %执行训练
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
            fprintf('\t->%0.2f%% accuracy from "%s" on dataset "%s" in %.3fs\n',Accuracy,algorithm,database,tElapsed);
            
            %-------------------------------------------------------------
            %将所有结果储存，方便检验与调用
            cell_Result{perrunningtime}.id=resultIds;
            cell_Result{perrunningtime}.trainface=TrainFaces;
            cell_Result{perrunningtime}.trainid=TrainIds;
            cell_Result{perrunningtime}.testface=TestFaces;
            cell_Result{perrunningtime}.testid=TestIds;
            cell_Result{perrunningtime}.accuracy=Accuracy;            
            cell_AllMethod{peralgorithm}.algorithm=algorithm;
            cell_AllMethod{peralgorithm}.result{perrunningtime}=cell_Result{perrunningtime};%修改的部分            
            cell_AllResult{perdatabase}.database=database;
            cell_AllResult{perdatabase}.allmethod=cell_AllMethod;
            
        end
    end
end

%%
n_dataset=length(cell_AllResult);
for perdatabase=1:n_dataset
    fprintf('results on dataset [%s]:\n',cell_AllResult{perdatabase}.database);
    n_method=length(cell_AllResult{perdatabase}.allmethod);
    for peralgorithm=1:n_method
        avgaccuracy=0;
        n_runtime=length(cell_AllResult{perdatabase}.allmethod{peralgorithm}.result);
        for perrunningtime=1:n_runtime
            avgaccuracy=avgaccuracy+cell_AllResult{perdatabase}.allmethod{peralgorithm}.result{perrunningtime}.accuracy;
        end
        avgaccuracy=avgaccuracy/n_runtime;
        fprintf('\taverage accuracy of [%s] on [%d] tests: [%.3f%%]\n',cell_AllResult{perdatabase}.allmethod{peralgorithm}.algorithm,n_runtime,avgaccuracy);  
    end
end











