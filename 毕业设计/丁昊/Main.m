%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%main: ���ڷ���ϡ�������ʶ��������
%������������зֱ���в��ԣ�AR��ORL��ExtendedYaleB
%������SRC��pca��lda������ʶ�𷽷�����׼ȷ�ԱȽ�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
clear all
close all

%%
DataBasePath='.\datasets';                      %ָ������ͼ��·��
Databases={'AR','ORL','ExtendedYaleB'};                              %ָ�����ݿ�(�������ݿ⣺'AR','ORL','ExtendedYaleB')
Algorithms={'pca'};                             %ָ���㷨(������ʹ����SRC,pca,lda���ַ�����������ʶ��)

%ȫ�ֲ���
RunningTimes=10;                                 %ÿ��ָ�����ݿ����㷨�����д���
TrainRatio=50;                                  %ѵ������ռ���ݿ�ı�����ѵ������Խ���㷨׼ȷ��Խ��
threshold=5;                                    %����ͼ������ֵ�������в��ԣ�ÿ��Id��Ӧ��ͼ������ٸ���
CountTopX=1;

Preprint;                                       %ǰ�����

%%
%�㷨����                         
for perdatabase=1:length(Databases)             %��ÿ��ָ�������ݿ�����㷨
    
    database=Databases{perdatabase};             %��ȡ��ǰ���ݿ⵽dataset
    imgpath=[DataBasePath '/' database];         %����imgpathΪ��ǰ���ݿ����·��
    
    %��ͼƬ��Ϊѵ��ͼ�������ͼ��
    [TrainFaces,TestFaces,Ids]=DivideTrainTest(imgpath,TrainRatio,'jpg',threshold);
    
    for perrunningtime=1:RunningTimes           %ÿ�����ݿ⣬�㷨ִ��ָ������
        
        %��ѵ��ͼ�����еķ�ʽ����
        [TrainImgs,TrainIds,AvgFace]=batchPictures(imgpath,TrainFaces);
			tmpImg = getImageN(imgpath, TrainFaces(1));
			[fbgRows, fbgCols] = size(tmpImg);
        [TestImgs,TestIds]=batchPictures(imgpath,TestFaces);
        Secprint;                               %�����Ϣ
        
        for peralgorithm=1:length(Algorithms)   %����ÿ��ָ���㷨
            
            tStart=tic;                         %��ʱ��ʼ
            algorithm=Algorithms{peralgorithm};
            
            if(strcmp(algorithm,'pca'))         %pca�㷨
                numVectors1=143;                 %ȡǰnumVectors��eigenvectors��Ϊeigenfaces
                eigWeights=[];                  %��eigenvectors��ͶӰȨ�أ�pca�㷨Ĭ��ȥ��ǰ10����������
                %eigWeights=ones(1,1000);       %���ȫȡ�Ļ��������ʶ����
                [v1,trainWeights1]=train_pca(TrainImgs,TrainIds,AvgFace,numVectors1,eigWeights);%ִ��ѵ��
                [resultIds]=test_pca(TestImgs,AvgFace,CountTopX,v1,trainWeights1,TrainIds);    %ִ�в���
                
            elseif(strcmp(algorithm,'lda'))     %lda�㷨
                numVectors2=100;
                [v2,trainWeights2]=train_lda(fbgRows,fbgCols,TrainImgs,TrainIds,AvgFace,numVectors2)           %ִ��ѵ��
                [resultIds]=test_pca(TestImgs,AvgFace,CountTopX,v1,trainWeights1,TrainIds);    %ִ�в���

            elseif(strcmp(algorithm,'SRC'))     %SRC�㷨
                [TrainImgs]=train_SRC(TrainImgs);                                              %ִ�в���
                dim=40;
                [resultIds]=test_SRC(TestImgs,TrainImgs,TestIds,TrainIds,dim);               %ִ��ѵ��
            end
            
            %--------------------------------------------------------------
            %ͳ��ʶ����
            if(CountTopX>1)
                resultMatrix=(resultIds==repmat(TestIds,1,CountTopX));
                results=max(resultMatrix,[],2);
            else
                resultMatrix=(resultIds==TestIds);%ʶ����ȷ��Ϊ1,�����Ϊ0
                results=max(resultMatrix,[],2);
            end
            correct=find(results==1);                       %���ʶ����ȷ�Ĳ���ͼ������
            Accuracy=100*length(correct)/size(TestIds,1);	%������ȷʶ����
            
            tElapsed=toc(tStart);
            fprintf('\t->%0.2f%% accuracy from "%s" on dataset "%s" in %.3fs\n',Accuracy,algorithm,database,tElapsed);
            
            %-------------------------------------------------------------
            %�����н�����棬������������
            cell_Result{perrunningtime}.id=resultIds;
            cell_Result{perrunningtime}.trainface=TrainFaces;
            cell_Result{perrunningtime}.trainid=TrainIds;
            cell_Result{perrunningtime}.testface=TestFaces;
            cell_Result{perrunningtime}.testid=TestIds;
            cell_Result{perrunningtime}.accuracy=Accuracy;            
            cell_AllMethod{peralgorithm}.algorithm=algorithm;
            cell_AllMethod{peralgorithm}.result{perrunningtime}=cell_Result{perrunningtime};%�޸ĵĲ���            
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











