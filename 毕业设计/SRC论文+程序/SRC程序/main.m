%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%main: ����ʶ�����ƽ̨
%pca�㷨(���ɷַ���)�ɸ������ɵ����Ž����
%��svm�㷨��֧����������ֻ�ܸ���һ�����,���CountTopX������ʱδʹ��
%�ƺ�����lda�ķ��������Ϻ���pca
%lda+-svm�ƺ�Ӱ�첻��
%pca�㷨Ĭ��ȥ��ǰ10������������������Ҫ��ʾ���ȣ���������ȥ����������ʶ����
%��Ҫ���Բ�ͬ�߶���,pca��������������...��ʶ���ʲ���������
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
clear all
close all

%%
%ָ�����ݿ�
DataSetsPath='.\datasets';
Datasets={'ORL'};             %{'AR','ORL','ExtendedYaleB'}
%ָ��ʶ���㷨
Algorithms={'SRC'};% {'SRC','GSRC','fGSRC'}      
%Algorithms={'pca', 'batch_ccipca', 'ind_ccipca', 'ica', 'lda' , 'libsvm', 'pca_libsvm', 'lda_libsvm', 'isvm','pca_mayi'};
%Algorithms={'batch_ilda', 'ccipca_libsvm', 'ilda_libsvm', 'ilda', 'ind_batch_ccipca', 'ica_libsvm'};
%ȫ�ֲ���
ImgNormSize=18;                 %ͼƬ��һ�����ź�����߳���,�ҵĳ����л����ò������������ֱ����getImageN.m�޸�,
                                %ImgNormSize���������getImageN.m������
TrainPercent=50;                %ѵ��������ռ����(����)
RandSelectTrainFaces=1;         %�Ƿ����ѡ��ѵ������
RunTimes=1;                     %���㷨��ͬһ���ݿ��ϵ����д���(��ѵ����ѡ�����ʱ����������ͳ�ƽ��)
CountTopX=1;                    %�����ȷ�����ǰX��ʶ������,��Ϊ����ȷʶ��
MinImgsPerUser=5;               %���ݿ���ÿ���˵�����ͼ                                  Ƭ��(���ڸ�ֵ����Ϊ��Ч)taiwan_crop=5

