%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Face Recognition Evaluator -> make.m: Makes libsvm MEX interface for
% Matlab. The original libsvm MEX suffers from large memory overhead,
% passing the model back and forth between C and Matlab. This is a slightly
% modified version that offers more options to reduce the overhead of
% passing data back and forth. It also reduces replicated data. 
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

% This make.m is used under Windows

% Unload libsvm mex dll so we can (re)compile it
clear mexexp

mex -O -g methods/ica/mexexp.c

% This only keeps the folder structure organized
files = {'mexexp.obj', 'mexexp.mexw32.pdb', 'mexexp.ilk', 'mexexp.mexw32', 'mexexp.mexw64.pdb', 'mexexp.mexw64'};
for i = 1:length(files)
	if exist(['./' files{i}], 'file')
		if exist(['methods/ica/' files{i}])
			delete(['methods/ica/' files{i}]);
		end
		
		movefile(['./' files{i}], ['methods/ica/' files{i}]);
	end
end
