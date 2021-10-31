cd 'W:\ecn.data\Personal\STao\data_pichuli'; %folder path
listing = dir('result_files');
filename = extractfield(listing,'name');
cd 'result_files'
fileID = fopen('result_summary.txt','w');
for i = 1 : size(filename,2)
    name = char(filename(i));
    tr1 = strcmp(name,'.');
    tr2 = strcmp(name,'..');
    if tr1 ~= 1 && tr2 ~= 1
        text = fileread(name);
        fprintf(fileID, '%s : \n%s \n', name, text);
    end
end

fclose(fileID);
fclose('all');
movefile('result_summary.txt', 'W:\ecn.data\Personal\STao\data_pichuli'); %move the result file to a new location 
fprintf('Done. \n');
cd ..
