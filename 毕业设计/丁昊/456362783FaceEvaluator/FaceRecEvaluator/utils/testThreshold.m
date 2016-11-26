%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Face Recognition Evaluator -> testThreshold: Sees how applying a
% threshold to subspace methods will affect the accuracy. 
%
% Often we want an algorithm to have a target accuracy. For instance, a
% system might not really be that worthwhile unless at least 85% accuracy
% is achieved. Because we are essentially doing a nearest neighbor problem
% for a lot of the algorithms (most of the subspace algorithms such as
% PCA, LDA, etc), we already have distance metrics. The distance metrics
% give us a measure of certainty that we can use. Setting a threshold (if
% the nearest neighbor is a billion light years away, well maybe they
% aren't as related as we thought) will give us a way out. In effect, it
% says "we don't know who this is"
%
% Thus, say for all datasets you want to find a threshold that gives you
% roughly 85% accuracy. This function helps you do it. First set
% fbgMakeAccuracy = 0.85 and then pass it to thiss function after
% classify_nearest. Use an optimizer such as fminsearch to quickly find the
% threshold that gives you the desired accuracy values. This function will
% return the absolute difference between the current and target accuracy,
% thus giving the optimizer a nice triangle function to find the bottom of.
%
% [accuracy, left, index] = testThreshold(t, correct, resultDist, 
%                                         fbgMakeAccuracy, results)
%
% 't'                - The threshold to use
% 'correct'          - The current number of correct using threshold of 0
% 'resultDist'       - The distance between each test image and the match
% 'fbgMakeAccuracy'  - What target accuracy are we aiming for (90%?)
% 'results'          - The results from the classify_nearest script
%
% 'accuracy' - How close we are to the target accuracy (absolute diff).
%              This value will be 0 if we are at the target accuracy.
% 'left'     - The fraction of faces we can classify. 1 - left is the
%              fraction of faces that don't pass the threshold and thus we
%              have to say we don't know who it is.
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

function [accuracy, left, index] = testThreshold(t, correct, resultDist, fbgMakeAccuracy, results)
	index = find(resultDist < t);
	
	% Get the distances for the correct
	c = resultDist(correct);
	% Get the distances for the wrong predictions
	wrong = find(results ~= 1);
	w = resultDist(wrong);

	% Find out how many images pass the distance threshold
	left = length([c(find(c < t)); w(find(w < t))]);
	
	% Calculate the accuracy
	accuracy = length(c(find(c < t))) / left;
	accuracy = abs(accuracy - fbgMakeAccuracy);
	
	% Make the number of faces left into a percentage of the total
	left = left / length(results); 
	
	% Debugging stuff
	%[length(c(find(c < t))) length([c(find(c < t)); w(find(w < t))]) length(c(find(c < t))) / length([c(find(c < t)); w(find(w < t))]) length([c(find(c < t)); w(find(w < t))]) / length(results)]
end