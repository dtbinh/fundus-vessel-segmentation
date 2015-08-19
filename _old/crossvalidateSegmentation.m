
function [results] = crossvalidateSegmentation(root, param)

    %% Load data
    % If there is not precomputed information
    if (exist(strcat(root, filesep, 'crossvalidationdata.mat'), 'file')~=2)     
        
        % Open images, labels and masks for the training set
        [crossvalidationdata.images, crossvalidationdata.labels, crossvalidationdata.masks, crossvalidationdata.numberOfPixels] = openLabeledData(root);

        % If we have a fixed model
        if (param.performModelSelection == 0)
        
            % Extract unary features
            fprintf('Computing unary features\n');
            crossvalidationdata.unaryFeatures = extractFeaturesFromImages(crossvalidationdata.images, crossvalidationdata.masks, param.unaryFeaturesConfiguration);

            % Extract pairwise features
            fprintf('Computing pairwise features\n');
            pairwisefeatures = extractFeaturesFromImages(crossvalidationdata.images, crossvalidationdata.masks, param.pairwiseFeaturesConfiguration);

            % Obtain standard deviations
            fprintf('Computing pairwise deviations\n');
            pairwiseDeviations = getPairwiseDeviations(pairwisefeatures, crossvalidationdata.masks);

            % Compute the pairwise kernels
            fprintf('Computing pairwise kernels\n');
            crossvalidationdata.pairwiseKernels = getPairwiseFeatures(pairwisefeatures, pairwiseDeviations);
            
        end;
        
        % Save training data to reutilize it
        save(strcat(root,filesep,'crossvalidationdata.mat'), 'crossvalidationdata');   

    else

        % Open training data
        load(strcat(root, filesep, 'crossvalidationdata.mat'));

    end;
        
    %% Perform leave-one-out cross validation
    
    % Preallocate parameters
    param.c_initialPower = 0;
    param.c_lastPower = 6;
    
    % Preallocate memory
    results.segmentations = cell(size(crossvalidationdata.images));
    results.qualityMeasures.se = [];
    results.qualityMeasures.sp = [];
    results.qualityMeasures.acc = [];
    results.qualityMeasures.precision = [];
    results.qualityMeasures.recall = [];
    results.qualityMeasures.fMeasure = [];
    
    
    % Leave-one-out cross validation
    % For each image in the cross validation set
    for i = 1:length(crossvalidationdata.images)

        % Check if the splits exist
        if (exist(strcat(root, filesep, num2str(i),'.mat'), 'file')~=2)

            % Generate indexes of all the images
            allimages = 1:1:length(crossvalidationdata.images);

            % Remove the index corresponding to the test image
            allimages(i) = [];
            % Select randomly 20% of the images for validation
            numvalidation = floor((length(allimages)) * 0.20);
            sample = randsample(length(allimages),numvalidation);
            % Get validation indexes
            validationIndexes = allimages(sample);
            % Get training indexes
            trainingIndexes = allimages;
            trainingIndexes(sample) = [];

            % Save the distribution of training and validation images
            save(strcat(root, filesep, num2str(i),'.mat'), 'trainingIndexes', 'validationIndexes');  

        else

            load(strcat(root, filesep, num2str(i),'.mat'));

        end

        % Get training and validation data
        [testdata] = getithdata(param, crossvalidationdata, i);
        [validationdata] = removefromdata(param, crossvalidationdata, [trainingIndexes i]);
        [trainingdata] = removefromdata(param, crossvalidationdata, [validationIndexes i]);

        % If the model is fixed
        if (param.performModelSelection == 0)
            
            % Learn the best model
            [model, param.C, ~] = learnCRFPotentials(param, trainingdata, validationdata);
            
        else
            
            % Learn the CRF and get the best model
            [model, param.C, ~, param.unaryFeaturesConfiguration, param.pairwiseFeaturesConfiguration] = completeModelSelection(param, trainingdata, validationdata, param.numberOfFeatures);
            
            % Extract unary features
            fprintf('Computing unary features\n');
            testdata.unaryFeatures = extractFeaturesFromImages(testdata.images, testdata.masks, param.unaryFeaturesConfiguration);

            % Extract pairwise features
            fprintf('Computing pairwise features\n');
            pairwisefeatures = extractFeaturesFromImages(testdata.images, testdata.masks, param.pairwiseFeaturesConfiguration);

            % Obtain standard deviations
            fprintf('Computing pairwise deviations\n');
            pairwiseDeviations = getPairwiseDeviations(pairwisefeatures, testdata.masks);

            % Compute the pairwise kernels
            fprintf('Computing pairwise kernels\n');
            testdata.pairwiseKernels = getPairwiseFeatures(pairwisefeatures, pairwiseDeviations);
            
        end
        
        % Evaluate over test set
        [segm, qualityMeasure] = getBunchSegmentations(param, testdata, model);
        results.segmentations{i} = segm{1};
        results.qualityMeasures.se = [results.qualityMeasures.se, qualityMeasure.se];
        results.qualityMeasures.sp = [results.qualityMeasures.sp, qualityMeasure.sp];
        results.qualityMeasures.acc = [results.qualityMeasures.acc, qualityMeasure.acc];
        results.qualityMeasures.precision = [results.qualityMeasures.precision, qualityMeasure.precision];
        results.qualityMeasures.recall = [results.qualityMeasures.recall, qualityMeasure.recall];
        results.qualityMeasures.fMeasure = [results.qualityMeasures.fMeasure, qualityMeasure.fMeasure];
        
        % Save results
        save(strcat(root, filesep, num2str(i),'_results.mat'), 'model', 'param', 'results'); 

    end
    
end


%%
function [ithdata] = getithdata(param, data, i)

    ithdata.images = {data.images{i}};
    ithdata.masks = {data.masks{i}};
    ithdata.labels = {data.labels{i}};
    
    if (param.performModelSelection == 0)
        ithdata.unaryFeatures = {data.unaryFeatures{i}};
        ithdata.pairwiseKernels = {data.pairwiseKernels{i}};
    end

end

%%
function [newdata] = removefromdata(param, data, toremove)

    newdata = data;
    newdata.images(toremove) = [];
    newdata.masks(toremove) = [];
    newdata.labels(toremove) = [];
    
    if (param.performModelSelection == 0)
        newdata.unaryFeatures(toremove) = [];
        newdata.pairwiseKernels(toremove) = [];
    end

end