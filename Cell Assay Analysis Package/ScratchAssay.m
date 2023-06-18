
% Make sure that you're in the folder with the images you want to use
addpath("..."); %add the path to the directory where the Assay Analysis Package is located in your compuater 
filePath = "..."; %folder where images are located
cd (filePath);
fileList = dir(fullfile(filePath, '*.PNG'));  %specify file extension for photos you want to analyze

% Extract the filenames from the structure
filenames = {fileList.name};
photoNumber = length(filenames) %tells you how many photos are in your folder
i =...; %# of the photo inside your folder that you want to analyze  (1st photo, 2nd, 3rd...)
imgTitle = string(filenames(i))
img1 = imread(imgTitle); %read in image
img = rgb2gray(img1); %convert to grayscale
img_blurred = imgaussfilt(img);

%specify one true and one false based on the type of thresholding you want
%to use. 
intensity_threshold = ...;
variance_threshold = ...;  
%Intensity thresholding is good if theres distinction in brightness between the
%cells & gap. Variance thresholding is good if there is not and the background regions
%are identified by blurriness.


if intensity_threshold
  %to run adaptive thresholding, make sure to check adaptice_thresholding,
    %and uncheck manual_thresholding.
    [bw, threshold] = adaptiveThreshold(img_blurred);
    
    disp(['Selected threshold: ' num2str(threshold)])
    bw = imbinarize(img_blurred, 'adaptive', 'Sensitivity', threshold);
    adaptive_sensitivity = threshold;
    
    
    elseif variance_threshold
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


        blurryImage(~blurryMask) = 0; %create an image that displays original
     

    figure
    imagesc(img1)
    figure
    imagesc(blurryImage), colormap gray
    blurryBinary = ~blurryImage; %Binary image where white = blurry regions
    
    brightnessThreshold = 70; % Example threshold value
    
    % Create a binary mask for regions above the brightness threshold
    aboveThresholdMask = img_blurred > brightnessThreshold;
    
    % Set the corresponding regions in 'back' to white
    blurryBinary(aboveThresholdMask) = 1;
    figure, imagesc(blurryBinary), colormap gray
    

    % Apply a threshold to separate foreground and background
    [thresholded, sensitivity] = adaptiveThreshold(img_blurred); 
    
    thresholded(blurryBinary) = 1;
    bw = thresholded;

    

end

     figure
    subplot(1,2,1)
    imshow(img1); 
    title('Original Image');
    subplot(1,2,2)
    imshow(img); colormap gray
    title('Original Image, blurred & converted to grayscale');
   
    
    figure
    colormap gray
    imagesc(bw),  title('Binarized Image')  

%specify true or false based on whether more gap clearing is needed after
%the previous step
skip_clearing = ...; 
strel_size = 4;
    
% Create a structuring element for erosion and dilation
if ~skip_clearing
    se = strel('disk', strel_size); % Change the disk size as needed

    % Perform erosion and dilation
    eroded = imerode(bw, se);
    dilated = imdilate(bw, se);
    
    % Subtract eroded image from dilated image to get the boundaries
    boundaries = imcomplement(dilated - eroded);
    figure
    subplot(1,1,1)
    %imshow(boundaries)
    
    % Fill the holes in the boundaries under a certain size
    filled = imfill(boundaries, 'holes');
    %imshow(filled)
    back = bwareaopen(~filled,3000);
    % Threshold for brightness (adjust as needed)

    imagesc(back), colormap gray,  title('Gap Cleared') 
else
    back = bw;
    strel_size = NaN;
end


%where store data from image analysis (table & montage)
tableName = "..."+'.xls'; %name excel file where you want to store analysis stats
filePath = "...";  %directory in which to create/look for table & to store image montages created
cd(filePath)

minimum_strel = 2;
 
strel_range = minimum_strel:3:60;
[complement, final_strel] = gapSegmentation(back, strel_range); % assign the final image to the var complement

%show the final image & display its strel size used 
main_strel = final_strel; % for stats table


fprintf('[Strel size = %d] compared to original:', final_strel); % label the comparison here so that we have the right value of i (inside a for loop)
figure, colormap gray
subplot(1,2,1);
imagesc(complement), axis image, colormap gray;
subplot(1,2,2);
imagesc(img1), axis image, colormap gray;
final_image = complement;

%produce montage

C = imfuse(final_image,img1,'montage');

S = extractBefore(imgTitle, '.');
fileName = "MONTAGE " + S + '.jpg';
imwrite(C,fileName)



fprintf('Image Montage (Downloaded): [%s]', fileName)
subplot(1,1,1);
imagesc(C), colormap gray

%calculate gap area
stats = regionprops(final_image, 'Area');
    allAreas = [stats.Area];
    gapArea = max(allAreas);  
clipboard('copy',gapArea)  
fprintf('Final Gap Area = %d\n', gapArea)

%create an excel file with tableName if such a file does not already exist;
if ~isfile(tableName) %if the table does not already exist
    colNames = {'Photo Name', 'gap area (pixels)'};
    data = cell(1,2); % create a cell array with one row and the same number of columns as colNames
    table = [cell2table(colNames, 'VariableNames', colNames); cell2table(data, 'VariableNames', colNames)]
    writetable(table, tableName);
    existingTable = readtable(tableName);
    existingTable(1,:) = []; %remove duplicate column names row
else
    existingTable = readtable(tableName); %no need to remove duplicate col name row in this case
end

fprintf('This table is stored as %s in %s:', tableName, filePath)

newRow = {imgTitle, gapArea}; 


data = [existingTable;newRow]; %add data from analysis
%T = unique(data,'rows', 'stable'); %make sure there are no duplicate lines
% Find the unique values in PhotoName column
[~, ia, ~] = unique(flipud(data.PhotoName),'rows', 'stable');
ia = size(data,1) - ia + 1;% Select only the rows that contain unique values. If you ran code for
% the same image >1 time, the program will save the most recent version of
analysisStats = flipud(data(ia, :))

writetable(analysisStats, tableName, 'WriteMode', 'overwrite'); %add data to table

