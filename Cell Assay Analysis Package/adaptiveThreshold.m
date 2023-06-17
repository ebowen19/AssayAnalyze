function [bw, final_threshold] = adaptiveThreshold(img_blurred)
    threshold_otsu = graythresh(img_blurred);
    bw_otsu = imbinarize(img_blurred, threshold_otsu);
    
    min_threshold = 0.4; % Minimum threshold value
    max_threshold = 0.9; % Maximum threshold value
    prev_num_small_objects = inf; % Set initial value to infinity
    final_threshold = min_threshold; % Initialize final threshold
    
    for threshold = min_threshold:0.01:max_threshold
        bw = imbinarize(img_blurred, 'adaptive', 'Sensitivity', threshold);
        stats = regionprops('table', bw, 'Area');
        
        num_small_objects = nnz(stats.Area < 6);
        
        if num_small_objects > prev_num_small_objects && mean2(bw) > (mean2(bw_otsu) * 0.7)
            final_threshold = threshold - 0.01;
            break; % Exit loop
        end
        
        prev_num_small_objects = num_small_objects;
    end
end
