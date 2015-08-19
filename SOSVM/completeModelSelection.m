
function [model, c, qualityOverValidation, config] = completeModelSelection(config, trainingdata, validationdata)


    % 1) FORWARD SELECTION FOR UNARY FEATURES

    % If there are unary features selected, don't perform forward selection
    if (sum(config.features.unary.unaryFeatures(:)) ~= 0)
    
        % Initialize pairwise selected features with zeros
        config.features.pairwise.pairwiseFeatures = zeros(config.features.numberFeatures, 1);
        config.features.pairwise.pairwiseDimensionality = 0;
        config.theta_p.finalValues = [];
        
        % Extract unary features
        fprintf('Computing unary features\n');
        % Compute unary features on training data
        [trainingdata.unaryFeatures, config.features.unary.unaryDimensionality] = ...
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

        % Compute pairwise features on training data (all zeros)
        [trainingdata.pairwiseKernels, trainingdata.pairwiseDimensionality] = extractFeaturesFromImages(trainingdata.images, trainingdata.masks, config, config.features.pairwise.pairwiseFeatures, false);
        % Compute pairwise features on validation data (all zeros)
        [validationdata.pairwiseKernels, validationdata.pairwiseDimensionality] = extractFeaturesFromImages(validationdata.images, validationdata.masks, config, config.features.pairwise.pairwiseFeatures, false);                                                             
        
        % Learn CRF potentials using SOSVM, and optimize the value of C according to the validation set
        [model, qualityOverValidation, bestParam] = learnCRFPotentials(config, trainingdata, validationdata);
        
        qualitiesOnValidationSet = bestParam.qualitiesOnValidationSet
        output_path = strcat(config.output_path, filesep, config.modelSelectionMetric);
        if (~exist(output_path, 'dir'))
            mkdir(output_path);
        end
        save(strcat(output_path, filesep, 'qualitiesOnValidationSet_C.mat'), 'qualitiesOnValidationSet');
        
        
        % Don't learn C anymore
        config.learn.C = 0;
        config.C.value = bestParam.bestCvalue;
        
        % update the fixed features set with the new feature
        fixed_UnaryFeatures = find(config.features.unary.unaryFeatures)
        % update the value corresponding to the given combination of features
        quality_UnaryFeatures_best = extractfield(qualityOverValidation, config.modelSelectionMetric)
        
        
    else
        
        % Initialize selected features with zeros
        config.features.unary.unaryFeatures = zeros(config.features.numberFeatures, 1);
        config.features.pairwise.pairwiseFeatures = zeros(config.features.numberFeatures, 1);
        config.features.pairwise.pairwiseDimensionality = 0;
        config.theta_p.finalValues = [];

        % Compute pairwise features over training data (all zeros)
        [trainingdata.pairwiseKernels, trainingdata.pairwiseDimensionality] = extractFeaturesFromImages(trainingdata.images, trainingdata.masks, config, config.features.pairwise.pairwiseFeatures, false);
        % Compute pairwise features over validation data (all zeros)
        [validationdata.pairwiseKernels, validationdata.pairwiseDimensionality] = extractFeaturesFromImages(validationdata.images, validationdata.masks, config, config.features.pairwise.pairwiseFeatures, false);

        % Initializing variables for model selection
        iteration_unaryFeatureSelection = 0; 
        fixed_UnaryFeatures = []; % Selected features in the current iteration (initially empty)
        fixed_UnaryFeatures_prev = []; % Selected features in the previous iteration (initially empy)
        quality_UnaryFeatures = -Inf; % Current value of F1-score/Matthews
        quality_UnaryFeatures_best = -Inf; % Highest value of F1-score/Matthews obtained
        config.features.unary.UnaryQualityTable = [];
        
        
        % 1) FORWARD SELECTION TO DETERMINE UNARY FEATURES
        disp('Starting forward selection for unary potentials');

        % If it is the first iteration OR selected features have changed after
        % the last iteration...

        while ((iteration_unaryFeatureSelection == 0) || ~(isequal(fixed_UnaryFeatures, fixed_UnaryFeatures_prev)))

            % Increment the number of iterations
            iteration_unaryFeatureSelection = iteration_unaryFeatureSelection + 1;
            % Update fixed features
            fixed_UnaryFeatures_prev = fixed_UnaryFeatures;
            % Preallocate a vector with qualities
            quality_values = ones(config.features.numberFeatures, 1) * -Inf;

            % For each available feature
            for i = 1 : config.features.numberFeatures

                % If the current feature is not in the feature set
                if (~ismember(i, fixed_UnaryFeatures))

                    disp(strcat('Evaluating feature: ', num2str(i), ' - Already fixed: ', mat2str(fixed_UnaryFeatures)));

                    % Include the feature in the feature set
                    config.features.unary.unaryFeatures = zeros(config.features.numberFeatures, 1);
                    config.features.unary.unaryFeatures(i) = 1;
                    config.features.unary.unaryFeatures(fixed_UnaryFeatures) = 1;

                    % Compute unary features over training data
                    [trainingdata.unaryFeatures, config.features.unary.unaryDimensionality] = ...
                        extractFeaturesFromImages(trainingdata.images, ...
                                                  trainingdata.masks, ...
                                                  config, ...
                                                  config.features.unary.unaryFeatures, ...
                                                  true);
                    config.features.pairwise.pairwiseDimensionality = 0;

                    % Compute unary features over validation data
                    [validationdata.unaryFeatures, ~] = ...
                        extractFeaturesFromImages(validationdata.images, ...
                                                  validationdata.masks, ...
                                                  config, ...
                                                  config.features.unary.unaryFeatures, ...
                                                  true);

                    % Learn CRF potentials using SOSVM, and optimize the value of C according to the validation set
                    [~, qualityOverValidation, ~] = learnCRFPotentials(config, trainingdata, validationdata);

                    % Extract the quality value indicated in the field
                    % modelSelectionMetric
                    quality_values(i) = extractfield(qualityOverValidation, config.modelSelectionMetric);

                    % Display actual state of quality_values
                    disp(quality_values);

                end

            end

            % Replace NaN values by the minimum quality value possible
            quality_values(isnan(quality_values)) = -Inf;

            % Update the unary quality table
            config.features.unary.UnaryQualityTable = [config.features.unary.UnaryQualityTable, quality_values];
            
            % Save the file with the unary features
            output_path = strcat(config.output_path, filesep, config.modelSelectionMetric);
            if (~exist(output_path, 'dir'))
                mkdir(output_path);
            end
            UnaryQualityTable = config.features.unary.UnaryQualityTable;
            save(strcat(output_path, filesep, 'unaryFeaturesSelection.mat'), 'UnaryQualityTable');

            % Identify the best feature and the best quality value
            [quality_UnaryFeatures, bestFeature] = max(quality_values);

            % If the new set of features outperforms the previous one, update fixed features   
            if (quality_UnaryFeatures >= quality_UnaryFeatures_best)
                % update the fixed features set with the new feature
                fixed_UnaryFeatures = [fixed_UnaryFeatures, bestFeature]
                % update the value corresponding to the best combination of features
                quality_UnaryFeatures_best = quality_UnaryFeatures
                % sort the features set
                fixed_UnaryFeatures = sort(fixed_UnaryFeatures)
            end

        end
        disp('Forward selection for unary potentials finished!');

        % Unary features has been selected! Now, we just have to fix them in order to find the pairwise features

        % Update unary features
        config.features.unary.unaryFeatures = zeros(config.features.numberFeatures, 1);
        config.features.unary.unaryFeatures(fixed_UnaryFeatures) = 1;

        % Compute unary features over training data
        [trainingdata.unaryFeatures, config.features.unary.unaryDimensionality] = extractFeaturesFromImages(trainingdata.images, trainingdata.masks, config, config.features.unary.unaryFeatures, true);
        % Compute unary features over validation data
        validationdata.unaryFeatures = extractFeaturesFromImages(validationdata.images, validationdata.masks, config, config.features.unary.unaryFeatures, true);
        
    end
    
    % -------------------------------------------------------------

    
    
    
    % -------------------------------------------------------------
    
    % 2) SELECTION OF DIFFERENT VALUES OF THETA_P
    
    % Initialize the theta_p table
    config.theta_p.ThetaPTable = [];
    
    % If theta_p must be learned
    if config.learn.theta_p
        
        % Start search of best theta_p value
        disp('Starting search of the best values of theta_p');
        theta_p_values = zeros(sum(config.features.pairwise.pairwiseFeaturesDimensions(:)), 1);

        % Initialize theta_p table of values
        config.theta_p.ThetaPValuesTable = zeros(config.features.numberFeatures, floor((config.theta_p.lastValue - config.theta_p.initialValue + 1) / config.theta_p.increment));
        
        % For each feature
        for i = 1 : config.features.numberFeatures

            disp(strcat('Analysing feature ', num2str(i)));

            % Assign the feature
            config.features.pairwise.pairwiseFeatures = zeros(config.features.numberFeatures, 1);
            config.features.pairwise.pairwiseFeatures(i) = 1;

            % Compute pairwise features on training data
            [pairwiseFeatures, config.features.pairwise.pairwiseDimensionality] = ...
                extractFeaturesFromImages(trainingdata.images, ...
                                          trainingdata.masks, ...
                                          config, ...
                                          config.features.pairwise.pairwiseFeatures, ...
                                          false);
            % Filter pairwise deviations and divide pairwise features by
            % the pairwise deviations to obtain the pairwise kernels
            pairwiseDeviations = config.features.pairwise.pairwiseDeviations(generateFeatureFilter(config.features.pairwise.pairwiseFeatures, config.features.pairwise.pairwiseFeaturesDimensions));
            trainingdata.pairwiseKernels = getPairwiseFeatures(pairwiseFeatures, pairwiseDeviations);
            
            % Compute pairwise features on validation data
            pairwiseFeatures = extractFeaturesFromImages(validationdata.images, ...
                                                         validationdata.masks, ...
                                                         config, ...
                                                         config.features.pairwise.pairwiseFeatures, ...
                                                         false);
            % Divide pairwise features by the pairwise deviations to obtain
            % the pairwise kernels
            validationdata.pairwiseKernels = getPairwiseFeatures(pairwiseFeatures, pairwiseDeviations);       

            % Initialize the set of best theta_p values and the best quality value
            theta_p_best = ones(config.features.pairwise.pairwiseDimensionality, 1) * config.theta_p.initialValue;
            quality_best_theta_p_search = -Inf;

            % For each possible exponent for theta_p
            countt = 1;
            for j = config.theta_p.initialValue : config.theta_p.increment : config.theta_p.lastValue

                % Compute the values of theta_p
                config.theta_p.values = ones(config.features.pairwise.pairwiseDimensionality,1) * j;
                config.theta_p.finalValues = config.theta_p.values;

                disp(strcat('Analysing theta_p = ', num2str(config.theta_p.values(1))));

                % Learn CRF potentials using SOSVM, and optimize the value of C according to the validation set
                [~, qualityOverValidation, parameters{i}] = learnCRFPotentials(config, trainingdata, validationdata);

                % Check if the quality measure is higher than the previous ones
                if (extractfield(qualityOverValidation, config.modelSelectionMetric) >= quality_best_theta_p_search)
                    quality_best_theta_p_search = extractfield(qualityOverValidation, config.modelSelectionMetric);
                    theta_p_best = config.theta_p.values;
                end                    
                % Update the theta_p table
                config.theta_p.ThetaPValuesTable(i,countt) = extractfield(qualityOverValidation, config.modelSelectionMetric);
                
                countt = countt + 1;
                
            end
            
            config.theta_p.ThetaPValuesTable
            
            % Save the file with the unary features
            output_path = strcat(config.output_path, filesep, config.modelSelectionMetric);
            if (~exist(output_path, 'dir'))
                mkdir(output_path);
            end
            ThetaPValuesTable = config.theta_p.ThetaPValuesTable;
            save(strcat(output_path, filesep, 'thetapValuesTable.mat'), 'ThetaPValuesTable');

            % Store the best value of theta_p found
            theta_p_values(i) = theta_p_best(1);
            disp(theta_p_values(i));
            
        end
        
        config.theta_p.values = theta_p_values;
            
    end
    
    disp('Search of theta_p values finished');
    disp(config.theta_p.finalValues);
    
    % -------------------------------------------------------------

    
    
    
    % -------------------------------------------------------------
    
    % 3) FORWARD SELECTION TO DETERMINE PAIRWISE FEATURES
    % We don't initialize the value of quality_best with Inf because we want to
    % outperform it
    
    % Initializing variables for model selection
    iteration_pairwiseFeatureSelection = 0;
    fixed_PairwiseFeatures = [];
    fixed_PairwiseFeatures_prev = [];
    quality_PairwiseFeatures = [];
    quality_PairwiseFeatures_best = quality_UnaryFeatures_best;

    config.features.pairwise.PairwiseQualityTable = [];
    
    % Forward selection to determine pairwise potentials
    disp('Starting forward selection for pairwise potentials');
    while ((iteration_pairwiseFeatureSelection==0) || ~(isequal(fixed_PairwiseFeatures, fixed_PairwiseFeatures_prev)))
       
        % Increment the number of iterations
        iteration_pairwiseFeatureSelection = iteration_pairwiseFeatureSelection + 1;
        % Update fixed features
        fixed_PairwiseFeatures_prev = fixed_PairwiseFeatures;
        % Preallocate a vector with quality values
        quality_values = ones(config.features.numberFeatures, 1) * -Inf;
        parameters = cell(config.features.numberFeatures, 1);
        
        % For each feature
        for i = 1 : config.features.numberFeatures
            
            % If it is not in the feature set
            if (~ismember(i, fixed_PairwiseFeatures))
                
                disp(strcat('Evaluating feature: ', num2str(i), ' - Already fixed: ', mat2str(fixed_PairwiseFeatures)));
                
                % Assign the feature
                config.features.pairwise.pairwiseFeatures = zeros(config.features.numberFeatures, 1);
                config.features.pairwise.pairwiseFeatures(i) = 1;
                config.features.pairwise.pairwiseFeatures(fixed_PairwiseFeatures) = 1;
                
                % Get their theta_p
                fixedfeaturesnow = sort(cat(1, fixed_PairwiseFeatures,i));
                config.theta_p.finalValues = [];
                for j = 1 : length(fixedfeaturesnow)
                    config.theta_p.finalValues = cat(1, config.theta_p.finalValues, ones(fixedfeaturesnow(j),1) * config.theta_p.values(fixedfeaturesnow(j)));
                end
                
                % Compute pairwise features over training data
                [pairwiseFeatures, config.features.pairwise.pairwiseDimensionality] = ...
                    extractFeaturesFromImages(trainingdata.images, ...
                                              trainingdata.masks, ...
                                              config, ...
                                              config.features.pairwise.pairwiseFeatures, ...
                                              false);
                pairwiseDeviations = config.features.pairwise.pairwiseDeviations(generateFeatureFilter(config.features.pairwise.pairwiseFeatures, config.features.pairwise.pairwiseFeaturesDimensions));
                trainingdata.pairwiseKernels = getPairwiseFeatures(pairwiseFeatures, pairwiseDeviations);
                
                % Compute pairwise features over validation data
                pairwiseFeatures = extractFeaturesFromImages(validationdata.images, ...
                                                             validationdata.masks, ...
                                                             config, ...
                                                             config.features.pairwise.pairwiseFeatures, ...
                                                             false);
                validationdata.pairwiseKernels = getPairwiseFeatures(pairwiseFeatures, pairwiseDeviations);
                
                % Learn CRF potentials using SOSVM, and optimize the value
                % of C according to the validation set
                [~, qualityOverValidation, parameters{i}] = learnCRFPotentials(config, trainingdata, validationdata);
                                
                % Extract the quality value indicated in the field modelSelectionMetric
                quality_values(i) = extractfield(qualityOverValidation, config.modelSelectionMetric);
                
                disp(quality_values);
                
            end
            
        end
        
        % Replace NaN values by the minimum quality value possible
        quality_values(isnan(quality_values)) = -Inf;
        
        % Update the unary quality table
        config.features.pairwise.PairwiseQualityTable = [config.features.pairwise.PairwiseQualityTable, quality_values];
        
        % Save the file with the qualities of each pairwise feature
        output_path = strcat(config.output_path, filesep, config.modelSelectionMetric);
        if (~exist(output_path, 'dir'))
            mkdir(output_path);
        end
        PairwiseQualityTable = config.features.pairwise.PairwiseQualityTable;
        save(strcat(output_path, filesep, 'pairwiseFeaturesSelection.mat'), 'PairwiseQualityTable');
        
        % Identify the best feature and the best quality value
        [quality_PairwiseFeatures, bestFeature] = max(quality_values);
        
        % If the new set of features outperforms the previous one, update fixed features   
        if (quality_PairwiseFeatures >= quality_PairwiseFeatures_best)
            % update the fixed features set with the new feature
            fixed_PairwiseFeatures = [fixed_PairwiseFeatures, bestFeature]
            % update the value corresponding to the best combination of features
            quality_PairwiseFeatures_best = quality_PairwiseFeatures
            % sort the features set
            fixed_PairwiseFeatures = sort(fixed_PairwiseFeatures)
        end

        
    end
    
    % Update pairwise features
    config.features.pairwise.pairwiseFeatures = zeros(config.features.numberFeatures, 1);
    config.features.pairwise.pairwiseFeatures(fixed_PairwiseFeatures) = 1;
    
    % Compute pairwise features on training data
    [pairwiseFeatures, config.features.pairwise.pairwiseDimensionality] = ...
        extractFeaturesFromImages(trainingdata.images, ...
                                  trainingdata.masks, ...
                                  config, ...
                                  config.features.pairwise.pairwiseFeatures, ...
                                  false);
    config.features.pairwise.pairwiseDeviations = config.features.pairwise.pairwiseDeviations(generateFeatureFilter(config.features.pairwise.pairwiseFeatures, config.features.pairwise.pairwiseFeaturesDimensions));
    trainingdata.pairwiseKernels = getPairwiseFeatures(pairwiseFeatures, config.features.pairwise.pairwiseDeviations);
    
    % Compute pairwise features on validation data
    pairwiseFeatures = extractFeaturesFromImages(validationdata.images, validationdata.masks, config.features, config.features.pairwise.pairwiseFeatures, false);
    validationdata.pairwiseKernels = getPairwiseFeatures(pairwiseFeatures, config.features.pairwise.pairwiseDeviations);
    
    % Train with this configuration and return the model
    [model, qualityOverValidation, config] = learnCRFPotentials(config, trainingdata, validationdata);
    c = config.C.value;

end