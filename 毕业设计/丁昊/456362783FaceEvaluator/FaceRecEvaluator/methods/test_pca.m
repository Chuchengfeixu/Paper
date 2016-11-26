%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Face Recognition Evaluator -> test_pca.m: Tests/recognizes the original
% 'eigenface' method using Principal Component Analysis (PCA). Test images
% are projected into the eigenspace created by the training process and are
% then matched to their nearest neighbor in the trained face weights. The
% nearest trained face provides the classification for the test face.
%
% This is usually called during a fbRun, you will need to set fgbAccuracy
% in order for the fbRun script to calculate the accuracy. A number of
% variables are  already loaded and ready:
%  - fbgAccuracy: You must set this with the accuracy of the method
%  - fbgTestImgs: The testing images, arranged in columns.
%  - fbgTestIds: The IDs of the testing images (identity of faces)
%  - fbgAverageFace: The mean face of all the training images
%  - fbgRows/fbgCols: The size of images trained on
%  - fbgTrainMem: Store any training memory necessary to do recognition
%    here in cell arrays
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Authors:                           Brian C. Becker @ www.BrianCBecker.com
% Copyright (c) 2007-2008          Enrique G. Ortiz @ www.EnriqueGOrtiz.com
%
% License: You are free to use this code for academic and non-commercial
% use, provided you reference the following paper in your work.
%
% Becker, B.C., Ortiz, E.G., "Evaluation of Face Recognition Techniques for 
% Application to Facebook," in Proceedings of the 8th IEEE International
% Automatic Face and Gesture Recognition Conference, 2008.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Normalize testing images by removing training mean face
for i = 1:size(fbgTestImgs,2)
	fbgTestImgs(:,i) = fbgTestImgs(:,i) - fbgAvgFace;
end

% Project faces into eigenspace by getting weights of each test face's
% representation as a linear combination of the eigenfaces.
testWeights = v'*fbgTestImgs;

% Now we have the weights of the training images and the testing images. We
% can classify by doing a nearest neighbor approach. For each test image,
% we "recognize" it by assigning it the identity of the closest matching
% training face. We have a special script that does it because it is so
% common. fbgAccuracy is set in the process.
classify_nearest;

% Don't want defaults hanging around
if resetNumVectors, clear numVectors; end
if resetEigWeights, clear eigWeights; end