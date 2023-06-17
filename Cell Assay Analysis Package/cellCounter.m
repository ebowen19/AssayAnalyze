
analysisPackageDirectory = "..."; 
addpath(analysisPackageDirectory); 
filePath1 = "..."; 
fileList = dir(fullfile(filePath1, '*.tif'));  
filePath2 = "...";
tableName = "..."+'.xls'; 

% Extract the filenames from the structure
filenames = {fileList.name}'
%iterate through images in the specified folder
for i = 1:length(filenames)
    cd (filePath1);
    imgTitle = string(filenames(i));
    [analysisStats,C] = countCells(imgTitle, filePath2, tableName);
end


fprintf('This table is stored as %s in %s:', tableName, filePath2)
analysisStats

