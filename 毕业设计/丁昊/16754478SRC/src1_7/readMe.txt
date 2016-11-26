This is the Sparse Representation Toolbox in MATLAB version 1.6.

Sparse Reprsentation:
Kernel sparse coding: KSRSC
Kernel dictionary learning: KSRDL

Classifiers:
The classification methods include
NNLS: nnlsClassifier, bootstrapnnlsClassifier
SRC1: src
SRC2: SRC2
MSRC: computeMetaSample and SRC2
MNNLS(Meta-sample based NNLS): computeMetaSample and nnlsClassifier
LRC: lrc
nearest centroid: nearestCentroidTrain, nearestCentroidPredict
C-SVM and nu-SVM: svmTrain, softSVMTrain2, softSVMPredict2
High Dimensional Linear Machine: khdlmTrain, khdlmPredict
Unified Interface: classificationTrain, classificationPredict

Statistical Test:
Find Significant Accuracy /Error Rate: significantAcc
Fitting Learning Curves: learnCurve
Friedman Test coupled with Nemenyi Test: FriedmanTest
Plot the result of Nemenyi Test: plotNemenyiTest
Leave-M-Out: leaveMOut

Others:
Plot the accuracy / running time of multiple classifiers on multiple datasets: plotBarError.m


Requirement:
1. The codes are written in MATLAB 7.11(2010b). It may also work in earlier version, for example MATLAB 7.9(2009a).
2. For using SRC1: you have to install L1_magic which is available at http://users.ece.gatech.edu/~justin/l1magic
3. For using SRC2: you have to install l1_ls which is available at http://www.stanford.edu/~body/l1_ls

Usage:
Please see the files example*.m for how to use them.
For more parameter seting, please use command HELP in the command line, for example help nnlsClassifier. 

Documentation:
There is no complete documentation by now, I am still working on this. The following references should be very useful for understanding this toolbox. These papers are available in the doc folder.

References:
[1] Yifeng Li and Alioune Ngom, "Sparse representation approaches for the classification of high-dimensional data," BMC Systems Biology. 2013. To appear.
[2] Yifeng Li and Alioune Ngom, "Supervised Dictionary Learning via Non-negative Matrix Factorization for Classification," ICMLA 2012, pp. 439-443.


Contact:
Should you have any question and problem about this toolbox, please contact 
Yifeng Li
School of Computer Science
University of Windsor
Windsor, Ontario, N9B 3P4, Canada
li11112c@uwindsor.ca
yifeng.li.cn@gmail.com

Feb. 28, 2013