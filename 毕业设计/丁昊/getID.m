%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Face Recognition Evaluator -> getID: The identify of a face is encoded
% directly into the filename of each image. For instance, image 2-1.pgm
% means that this is the first face image of person 2. This function breaks
% a filename up into the individual parts for you.
%
% [id, num] = getID(filename)
%
% 'filename' - Name of the face image file
%
% 'id'       - Identity of the face image (who the face belongs to)
% 'num'      - The number of the face (1st face, 2nd face, 100th face)
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

function [id, num] = getID(filename)
    A = strsplit('-', filename);
    B = strsplit('.', A{2});
    id = A{1};
    num = B{1};
end