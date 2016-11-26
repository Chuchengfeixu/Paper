function [resultIds]=test_GSRC(fbgTestImgs,fbgTrainImgs,fbgTestIds,fbgTrainIds,fbgdim)

[disc_set,disc_value,Mean_Image]  =  Eigenface_f(fbgTrainImgs,fbgdim);  
tr_gdat       =    disc_set'* fbgTrainImgs;
tt_gdat        =    disc_set'* fbgTestImgs;
tr_gdat        =    tr_gdat./ repmat(sqrt(sum(tr_gdat.*tr_gdat)),[size(tr_gdat,1) 1]); % unit norm 2
tt_gdat        =    tt_gdat./ repmat(sqrt(sum(tt_gdat.*tt_gdat)),[size(tt_gdat,1) 1]); % unit norm 2
fbgTrainImgs=tr_gdat;
fbgTestImgs=tt_gdat;

k1= length(unique(fbgTrainIds));%k1表示训练集里面有多少人
testLen = size(fbgTestImgs,2);
resultIds = zeros(testLen,1);
correctLabel = 0;
thr=0.05;%0.05
lambda=15;

for i=1:testLen   
    y = fbgTestImgs(:,i);
    A=fbgTrainImgs;
    n = size(A,2);

cvx_begin
variable xp(n,1)
t1=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for k = 1:k1
t1 =norm(xp(find(fbgTrainIds==k)), 2);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  for k = 1:k1
% t1 = norm(tr_gdat(:,find(fbgTrainIds==k))*xp(find(fbgTrainIds==k)), 2);
%  end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%55%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
minimize( t1 )
subject to
norm(y - A * xp) <= thr;
cvx_end

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
fid1=['accuracy','.txt'];
c=fopen(fid1,'a+');    
fprintf(c,'%f\n',fbgAccuracy);        %%%q为你要写入的数据，“'%f”为数据格式
fclose(c);  