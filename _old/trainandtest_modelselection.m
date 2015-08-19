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

%% Retinal Vessel Segmentation
function [results] = trainandtest_modelselection(trainingroot, validationroot, testroot, param)

    %% Learn fully connected CRF using SOSVM
    if (exist(strcat(trainingroot, filesep, 'learnedModel.mat'), 'file')~=2)
        
        %% Open training images, masks and labels
    
        % Open the training data
        if (exist(strcat(trainingroot, filesep, 'trainingdata.mat'), 'file')~=2)

            % Open images, labels and masks for the training set
            [trainingdata.images, trainingdata.labels, trainingdata.masks, trainingdata.numberOfPixels] = openLabeledData(trainingroot);

            % Save training data to reutilize it
            save(strcat(trainingroot,filesep,'trainingdata.mat'), 'trainingdata');   

        else

            % Open training data
            load(strcat(trainingroot, filesep, 'trainingdata.mat'));

        end;

        %% Open validation images, masks and labels

        % Open the training data
        if (exist(strcat(validationroot, filesep, 'validationdata.mat'), 'file')~=2)

            % Open images, labels and masks for the validation set
            [validationdata.images, validationdata.labels, validationdata.masks, validationdata.numberOfPixels] = openLabeledData(validationroot);

            % Save training data to reutilize it
            save(strcat(validationroot,filesep,'validationdata.mat'), 'validationdata');   

        else

            % Open training data
            load(strcat(validationroot, filesep, 'validationdata.mat'));

        end;
        
        % Learn fully connected CRF potentials using SOSVM
        [model, param.C, qualityOverValidation, param.unaryFeaturesConfiguration, param.pairwiseFeaturesConfiguration] = completeModelSelection(param, trainingdata, validationdata, param.numberOfFeatures);
        save(strcat(trainingroot,filesep,'learnedModel.mat'), 'model', 'qualityOverValidation', 'param');
        
    else
        
        load(strcat(trainingroot,filesep,'learnedModel.mat'));
        
    end

    %% Open test data
    if (exist(strcat(testroot, filesep, 'testdata.mat'), 'file')~=2)
        
        % Open test data
        [testdata] = openTestData(testroot);
        
        % Extract all features
        for i = 1:length(testdata)
        
            disp(testdata{i}.testName);
            
            % Extract unary features
            fprintf(strcat('Computing unary features\n'));
            testdata{i}.unaryFeatures = extractFeaturesFromImages(testdata{i}.images, testdata{i}.masks, param.unaryFeaturesConfiguration);

            % Extract pairwise features
            fprintf(strcat('Computing pairwise features\n'));
            pairwisefeatures = extractFeaturesFromImages(testdata{i}.images, testdata{i}.masks, param.pairwiseFeaturesConfiguration);

            % Obtain standard deviations
            fprintf(strcat('Computing pairwise deviations\n'));
            pairwiseDeviations = getPairwiseDeviations(pairwisefeatures, testdata{i}.masks);

            % Compute the pairwise kernels
            fprintf(strcat('Computing pairwise kernels\n'));
            testdata{i}.pairwiseKernels = getPairwiseFeatures(pairwisefeatures, pairwiseDeviations);
        
        end
        
        % Save test data to reutilize it
        save(strcat(testroot,filesep,'testdata.mat'), 'testdata'); 
        
    else
        
        load(strcat(testroot,filesep,'testdata.mat'));
        
    end
    
    %% Segment test data to evaluate the model
    [results] = evaluateOverTestData(param, model, testdata);
    
end





%% PROMPTS

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

