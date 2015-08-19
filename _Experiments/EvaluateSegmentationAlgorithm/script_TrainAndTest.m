
% Get configuration for the data set
[config] = getConfiguration_DRIVE();


% Name of the expected pairwise deviations file
pairwisedeviations = strcat(config.training_data_path, filesep, 'pairwisedeviations.mat');


% If the pairwise deviation does not exist
if (exist(pairwisedeviations, 'file')~=2)

    % Compute all possible features
    [allfeatures, numberOfDeviations] = extractFeaturesFromImages(config.training_data_path, config, ones(size(config.features.pairwise.pairwiseFeatures)), false);
    % Compute pairwise deviations
    pairwiseDeviations = getPairwiseDeviations(allfeatures, numberOfDeviations);
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
    [model, param.qualityOverValidation, param.unaryFeaturesConfiguration, param.pairwiseFeaturesConfiguration] = completeModelSelection(config);

    
    
    
    
    
    
    
    
    
else

    % Open images, labels and masks for the training set
    [trainingdata.images, trainingdata.labels, trainingdata.masks, trainingdata.numberOfPixels] = openLabeledData(trainingroot);
    % Open images, labels and masks for the validation set
    [validationdata.images, validationdata.labels, validationdata.masks, validationdata.numberOfPixels] = openLabeledData(validationroot);

    % Extract unary features
    fprintf('Computing unary features\n');
    % Compute unary features on training data
    [trainingdata.unaryFeatures, param.unaryDimensionality] = extractFeaturesFromImages(trainingdata.images, trainingdata.masks, param.features, param.unaryFeatures, true);
    % Compute unary features on validation data
    validationdata.unaryFeatures = extractFeaturesFromImages(validationdata.images, validationdata.masks, param.features, param.unaryFeatures, true);

    % Compute pairwise features over training data
    % Extract pairwise features
    fprintf('Computing pairwise features\n');
    [pairwisefeatures, param.pairwiseDimensionality] = extractFeaturesFromImages(trainingdata.images, trainingdata.masks, param.features, param.pairwiseFeatures, false);
    % If the pairwise deviation does not exist
    if (exist(pairwisedeviations, 'file')~=2)
        % Compute all possible features
        [allfeatures, numberOfDeviations] = extractFeaturesFromImages(trainingdata.images, trainingdata.masks, param.features, ones(size(param.pairwiseFeatures)), false);
        % Compute pairwise deviations
        pairwiseDeviations = getPairwiseDeviations(allfeatures, numberOfDeviations, trainingdata.masks);
        % Save pairwise deviations
        save(pairwisedeviations, 'pairwiseDeviations');
    else
        % Load pairwise deviations
        load(pairwisedeviations);
    end
    % Assign precomputed deviations to the param struct
    trainingdata.pairwiseDeviations = pairwiseDeviations;
    clear 'pairwiseDeviations';

    trainingdata.pairwiseDeviations = trainingdata.pairwiseDeviations(generateFeatureFilter(param.pairwiseFeatures, param.pairwiseFeaturesDimensions));
    trainingdata.pairwiseKernels = getPairwiseFeatures(pairwisefeatures, trainingdata.pairwiseDeviations);

    % Compute pairwise features on validation data
    pairwisefeatures = extractFeaturesFromImages(validationdata.images, validationdata.masks, param.features, param.pairwiseFeatures, false);
    validationdata.pairwiseKernels = getPairwiseFeatures(pairwisefeatures, trainingdata.pairwiseDeviations);

    % Train with this configuration and return the model
    [model, param.qualityOverValidation, param] = learnCRFPotentials(param, trainingdata, validationdata);

end

% Open test data
%[testdata] = openTestData(testroot);
[testdata.images, testdata.labels, testdata.masks, testdata.numberOfPixels] = openLabeledData(testroot);

% Extract unary features
fprintf(strcat('Computing unary features\n'));
[testdata.unaryFeatures, param.unaryDimensionality] = extractFeaturesFromImages(testdata.images, testdata.masks, param.features, param.unaryFeatures, true);

% Extract pairwise features
fprintf(strcat('Computing pairwise features\n'));
[pairwisefeatures, param.pairwiseDimensionality] = extractFeaturesFromImages(testdata.images, testdata.masks, param.features, param.pairwiseFeatures, false);

% Compute the pairwise kernels
fprintf(strcat('Computing pairwise kernels\n'));
testdata.pairwiseKernels = getPairwiseFeatures(pairwisefeatures, trainingdata.pairwiseDeviations);

% Segment test data to evaluate the model
[results] = evaluateOverTestData(param, model, testdata);













% -------------------------------------------------------------------------
%                            CALL IT, BABE!
% -------------------------------------------------------------------------
[results, param, model] = retinalVesselSegmentation2(trainingroot, validationroot, testroot, param);

save('C:\Users\USUARIO\Dropbox\RetinalImaging\Writing\miccai2015paper\results\segmentations\hrfSegm.mat', 'results');