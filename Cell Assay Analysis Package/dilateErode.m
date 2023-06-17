function[further_dilation_] = dilateErode(image, strel_size_2)
        se = strel('disk',strel_size_2);
        %dilate
        bw_dilated = imdilate(image, se); 
        %create the image complement so that we can fill holes on the *border* of the
        %image using area opening
        complement1 = imcomplement(bw_dilated);    
        border_holes_filled = bwareaopen(complement1,8000);
    
        %change back to original (non-complement) image so that we can get rid of
        %cells in gap
        bw_dilated2 = imcomplement(border_holes_filled);
        %fill in holes not on border
        bw_filled = imfill(bw_dilated2,'holes');  
     
        %erode
        bw_eroded = imerode(bw_filled,se); %erode image back to original size
    
        % Final Area opening to get rid of debris in gap
        bw_final = bwareaopen(bw_eroded,2000); 
    
        %create complement so gap can be measured as an *object*
        further_dilation_ = imcomplement(bw_final);
        
        % Display the final binary image with the strel size used
        figure; colormap gray
        imagesc(further_dilation_);
end