
function SaveSegmentations(root, config, results, model)

    if (sum(config.features.pairwise.pairwiseFeatures)==0)
        tag = 'up';
    else
        if (strcmp(config.crfVersion, 'fully-connected'))
            tag = 'fccrf';
        else
            tag = 'lnbcrf';
        end
    end


    for i = 1 : length(results.segmentations);
        if i < 10
            imwrite(results.segmentations{i},strcat(root, '\0', num2str(i), '_test_', tag, '.png'));
        else
            imwrite(results.segmentations{i},strcat(root, '\', num2str(i), '_test_', tag, '.png'));
        end
    end
    save(strcat(root, filesep, 'results.mat'), 'results');
    save(strcat(root, filesep, 'model.mat'), 'model');
    save(strcat(root, filesep, 'config.mat'), 'config');
    
end