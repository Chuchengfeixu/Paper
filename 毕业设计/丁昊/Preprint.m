fprintf('Using Database:  <');                %输出所选择的数据库
for i=1:length(Databases)
    fprintf(' %s',Databases{i});
end
fprintf(' >\n');

fprintf('Using algorithm: <');               %输出所选择的算法
for i=1:length(Algorithms)  
    fprintf(' %s',Algorithms{i});
end
fprintf(' >\n\n');