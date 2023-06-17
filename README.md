# AssayAnalyze by Elizabeth Bowen
A Matlab tool for computationally analyzing scratch and transwell assays
- *Scratch Assay:* Measures the number of pixels in the gap and exports that data to an excel file
- *cellCounter* Counts the number of individual cells in a transwell assay photo
  - **cellCounter.mlx** is a more user-friendly version of the script (live script version) that can only be used/viewed inside of Matlab. Once opened in matlab, navigate to the "VIEW" tab at the top of the window and select the "Hide Code" option. Then fill in the empty fields according to the instructions to the right. 
  - **cellCounter.m** is a script that can be viewed in github. The ... fields must be filled in by the user.
    - *analysisPackageDirectory* should specify the folder/directory where you downloaded the AssayAnalyze Package
    - *filePath1* should specify the folder with the images that you want to analyze
    - within the *fileList* variable, you can modify the extension to pecify the type of file (photo--tif,jpg,etc) that you want the program to identify & analyze within the *filePath1* folder
    - *filePath2* should specify the directory in which to create/look for the excel table that will be created by the program & store the image montages created.
    - *tableName* should specify the excel file where you want to store the analysis stats. If such a file does not exist withinthe *filePath2* folder, it will be created by the program
