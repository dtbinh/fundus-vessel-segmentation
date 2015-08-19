% This code here comes from 
% 
%     Copyright (c) 2013, José Ignacio Orlando, Matthew Blaschko
%     All rights reserved.
% 
%     Redistribution and use in source and binary forms, with or without
%     modification, are permitted provided that the following conditions are met:
%         * Redistributions of source code must retain the above copyright
%         notice, this list of conditions and the following disclaimer.
%         * Redistributions in binary form must reproduce the above copyright
%         notice, this list of conditions and the following disclaimer in the
%         documentation and/or other materials provided with the distribution.
%         * Comercial restrictions?.
% 
%     THIS SOFTWARE IS PROVIDED BY José Ignacio Orlando and Matthew Blaschko ''AS IS'' AND ANY
%     EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
%     WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
%     DISCLAIMED. IN NO EVENT SHALL José Ignacio Orlando and Matthew Blaschko BE LIABLE FOR ANY
%     DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
%     (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
%     LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
%     ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
%     (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
%     SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
% 

% Retinal Vessel Segmentation
function [results, param] = retinalVesselSegmentation(trainingroot, validationroot, testroot, param)

    % Code name of the expected files
    trainingfilename = encodeFileName(trainingroot, param, 'training');
    validationfilename = encodeFileName(validationroot, param, 'validation');
    testfilename = encodeFileName(testroot, param, 'test');
    learnedModel = encodeFileName(trainingroot, param, 'learnedModel');
    
    % Learn fully connected CRF using SOSVM
    if (exist(learnedModel, 'file')~=2) % if there is not a learned model
           
        % Open the training data
        if (exist(trainingfilename, 'file')~=2)

            % Open images, labels and masks for the training set
            [trainingdata.images, trainingdata.labels, trainingdata.masks, trainingdata.numberOfPixels] = openLabeledData(trainingroot);

            % If we have a fixed model
            if (param.performModelSelection == 0)
            
                % Extract unary features
                fprintf('Computing unary features\n');
                [trainingdata.unaryFeatures, trainingdata.unaryDimensionality] = extractFeaturesFromImages(trainingdata.images, trainingdata.masks, param.features, param.unaryFeatures, true);

                % Extract pairwise features
                fprintf('Computing pairwise features\n');
                [pairwisefeatures, trainingdata.pairwiseDimensionality] = extractFeaturesFromImages(trainingdata.images, trainingdata.masks, param.features, param.pairwiseFeatures, false);

                % Obtain standard deviations
                fprintf('Computing pairwise deviations\n');
                training.pairwiseDeviations = getPairwiseDeviations(pairwisefeatures, trainingdata.pairwiseDimensionality, trainingdata.masks);

                % Compute the pairwise kernels
                fprintf('Computing pairwise kernels\n');
                trainingdata.pairwiseKernels = getPairwiseFeatures(pairwisefeatures, training.pairwiseDeviations);
                
                % Update dimensionalities in param struct
                param.unaryDimensionality = trainingdata.unaryDimensionality;
                param.pairwiseDimensionality = trainingdata.pairwiseDimensionality;
                
            end            

            % Save training data to reutilize it
            save(trainingfilename, 'trainingdata');   

        else

            % Open training data
            load(trainingfilename);
            % Update dimensionalities in param struct
            param.unaryDimensionality = trainingdata.unaryDimensionality;
            param.pairwiseDimensionality = trainingdata.pairwiseDimensionality;

        end;

        % Open the validation data
        if (exist(validationfilename, 'file')~=2)

            % Open images, labels and masks for the validation set
            [validationdata.images, validationdata.labels, validationdata.masks, validationdata.numberOfPixels] = openLabeledData(validationroot);

            % If we have a fixed model
            if (param.performModelSelection == 0)
            
                % Extract unary features
                fprintf('Computing unary features\n');
                validationdata.unaryFeatures = extractFeaturesFromImages(validationdata.images, validationdata.masks, param.features, param.unaryFeatures, true);

                % Extract pairwise features
                fprintf('Computing pairwise features\n');
                pairwisefeatures = extractFeaturesFromImages(validationdata.images, validationdata.masks, param.features, param.pairwiseFeatures, false);

                % Compute the pairwise kernels
                fprintf('Computing pairwise kernels\n');
                validationdata.pairwiseKernels = getPairwiseFeatures(pairwisefeatures, training.pairwiseDeviations);
                
            end

            % Save training data to reutilize it
            save(validationfilename, 'validationdata');   

        else

            % Open training data
            load(validationfilename);

        end;
        
        % Learn fully connected CRF potentials using SOSVM
        % If the model is fixed
        if (param.performModelSelection == 0)
            [model, qualityOverValidation, param] = learnCRFPotentials(param, trainingdata, validationdata);
        else
            % Learn the CRF and get the best model
            [model, ~, param.unaryFeaturesConfiguration, param.pairwiseFeaturesConfiguration] = completeModelSelection(param, trainingdata, validationdata, param.numberOfFeatures);
        end
        save(learnedModel, 'model', 'param', 'qualityOverValidation');
        
    else
        
        load(learnedModel);
        
    end

    % Open test data
    if (exist(testfilename, 'file')~=2)
        
        % Open test data
        %[testdata] = openTestData(testroot);
        [testdata.images, testdata.labels, testdata.masks, testdata.numberOfPixels] = openLabeledData(testroot);
            
        % Extract unary features
        fprintf(strcat('Computing unary features\n'));
        testdata.unaryFeatures = extractFeaturesFromImages(testdata.images, testdata.masks, param.features, param.unaryFeatures, true);

        % Extract pairwise features
        fprintf(strcat('Computing pairwise features\n'));
        pairwisefeatures = extractFeaturesFromImages(testdata.images, testdata.masks, param.features, param.pairwiseFeatures, false);

        % Compute the pairwise kernels
        fprintf(strcat('Computing pairwise kernels\n'));
        testdata.pairwiseKernels = getPairwiseFeatures(pairwisefeatures, training.pairwiseDeviations);
        
        % Save test data to reutilize it
        save(testfilename, 'testdata'); 
        
    else
        
        load(testfilename);
        
    end
    
    % Segment test data to evaluate the model
    [results] = evaluateOverTestData(param, model, testdata);
    
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

