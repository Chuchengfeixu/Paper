
%���ѵ�������Ա����������������ݿ��Լ����д�������Ϣ
fprintf('Train: %d%%(%d)  Test: %d%%(%d)\n%d peoples in [%s], run [%d]...\n\n',TrainRatio,length(TrainFaces),100-TrainRatio,length(TestFaces),length(Ids),database,perrunningtime);

%���ѵ���Ͳ���������Ϣ
fprintf('->load [%d] training image...\n',length(TrainIds));
fprintf('->load [%d] testing  image...\n',length(TestIds));
