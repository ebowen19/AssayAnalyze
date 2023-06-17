
analysisPackageDirectory = "..."; %directory in which you downloaded the Cell Assay Analysis Package from Github
addpath(analysisPackageDirectory); 
filePath1 = "..."; %folder with the photos you want to analyze
fileList = dir(fullfile(filePath1, '*.tif')); %can modify type of photo (file extension) for the program to search for / analyze within filePath1
filePath2 = "..."; %folder where you want to store excel file output table
tableName = "..."+'.xls'; %name you want for output table 

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

