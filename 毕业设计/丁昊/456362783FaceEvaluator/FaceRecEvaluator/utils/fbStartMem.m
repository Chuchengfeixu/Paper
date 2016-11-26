%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Face Recognition Evaluator -> fbStartMem: Starts an external script that
% monitors the memory usage of Matlab. Should work under Windows and Linux
% although I haven't tested it under Linux in a while. Note that on
% Windows, a separate window console pops up, which is annoying. This can
% be fixed, but it would take too much effort on my part. 
%
% This works by querying the memory of Matlab periodically (5-15 Hz) and
% dumping the results to a file. At each cycle, the script checks for the
% existence of a "done" file to determine if it should stop.
%
% IMPORTANT: Only ONE Matlab process must be running for this to work!
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

if exist(fbgDoneFile, 'file');
    delete(fbgDoneFile);
end

% Run the script that monitors the memory usage of matlab
% IMPORTANT: Make sure only one Matlab is running!!!
% Memory consumption measurement may not be completely accurate due to the
% various OS handling of virtual memory and reporting reserved/actual mem
% The scripts run until a done file is written
if fbgPlatform == LINUX
	system(['sh "' fbgShellFolder '/' fbgLinMemScript '" "' fbgMemFile '"&']);
else
	system(['"' fbgShellFolder '/' fbgWinMemScript '" "' fbgMemFile '" ' fbgDoneFile ' &']);
end

% Make sure we launch the script and get a good reading before doing
% anything else
pause(5)