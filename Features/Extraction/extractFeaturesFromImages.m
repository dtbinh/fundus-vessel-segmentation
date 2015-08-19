
function [features, dimensionality] = extractFeaturesFromImages(images, masks, config, selectedFeatures, unary)
 
    % Preallocate the cell array where the features will be stored
    features = cell(size(images));

    % For each image
    parfor i = 1:length(images)
        
        fprintf('Extracting features from %i/%i\n',i,length(images));
        
        % Compute the raw features
        features{i} = extractFeaturesFromImage(images{i}, masks{i}, config, selectedFeatures, unary);
        
    end
    
    % Return the dimensionality of the feature vector
    dimensionality = size(features{1}, 2);

end
