
% Retinal Vessel Segmentation
function [results, config, model] = retinalVesselSegmentation2(config)

    % Code name of the expected files
    pairwisedeviations = strcat(config.training_data_path, filesep, 'pairwisedeviations.mat');
    
    % Open images, labels and masks on the training set
    [trainingdata.images, trainingdata.labels, trainingdata.masks, trainingdata.numberOfPixels] = openLabeledData(config.training_data_path, config.preprocessing);
    % Open images, labels and masks for the validation set
    [validationdata.images, validationdata.labels, validationdata.masks, validationdata.numberOfPixels] = openLabeledData(config.validation_data_path, config.preprocessing);

    % If the pairwise deviation file does not exist
    if (exist(pairwisedeviations, 'file')~=2)
        % Compute all possible features
        [allfeatures, numberOfDeviations] = extractFeaturesFromImages(trainingdata.images, trainingdata.masks, config, ones(size(config.features.numberFeatures)), false);
        % Compute pairwise deviations
        pairwiseDeviations = getPairwiseDeviations(allfeatures, numberOfDeviations, trainingdata.masks);
        % Save pairwise deviations
        save(pairwisedeviations, 'pairwiseDeviations');
    else
        % Load pairwise deviations
        load(pairwisedeviations); 
    end
    
    
    % If model selection have to be performed
    if (config.learn.modelSelection == 1)
        
        % Assign precomputed deviations to the param struct
        config.features.pairwise.pairwiseDeviations = pairwiseDeviations;
        clear 'pairwiseDeviations';
        % Learn the CRF and get the best model
        [model, config.qualityOverValidation, config] = completeModelSelection(config, trainingdata, validationdata);
       
    else

        % Extract unary features
        fprintf('Computing unary features\n');
        % Compute unary features on training data
        [trainingdata.unaryFeatures, config.unaryDimensionality] = ...
            extractFeaturesFromImages(trainingdata.images, ...
                                      trainingdata.masks, ...
                                      config, ...
                                      config.features.unary.unaryFeatures, ...
                                      true);
        % Compute unary features on validation data
        validationdata.unaryFeatures = extractFeaturesFromImages(validationdata.images, ...
                                                                 validationdata.masks, ...
                                                                 config, ...
                                                                 config.features.unary.unaryFeatures, ...
                                                                 true);

        % Compute pairwise features on training data
        % Extract pairwise features
        fprintf('Computing pairwise features\n');
        [pairwisefeatures, config.features.pairwise.pairwiseDimensionality] = ...
            extractFeaturesFromImages(trainingdata.images, ...
                                      trainingdata.masks, ...
                                      config, ...
                                      config.features.pairwise.pairwiseFeatures, ...
                                      false);
        config.features.pairwise.pairwiseDeviations = config.features.pairwise.pairwiseDeviations(generateFeatureFilter(config.features.pairwise.pairwiseFeatures, config.features.pairwise.pairwiseFeaturesDimensions));
        trainingdata.pairwiseKernels = getPairwiseFeatures(pairwisefeatures, config.features.pairwise.pairwiseDeviations);

        % Compute pairwise features on validation data
        pairwisefeatures = extractFeaturesFromImages(validationdata.images, ...
                                                     validationdata.masks, ...
                                                     config, ...
                                                     config.features.pairwise.pairwiseFeatures, ...
                                                     false);
        validationdata.pairwiseKernels = getPairwiseFeatures(pairwisefeatures, config.features.pairwise.pairwiseDeviations);

        % Train with this configuration and return the model
        [model, config.qualityOverValidation, config] = learnCRFPotentials(config, trainingdata, validationdata);
        
    end
   
    % Open test data
    [testdata.images, testdata.labels, testdata.masks, testdata.numberOfPixels] = openLabeledData(testroot);

    % Extract unary features
    fprintf(strcat('Computing unary features\n'));
    [testdata.unaryFeatures, config.unaryDimensionality] = ...
        extractFeaturesFromImages(testdata.images, ...
                                  testdata.masks, ...
                                  config, ...
                                  config.features.unary.unaryFeatures, ...
                                  true);

    % Extract pairwise features
    fprintf(strcat('Computing pairwise features\n'));
    [pairwisefeatures, config.pairwiseDimensionality] = ...
        extractFeaturesFromImages(testdata.images, ...
                                  testdata.masks, ...
                                  config, ...
                                  config.features.pairwise.pairwiseFeatures, ...
                                  false);

    % Compute the pairwise kernels
    fprintf(strcat('Computing pairwise kernels\n'));
    testdata.pairwiseKernels = getPairwiseFeatures(pairwisefeatures, config.features.pairwise.pairwiseDeviations);
    
    % Segment test data to evaluate the model
    [results.segmentations, results.qualityMeasures] = getBunchSegmentations(config, testdata, model);
    
end



% PROMPTS

% Option input
function option = ynoption_promp(promp)
    precomputedModel = input(strcat(promp, 'y/n: \n'), 's');
    while ((precomputedModel ~= 'y') && (precomputedModel ~= 'n'))
        fprintf('\nInvalid option.');
        precomputedModel = input(strcat(promp, 'y/n: \n'), 's');
    end
    option = (precomputedModel == 'y');
end

% File (with full path attached) input
function filepath = file_promp(promp)
    filepath = input(strcat(promp, '\n'), 's');
    while (exist(filepath, 'file')~=2)
        fprintf('\nThe specified file does not exists.');
        filepath = input(strcat(promp, '\n'), 's');
    end
end

% Path input
function path = path_promp(promp)
    path = input(strcat(promp, '\n'), 's');
    while (exist(path, 'dir')~=7)
        fprintf('\nThe specified folder does not exists.');
        path = input(strcat(promp, '\n'), 's');
    end
end

