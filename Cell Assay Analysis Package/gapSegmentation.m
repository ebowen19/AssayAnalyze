function [complement, final_strel] = gapSegmentation(gap_cleared2, strel_range)
   
    final_strel = max(strel_range) + 1;  % Initialize to a value outside the valid range

    for i = 1:length(strel_range)
        se = strel('disk',strel_range(i));
        %dilate
        bw_dilated = imdilate(gap_cleared2,se); 
        %create the image complement so that we can fill holes on the *border* of the
        %image using area opening... 
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
        bw_final = bwareaopen(bw_eroded,5000); 

        %create complement so gap can be measured as an *object*
        complement = imcomplement(bw_final);

        % Label the connected components in the binary image
        cc = bwconncomp(complement);        
        % Count the number of connected components
        n_components = cc.NumObjects;
        % Check if one single foreground object was created
        if n_components == 1

            % Get object properties of our foreground image
            stats = regionprops(cc,'Area','BoundingBox');
             
        bool = (stats.BoundingBox(2) + stats.BoundingBox(4) > 1 && stats.BoundingBox(2) < size(bw_final, 1) && ...
        stats.BoundingBox(1) > 1 && stats.BoundingBox(1) + stats.BoundingBox(3) < size(bw_final, 2)) 
   

            
            if ~(stats.BoundingBox(2) + stats.BoundingBox(4) > 1 && stats.BoundingBox(2) < size(bw_final, 1) && ...
            stats.BoundingBox(1) > 1 && stats.BoundingBox(1) + stats.BoundingBox(3) < size(bw_final, 2)) 
            % check that the gap (foreground object) isn't touching 
            % the top/bottom of the image anywhere other than somewhere 
            % connected to a corner ((covers case where gap is diagonally
            % oriented)

       
            
            final_strel = strel_range(i);
            break;
            end
        end
    end
end
