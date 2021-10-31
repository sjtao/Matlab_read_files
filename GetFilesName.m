cd 'C:\VSrunning\MOC\MOC3D_energygroup'; %folder path
listing = dir('src');
filename = extractfield(listing,'name');
fileID = fopen('codefile_summary.txt','w');
for i = 1 : size(filename,2)
    name = char(filename(i));
    tr1 = strcmp(name,'.');
    tr2 = strcmp(name,'..');
    if tr1 ~= 1 && tr2 ~= 1
        fprintf(fileID, '%s \n', name);
    end
end
fclose(fileID);
fclose('all');
fprintf('Done. \n');
