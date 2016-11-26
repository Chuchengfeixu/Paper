--------------------------------------------------------------------------------
Face Recognition Evaluator Toolbox for MATLAB     Version 1.0, (c) 2008     LGPL
Brian C. Becker (www.BrianCBecker.com)  Enrique G. Ortiz (www.EnriqueGOrtiz.com)
--------------------------------------------------------------------------------
This toolbox for Matlab 2007a and higher lets you test and experiment with many different face recognition algorithms. This toolbox is designed to be a learning tool for introducing well-known algorithms as well as a springboard for testing your own face recognition algorithms against the most common benchmarks used today. You can easily add your own algorithms and/or datasets. Statistics for each run are automatically generated for concise quantitative comparisons of each algorithm.

There isn't a lot of documentation (aside from comments in the MATLAB code) so feel free to ask us questions. If you have comments/bug reports, please do contact us at our respective websites. We are always interested in how you are using this package, so drop us an email.

--------------------------------------------------------------------------------
Features
 - Automatically run multiple algorithms over multiple datasets
 - Highly configurable, many options can be changed in a single file
 - Easy to plug in new datasets/algorithms
 - Graphs and tables generated automatically summarizing run statistics
 - Reported statistics include accuracy (%), computational time (sec), memory consumed (MB), and model size (MB)
 - Tracks RAM memory consumed during training/testing
 - HTML table outputs with nearest matches

--------------------------------------------------------------------------------
Major algorithms included are:
 - PCA (Principal Component Analysis or Eigenfaces)
 - IPCA (Incremental PCA for online learning)
 - LDA (Linear Discriminant Analysis or Fisherfaces)
 - ILDA (Incremental LDA for online learning)
 - SVM (Support Vector Machines)
 - ISVM (Incremental SVMs for online learning)
 - ICA (Independent Component Analysis)
 
Comes with AT&T Database of Faces and the Indian Face Dataset so you can start evaluating right away!
 
--------------------------------------------------------------------------------
Credits: Many different resources were used, see credits.txt for more details.

--------------------------------------------------------------------------------
Usage: Everything is run using fbRun.m. Options are stored in fbInit.m so you can add algorithms/datasets and change various parameters. Individual algorithm parameters are listed in their respective *.m files under the "methods" folder.

Example: 
>> fbRun
Running Face Recognition Evaluator (c) Brian C. Becker & Enrique G. Ortiz
More info at www.BrianCBecker.com and www.EnriqueGOrtiz.com
Running Algorithms: pca, lda
Using Datasets: att, ifd

Separating train/test (60/40%) set images in ./datasets/att/_csu7, run 1...
Training algorithm "pca" on dataset "att"...
Testing algorithm "pca" on dataset "att"...
91.25% accuracy from "pca" on dataset "att" in 0.0 min

Training algorithm "lda" on dataset "att"...
Testing algorithm "lda" on dataset "att"...
94.38% accuracy from "lda" on dataset "att" in 0.0 min

Separating train/test (60/40%) set images in ./datasets/ifd/_csu7, run 1...
Training algorithm "pca" on dataset "ifd"...
Testing algorithm "pca" on dataset "ifd"...
74.17% accuracy from "pca" on dataset "ifd" in 0.0 min

Training algorithm "lda" on dataset "ifd"...
Testing algorithm "lda" on dataset "ifd"...
86.25% accuracy from "lda" on dataset "ifd" in 0.0 min

Algorithm runs done, generating report...
Report generated, check stats/results.csv for details
Face Recognition Evaluator done in 14.2 sec

--------------------------------------------------------------------------------
Dataset Format
The dataset format is pretty easy. Just dump all the grayscale face pictures in a single folder in the format <Person ID>-<Face ID>.jpg (ppms & pngs also supported). Thus 001-01.jpg would be the first face for the first person. The IDs for people and faces don't have to be in order (so 3783-97.jpg might correspond to a 4 digit PID and a year in the case of say a school yearbook). There is no need to divide your data into a train/test set as the system will take care of that for you automatically (you can control the parameter such as the percentage to train/test on).

Currently two datasets are included, the AT&T Database of Faces and the Indian Face Database. Both are unmodified except for conversion to JPEG, resizing, and renaming of the files. If you use your own database we recommend you use the preprocessing normalization techniques outlined by http://www.cs.colostate.edu/evalfacerec/ .

--------------------------------------------------------------------------------
Results
After each run, a "stats" folder is generated with a lot of statistics about all the algorithms run. The main file generated is stats\report.csv which is a table listing the accuracy, training/testing times, training/testing memory consumed, and the storage size of the algorithm models. Also generated are plots which are listed in stats\plots folder. 

One of the most frustating things is running one set of algorithms for a day and then forgetting to save the results before tweaking the parameters and starting a new run. We got tired of doing this and so created a "backup" folder. At the beginning of each run, the "stats" folder is moved into the "backup" folder with the current timestamp. This helps prevent data loss. 

--------------------------------------------------------------------------------
Algorithm Format
Algorithms are stored in the methods folder. Any required libraries by your algorithm can be stored in a folder inside the "methods" folder and it will be automatically added to the path. All algorithms must have a "train_algo.m" and "test_algo.m" where "algo" is the name of your algorithm. There are a number of variables available (fbgTrainImgs, fbgTrainIds, fbgTestImgs, fbgTestIds, fbgAvgFace, etc) that you can use to as the training and test inputs to your algorithm. This makes it nice because you don't have to worry about dividing up your data into test and training sets, it is handled automatically for you. At the end of "test_algo.m" you must set a variable fbgAccuracy (0-100) which the system uses to log accuracies. To run your algorithm, just add it to the fbgAlgorithms cell array in fbInit.m.

For a good example of how to design an algorithm, look at "train_pca.m" and "test_pca.m" from the "methods" folder as they have a lot of good comments outline what is being done and why.

================================================================================