%���ѡ������ݿ���㷨��Ϣ
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
%������ָ�����ݿ��ϲ���ָ���㷨
cell_AllResult=[];%��������㷨�ڲ�ͬ���ݿ���ÿ�ε�ʶ����
for iter_dataset=1:length(Datasets)
	dataset=Datasets{iter_dataset};
    
    %��ÿ�����ݿ��ϸ��㷨ִ��RunTimes��
    for iter_runtimes=1:RunTimes 	
        %��ָ��������������ָ�Ϊѵ���Ͳ���ͼƬ��ͼƬ��������Ϊ:ID-index.jpg��
        c=clock;seed=c(end)+iter_runtimes;clear c;%ָ�����������������
        imagepath=[DataSetsPath '/' dataset];
        %ע��ͼƬ��ʽ���޸ģ���jpg����������ʽ��
        [TrainFiles,TestFiles,Ids]=getTrainTestSet(imagepath,TrainPercent,'jpg',seed,MinImgsPerUser,RandSelectTrainFaces);
        fprintf('->split train/test [%d/%d%%]=[%d/%d]of %d peoples in [%s], run [%d]...\n',TrainPercent,100-TrainPercent,length(TrainFiles),length(TestFiles),length(Ids),dataset,iter_runtimes);

        %����ѵ������
        %��ѵ��ͼƬ����Ϊ��λ�洢Ϊ���󲢹�һ��(rgb2gray,resize,normalize)
        %��һ�������ο�: http://www.pages.drexel.edu/~sis26/Eigenface%20Tutorial.htm
        rowVecFlag=0;   %ͼƬ����Ϊ��λ�洢
        Verbose=0;   %����ʾ�м���Ϣ
        [TrainImgs,TrainIds,AvgFace]=batchPictures(imagepath,TrainFiles,ImgNormSize,rowVecFlag,Verbose);
                % Get the rows & cols for the pictures loaded����һЩ�õõ����Ϳ���㷨���Ա�����2������
				tmpImg = getImageN(imagepath, TrainFiles(1), ImgNormSize);
				[fbgRows, fbgCols] = size(tmpImg);
				clear tmpImg;
        fprintf('->load [%d] training image...\n',length(TrainIds));
        %�����������
        rowVecFlag=0;
        Verbose=0;
        [TestImgs,TestIds]=batchPictures(imagepath,TestFiles,ImgNormSize,rowVecFlag,Verbose);
        fprintf('->load [%d] testing  image...\n',length(TestIds));

        %����ͬ���ݿ����������в�ͬ�㷨
        for iter_algorithm=1:length(Algorithms)
            tStart=tic;
            Method=Algorithms{iter_algorithm};

            %--------------------------------------------------------------
            %ִ��ѵ��
            if(strcmp(Method,'pca'))
                numVectors=143;             %ȡǰnumVectors��eigenvectors��Ϊeigenfaces
                 eigWeights=[];              %��eigenvectors��ͶӰȨ��(pca�㷨Ĭ��ȥ��ǰ10����������)��default
                %eigWeights=ones(1,1000);    %���ȫȡ�Ļ��������ʶ����!!!
                [v,trainWeights]=train_pca(TrainImgs,TrainIds,AvgFace,numVectors,eigWeights);
            elseif(strcmp(Method,'SRC'))  %�еĹ�һ��
                TrainImgs=train_SRC(TrainImgs);
            end
			
            %--------------------------------------------------------------
            %ִ�в���
            if(strcmp(Method,'pca'))
                [resultIds]=test_pca(TestImgs,AvgFace,CountTopX,v,trainWeights,TrainIds);
            elseif(strcmp(Method,'SRC'))  
                dim=40;
                [resultIds]=test_SRC(TestImgs,TrainImgs,TestIds,TrainIds,dim); 
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
            fprintf('\t->%0.2f%% accuracy from "%10s" on dataset "%s" in %.3fs\n',Accuracy,Method,dataset,tElapsed);
            
            %--------------------------------------------------------------
            %��¼���Խ��
            cell_Result{iter_runtimes}.id=resultIds;
            cell_Result{iter_runtimes}.trainfile=TrainFiles;
            cell_Result{iter_runtimes}.trainid=TrainIds;
            cell_Result{iter_runtimes}.testfile=TestFiles;
            cell_Result{iter_runtimes}.testid=TestIds;
            cell_Result{iter_runtimes}.accuracy=Accuracy;
            
            cell_AllMethod{iter_algorithm}.method=Method;
           cell_AllMethod{iter_algorithm}.result{iter_runtimes}=cell_Result{iter_runtimes};%�޸ĵĲ���
            
            cell_AllResult{iter_dataset}.dataset=dataset;
            cell_AllResult{iter_dataset}.allmethod=cell_AllMethod;
            
            %--------------------------------------------------------------
            %�������ʶ��Ĳ���ͼ��Ͷ�Ӧѵ��ͼ����Ա��ڷ�������
        			
        end %for iter_algorithm=1:length(Algorithms)
        fprintf('\n');
    end  %for iter_runtimes=1:RunTimes
    
end %for iter_dataset=1:length(Datasets)
% save('allresult.mat','*');

%%
%���Խ��ͳ��
% clear all
% load('allresult.mat');

%ͳ�Ƹ��㷨�ڲ�ͬ���ݿ��ϵ�ƽ��ʶ����(���㷨100���������ʶ������������!)
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

%����html����
 %bcorrect=0;%1:������ȷʶ��ı���; 0:��������ʶ��ı���
% genHtmlReport(cell_AllResult,DataSetsPath,bcorrect);

%��Ҫ��ʾ�����ͼ�������ԭʼͼ����Ա�۲��todo