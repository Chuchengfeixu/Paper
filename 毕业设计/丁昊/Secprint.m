
%输出训练，测试比例，总人数，数据库以及运行次数的信息
fprintf('Train: %d%%(%d)  Test: %d%%(%d)\n%d peoples in [%s], run [%d]...\n\n',TrainRatio,length(TrainFaces),100-TrainRatio,length(TestFaces),length(Ids),database,perrunningtime);

%输出训练和测试人数信息
fprintf('->load [%d] training image...\n',length(TrainIds));
fprintf('->load [%d] testing  image...\n',length(TestIds));
