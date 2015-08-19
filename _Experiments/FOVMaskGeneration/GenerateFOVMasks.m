
folder = 'C:\_tmi_experiments\STARE\ALL\images';
folder_masks = 'C:\_tmi_experiments\STARE\ALL\masks';

close all;
[images, allNames] = openMultipleImages(folder);

for i = 1 : length(images)
    
    I = images{i};
    R = I(:,:,1);
    G = I(:,:,2);
    B = I(:,:,3);

%     ARIA
% --------------------
%     [L,a,b] = RGB2Lab(R,G,B);
%     L = L./100;
%     mask = logical((1- (L < 0.05)) > 0);
%     mask = imfill(mask,'holes');
%     mask = bwareaopen(mask, 50);
%     
%     if (sum(mask(:)==1) + 100 > (size(mask,1)*size(mask,2)) )
%         mask = logical((1- (L < 0.55)) > 0);
%         mask = imfill(mask,'holes');
%         mask = bwareaopen(mask, 50);
%     end
    
%   STARE
% --------------------
    [L,a,b] = RGB2Lab(R,G,B);
    L = L./100;
    mask = logical((1- (L < 0.50)) > 0);
    mask = imfill(mask,'holes');
    mask = bwareaopen(mask, 50);

    figure, imshow(mask);
    
    strtok(allNames{i}, '.')
    imwrite(mask, strcat(folder_masks, filesep, strtok(allNames{i}, '.'), '_mask', '.gif'));
    
end