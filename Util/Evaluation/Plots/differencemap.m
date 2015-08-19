
function [I] = differencemap(segmentation, gt)

    gt(gt>0) = 1;
    segmentation(segmentation<0)=0;

    % rgb bands with 0s (FN)
    r = zeros(size(segmentation));
    g = zeros(size(segmentation));
    b = zeros(size(segmentation));
    
    gt(gt<0) = 0;
    D = double(gt) - segmentation;
    
    % TP
    g(D==0) = 255;
    g = g .* double(gt);
    
    % TN
    b(D==0) = 255;
    b = b .* double(~logical(gt));
    
    % FP
    r(D<0) = 255;
    
    I = cat(3, r, g, b);

end