function [analysisStats,C] = countCells(imgTitle, filePath, tableName)
img1 = imread(imgTitle); %read in image
img = rgb2gray(img1); %convert to grayscale
img_blurred = imgaussfilt(img);
% imagesc(img_blurred)


% Define the window sizes for variance calculation
windowSizes = [3, 5, 7, 9];
        
% Initialize a mask to store the blurry regions
blurryMask = false(size(img_blurred));

% Calculate variance at different window sizes
for i = 1:numel(windowSizes)
       windowSize = windowSizes(i);
            
       % Calculate the local variance using imfilter and imgaussfilt
       localVariance = imfilter(double(img_blurred).^2, ones(windowSize)/windowSize^2, 'replicate') - imgaussfilt(double(img_blurred), windowSize).^2;
            
       % Find the blurry regions based on variance values
       blurryRegions = localVariance <= 90;
            
       % Accumulate the blurry regions
       blurryMask = blurryMask | blurryRegions;
end
        
% Apply the blurry mask to the original image
blurryImage = img_blurred;
%aboveThresholdMask = img_blurred > graythresh(img_blurred);
%blurryImage(blurryMask & aboveThresholdMask) = 0;  % Set to white

blurryImage(~blurryMask) = 0; %create an image that displays original
% grayscale values of blurry regions, and non-blurry regions set to 0 (black)

    blurryBinary = ~blurryImage; %Binary image where white = blurry regions
    
    brightnessThreshold = 70; % Example threshold value
    
    % Create a binary mask for regions above the brightness threshold
    aboveThresholdMask = img_blurred > brightnessThreshold;
    
    % Set the corresponding regions in 'back' to white
    blurryBinary(aboveThresholdMask) = 1;    

    % Apply a threshold to separate foreground and background
    [thresholded, sensitivity] = adaptiveThreshold(img_blurred); 
    
    thresholded(blurryBinary) = 1;
    bw = thresholded;
   
     
     figure
     colormap gray
%      imshow(bw),  title('Binarized Image')  

    bw2 = imcomplement(bw);
    
%remove small objects to denoise:
denoised = bwareaopen(bw2, 20);
% % %imagesc(denoised), title('Specks Removed')
% labeledImage = bwlabel(denoised);
% % Calculate the properties of the foreground objects
% props = regionprops(labeledImage, denoised, 'Area');
% 
% % Extract the area values of foreground objects
% foregroundAreas = [props.Area];
% 
% %count cells using distinct foreground objects & breaking up area of large
% %clustered objects
% cells = numel(foregroundAreas); %# of foreground objects
% 
% sum(foregroundAreas);
% 
% clusteredCells = foregroundAreas(foregroundAreas > 150); %extract large objects that represent multiple cells clustered tog
% num = numel(clusteredCells); %get # of elements
% cells = cells-num; %remove those from the cell count 
% clusteredArea = sum(clusteredCells); %get total area of clustered cells
% %73 = avg cell size
% cells = round(cells + clusteredArea/73) %add clustered area ÷ avg cell size & round to make whole #


%count cells (foreground objects) 
se = strel('disk', 2);
eroded = imerode(denoised, se);
labeledImage = bwlabel(eroded);
props = regionprops(labeledImage, eroded, 'Area');
foregroundAreas = [props.Area];
cells = numel(foregroundAreas)


cd(filePath)

C = imfuse(eroded,img1,'montage');

S = extractBefore(imgTitle, '.');
fileName = "MONTAGE " + S + '.jpg';
imwrite(C,fileName)



fprintf('Image Montage (Downloaded) [Erosion]: [%s]', fileName)
%imagesc(C)

%create an excel file with tableName if such a file does not already exist;
if ~isfile(tableName) %if the table does not already exist
    colNames = {'Photo Name', 'cell count'};
    data = cell(1,2); % create a cell array with one row and the same number of columns as colNames
    table = [cell2table(colNames, 'VariableNames', colNames); cell2table(data, 'VariableNames', colNames)]
    writetable(table, tableName);
    existingTable = readtable(tableName);
    existingTable(1,:) = []; %remove duplicate column names row
else
    existingTable = readtable(tableName); %no need to remove duplicate col name row in this case
end




newRow = {imgTitle, cells}; 


data = [existingTable;newRow]; %add data from analysis
%T = unique(data,'rows', 'stable'); %make sure there are no duplicate lines
% Find the unique values in PhotoName column
[~, ia, ~] = unique(flipud(data.PhotoName),'rows', 'stable');
ia = size(data,1) - ia + 1;% Select only the rows that contain unique values. If you ran code for
% the same image >1 time, the program will save the most recent version of
analysisStats = flipud(data(ia, :));

writetable(analysisStats, tableName, 'WriteMode', 'overwrite'); %add data to table
end

