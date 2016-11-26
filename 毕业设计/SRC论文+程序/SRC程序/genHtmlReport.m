function genHtmlReport(cell_AllResult,DataSetsPath,bcorrect)

htmlfilename='report.html';
fp=fopen(htmlfilename,'wb');
if fp
	fprintf(fp,'<html><head><title>Face Recognition Test Report</title></head><body>\n');
    
    n_dataset=length(cell_AllResult);
    for iter_dataset=1:n_dataset
        dataset=cell_AllResult{iter_dataset}.dataset;
        n_method=length(cell_AllResult{iter_dataset}.allmethod);
        for iter_algorithm=1:n_method
            method=cell_AllResult{iter_dataset}.allmethod{iter_algorithm}.method;
            n_runtime=length(cell_AllResult{iter_dataset}.allmethod{iter_algorithm}.result);
            for iter_runtimes=1:n_runtime
                resultIds   =cell_AllResult{iter_dataset}.allmethod{iter_algorithm}.result{iter_runtimes}.id;
                TestIds     =cell_AllResult{iter_dataset}.allmethod{iter_algorithm}.result{iter_runtimes}.testid;
                TestFiles   =cell_AllResult{iter_dataset}.allmethod{iter_algorithm}.result{iter_runtimes}.testfile;
                TrainIds    =cell_AllResult{iter_dataset}.allmethod{iter_algorithm}.result{iter_runtimes}.trainid;
                TrainFiles  =cell_AllResult{iter_dataset}.allmethod{iter_algorithm}.result{iter_runtimes}.trainfile;
                accuracy    =cell_AllResult{iter_dataset}.allmethod{iter_algorithm}.result{iter_runtimes}.accuracy;
    
                resultMatrix=(resultIds==TestIds);%识别正确的为1,错误的为0
                incorrect=find(resultMatrix==bcorrect);
                
                %打印信息
                fprintf(fp,'<body>================================================================================<br></body>');                
                fprintf(fp,'<body> <b><font color="#FF0000">[%s]</font></b> on dataset <b><font color="#FF0000">[%s]</font></b> run [%d/%d]: <br></body>',method,dataset,iter_runtimes,n_runtime);
                fprintf(fp,'<body> >>[%d] train images, [%d] test images  <br></body>',length(TrainIds),length(TestIds));
                fprintf(fp,'<body> >><b><font color="#FF0000">[%d]</font></b> incorrect recognized, accuracy=><font color="#FF0000">%.3f%%</font>  <br></body>',length(incorrect),accuracy);
                %打印表头
                fprintf(fp,'<table>');
                fprintf(fp,'<tr> <td>test</td> <td></td> <td>id</td> <td></td> <td>recog to...</td> </tr>');              
                for i=1:length(incorrect)
                    %打印识别错误的图像
                    filename=TestFiles(incorrect(i)).name;
                    filename=[DataSetsPath '/' dataset '/' filename];
                    fprintf(fp,'<tr> <td><img src="%s" /></td> <td>%d</td> <td>=></td> <td>%d</td>',filename,TestIds(incorrect(i)),resultIds(incorrect(i)));
                    %打印识别结果
                    id_reg=resultIds(incorrect(i));
                    id_reg_train=find(TrainIds==id_reg);
                    for j=1:length(id_reg_train)
                        filename=TrainFiles(id_reg_train(j)).name;
                        filename=[DataSetsPath '/' dataset '/' filename];
                        fprintf(fp, '<td><img src="%s"/></td>', filename);
                    end
                    fprintf(fp,'</tr>\n');
                end 
                fprintf(fp, '</table></body></html>');
    
            end
        end
    end
	fclose(fp);
end
open(htmlfilename);