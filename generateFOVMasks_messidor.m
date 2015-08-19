
function [masks] = generateFOVMasks_messidor(rootImages, rootMasks)

    images = openMultipleGroundTruths(rootImages);
    masks = cell(size(images));
    
    for i = 1 : length(masks)
        
        I = images{i};
        mask = (I(:,:,1) + I(:,:,2) + I(:,:,3)) > 10;
        mask = imerode(mask, strel('disk',2, 8));
        mask = imdilate(mask, strel('disk',2, 8));
        mask = logical(mask);
        masks{i} = imfill(mask,'holes'); 
        
        %masks{i} = getFOVMask(images{i});
        if i < 10
            imwrite(masks{i}, strcat(rootMasks, '\0', num2str(i), '_mask.gif'));
        else
            imwrite(masks{i}, strcat(rootMasks, '\', num2str(i), '_mask.gif'));
        end
    end

end



function [images] = openMultipleGroundTruths(directory)
    % Get all file names
    allFiles = dir(directory);
    % Get only the names of the images inside the folder
    allNames = cell({allFiles.name});
    allNames = (filterFileNames(allNames));
    % Get all the images in the directory and count the number of pixels
    images = cell(length(allNames), 1);
    for i = 1:length(allNames)
      currentfilename = strtrim(allNames{i});
      currentfilename = strrep(currentfilename, '''', '');
      currentImage = imread(strcat(directory, filesep, currentfilename));
      images{i} = (currentImage); % Assign the image
    end
end