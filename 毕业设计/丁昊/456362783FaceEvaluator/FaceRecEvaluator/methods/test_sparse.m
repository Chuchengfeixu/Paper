% Normalize the columns of A to have unit l^2-norm.
for i = 1 : size(fbgTestImgs,2)
    fbgTestImgs(:,i) = fbgTestImgs(:,i) / norm(fbgTestImgs(:,i));
end

testLen = size(fbgTestImgs,2);

resultIds = zeros(1,length(testLen));
correctLabel = 0;

Ainv = pinv(fbgTrainImgs);
for i = 1 : 10; %testLen
    % Initial solution to minimize.
    x0 = Ainv * fbgTestImgs(:,i);
    
    % Solve the l1-minimization problem.
%     tic
%     xp = l1eq_pd(x0, fbgTrainImgs, [], fbgTestImgs(:,i), 1e-3);
%     toc

% 	xp = x0;

    % Error tolerance
    epsilon = 0.05;     % 0.05 used in "Robust Face Recognition via Sparse Representation"

    % Solve the li-minimization problem with error tolerance.
    tic
    xp = l1qc_logbarrier(x0, fbgTrainImgs, [], fbgTestImgs(:,i), epsilon, 1e-3);
    toc

    classes = unique(fbgTrainIds(find(xp ~= 0)));
    
    % Initialize storage for residual results
    residuals = zeros(1,length(classes));
    
    % Compute the residuals.
    for j = 1 : length(classes)
        txp = xp;
        txp(find(fbgTrainIds ~= classes(j) & xp ~= 0)) = 0;
        
        residuals(j) = norm(fbgTestImgs(:,i) - fbgTrainImgs * txp);
    end
    
    % Minimum residual error indicates to which class the object (face)
    % belongs.
    [val, ind] = min(residuals);
    resultIds(i) = classes(ind);
	%plot(residuals), [fbgTestIds(i) classes(ind)]
    
    if resultIds(i) == fbgTestIds(i)
        correctLabel = correctLabel + 1;
	end
	
	fprintf('Accuracy: %0.2f (%d out of %d)\n', correctLabel / i * 100, correctLabel, i);
end

fbgAccuracy = 100 * correctLabel / testLen;