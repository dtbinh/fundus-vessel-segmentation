
% Datasets names
datasetsNames = {'STARE-D'};
% Flag indicating if the value of C is going to be tuned according to the
% validation set
learnC = 0;
% CRF versions that are going to be evaluated
crfVersions = {'up','fully-connected'};
%crfVersions = {'fully-connected'};
% C values
cValue = 10.^2 * ones(length(datasetsNames), 1);
% Training on DRIVE
training_different_sets = 1;

% Root dir where the data sets are located
rootDatasets = 'C:\_tmi_experiments\';

% Root folder where the results are going to be stored
rootResults = 'C:\Users\USUARIO\Dropbox\RetinalImaging\Writing\tmi2015paper\results2';





% Creating data set paths
datasetsPaths = cell(length(datasetsNames), 1);
for i = 1 : length(datasetsNames)
    datasetsPaths{i} = strcat(rootDatasets, datasetsNames{i});
end

% Creating results paths
resultsPaths = cell(length(datasetsNames), 1);
for i = 1 : length(datasetsNames)
    resultsPaths{i} = strcat(rootResults, filesep, datasetsNames{i});
end





for experiment = 1 : length(datasetsNames)

    for crfver = 1 : length(crfVersions)
        
        % Get the configuration
        [config] = getConfiguration_GenericDataset(datasetsNames{experiment}, datasetsPaths{experiment}, resultsPaths{experiment}, learnC, crfVersions{crfver}, cValue(experiment));    
        options.Nguyen = config.features.featureParameters{1};
        options.Nguyen.training_different_sets = training_different_sets;
        config.features.featureParameters{1} = options.Nguyen;
        
        root = config.resultsPath;

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
            pairwiseDeviations = getPairwiseDeviations(allfeatures, numberOfDeviations);
            % Save pairwise deviations
            save(pairwisedeviations, 'pairwiseDeviations');
        else
            % Load pairwise deviations
            load(pairwisedeviations); 
        end

        % Assign precomputed deviations to the param struct
        config.features.pairwise.pairwiseDeviations = pairwiseDeviations;
        clear 'pairwiseDeviations';

        % Extract unary features
        fprintf('Computing unary features\n');
        % Compute unary features on training data
        [trainingdata.unaryFeatures, config.features.unary.unaryDimensionality] = ...
            extractFeaturesFromImages(trainingdata.images, ...
                                      trainingdata.masks, ...
                                      config, ...
                                      config.features.unary.unaryFeatures, ...
                                      true);
        config.features.unary.unaryDimensionality
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

        % Filter the value of theta_p
        config.theta_p.finalValues = ...
            config.theta_p.values(generateFeatureFilter(config.features.pairwise.pairwiseFeatures, config.features.pairwise.pairwiseFeaturesDimensions));

        % Train with this configuration and return the model
        [model, config.qualityOverValidation, config] = learnCRFPotentials(config, trainingdata, validationdata);


        
        % Open test data
        [testdata.images, testdata.labels, testdata.masks, testdata.numberOfPixels] = openLabeledData(config.test_data_path, config.preprocessing);
        % Update scale factor
        config.scale_factor = estimateScaleFactor('C:\_tmi_experiments\DRIVE\training', config.test_data_path);
        % Update configuration
        [config] = getGeneralConfiguration(config);
        %options.Nguyen2013.w = 15;
        %config.features.featureParameters{1} = options.Nguyen2013;
        if (strcmp(crfVersions{crfver},'fully-connected'))
            model.w(end) = model.w(end) / (config.scale_factor.^2);
        end

        % Extract unary features
        fprintf(strcat('Computing unary features\n'));
        [testdata.unaryFeatures, config.features.unary.unaryDimensionality] = ...
            extractFeaturesFromImages(testdata.images, ...
                                      testdata.masks, ...
                                      config, ...
                                      config.features.unary.unaryFeatures, ...
                                      true);
        config.features.unary.unaryDimensionality

        % Extract pairwise features
        fprintf(strcat('Computing pairwise features\n'));
        [pairwisefeatures, config.features.pairwise.pairwiseDimensionality] = ...
            extractFeaturesFromImages(testdata.images, ...
                                      testdata.masks, ...
                                      config, ...
                                      config.features.pairwise.pairwiseFeatures, ...
                                      false);

        % Compute the pairwise kernels
        fprintf(strcat('Computing pairwise kernels\n'));
        testdata.pairwiseKernels = getPairwiseFeatures(pairwisefeatures, config.features.pairwise.pairwiseDeviations);

        % Segment test data to evaluate the model
        [results.segmentations, results.qualityMeasures] = getBunchSegmentations2(config, testdata, model);

        results.table = [results.qualityMeasures.se; results.qualityMeasures.sp; results.qualityMeasures.acc; results.qualityMeasures.precision; results.qualityMeasures.recall; results.qualityMeasures.fMeasure; results.qualityMeasures.matthews];
        results.table = results.table';

        if (config.compute_scores)
        
            % Encode labels
            yy = [];
            for i = 1 : length(testdata.labels)
                y = double(testdata.labels{i} > 0);
                y = y(testdata.masks{i});
                y(y==0) = -1;
                yy = [yy; y];
            end

            % Generate the ROC curve for unary and pairwise potentials
            [ses,sps,infoUP] = vl_roc(double(yy), double(results.qualityMeasures.unaryPotentials));
            figure, plot(1 - sps, ses, 'r');
            hold on
            [ses,sps,infoFCCRF] = vl_roc(double(yy), double(results.qualityMeasures.scores));
            plot(1 - sps, ses, 'b');
            xlabel('FPR (1 - Specificity)');
            ylabel('TPR (Sensitivity)');
            legend(strcat('Unary potentials - AUC = ',[''],num2str(infoUP.auc)), strcat('FC-CRF - AUC =',[''],num2str(infoFCCRF.auc)), 'Location','southeast');
            scatter(mean(1-results.qualityMeasures.sp), mean(results.qualityMeasures.se));

            % Generate the precision/recall curve
            [recalls,precisions,infoUP_pr] = vl_pr(double(yy), double(results.qualityMeasures.unaryPotentials));
            figure, plot(recalls, precisions, 'r');
            hold on
            [recalls,precisions,infoFCCRF_pr] = vl_pr(double(yy), double(results.qualityMeasures.scores));
            plot(recalls, precisions, 'b');
            xlabel('Recall');
            ylabel('Precision');
            legend(strcat('Unary potentials - AUC = ',[''],num2str(infoUP_pr.auc)), strcat('FC-CRF - AUC =',[''],num2str(infoFCCRF_pr.auc)), 'Location','southeast');
            scatter(mean(results.qualityMeasures.recall), mean(results.qualityMeasures.precision));
            
        end
            

        SaveSegmentations(root, config, results, model);
        
    end
    
end
        