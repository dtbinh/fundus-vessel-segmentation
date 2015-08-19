
function [X, Y] = GetTrainingData(root, firstImage, lastImage, featconfig, imageTag, labelTag)


    % 1) Preallocate the samples

    % Compute sample size
    samplesize = 0;
    for i = firstImage : lastImage;
        mask = openmask(root, i);
        mask = mask(:);
        samplesize = numel(mask(mask==1)) + samplesize;
    end;

    % Preallocation
    X = single(zeros(samplesize, featconfig.featsetsize));
    Y = int8(1); % we can't preallocate this because it doesn't fit in memory


    % 2) Build the training data

    count = 1;
    for i = firstImage : lastImage;

        % Print the name of the image being processed
        fprintf('Processing image %i\n', i);

        % Extract the features
        x = ExtractFeaturesFromAGivenImage(root, i , firstImage, featconfig, imageTag, labelTag);

        % Open data (mask, annotations)
        [~, mask, y, ~] = opendata(root, i, imageTag, labelTag);
        
        % Remove y labels that don't belongs to the mask
        [ii, jj] = size(mask);
        mask = reshape(mask,ii*jj,1);
        y = y(logical(mask),:);

        % Assign observations and labels to the training set
        X(count : count + length(y) - 1, :) = x;
        Y(count : count + length(y) - 1, :) = y;   

        % Update count
        count = count + length(y) + 1;

    end;


end