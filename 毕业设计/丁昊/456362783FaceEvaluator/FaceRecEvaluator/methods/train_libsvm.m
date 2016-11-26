% Needed if not using a linear kernel
%fbgTrainImgs = fbgTrainImgs ./ 255;

fbgTrainImgs = fbgTrainImgs';
libsvm(OPT_SET_DATA, fbgTrainIds, fbgTrainImgs, '-t 0 -c 1 -g 0.07 -m 2000');
clear fbgTrainImgs;
libsvm(OPT_TRAIN);
libsvm(OPT_SAVE, 'svm_model.dat');

f = dir('svm_model.dat');
fbgTrainMemSize = f(1).bytes;