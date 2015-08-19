
warning('off','all');

% Datasets names
datasetsNames = {...
%    'DRIVE'
      'DRIVE', ...
       'STARE-A', ...
       'STARE-B', ...
       'CHASEDB1-A'...%, ...
      'HRF'...
    };

cc=hsv(length(datasetsNames));
h_roc = figure;
    

aucs = [];


humanObserverPerformances = [...
    0.8066, 0.7760; ...
    0.9385, 0.9365; ...
    0.6249, 0.9022; ...
    0.7501, 0.8362];


% Flag indicating if the value of C is going to be tuned according to the
% validation set
learnC = 1;
% CRF versions that are going to be evaluated
crfVersions = {'up','fully-connected'};

% C values
cValue = 10^2;

% Root dir where the data sets are located
rootDatasets = 'C:\_tmi_experiments\';

% Root folder where the results are going to be stored
rootResults = 'C:\Users\USUARIO\Dropbox\RetinalImaging\Writing\tmi2015paper\results2';


exportfigures = 'C:\Users\USUARIO\Dropbox\RetinalImaging\Writing\tmi2015paper\paper\figures\precisionRecallCurves';



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
        
        % Load the configuration
        load(strcat(resultsPaths{experiment}, filesep, crfVersions{crfver}, filesep, 'config.mat'));
        root = strcat(resultsPaths{experiment}, filesep, crfVersions{crfver});
        config.compute_scores = 1;
        config.experiment = crfVersions{crfver};

        % Load the model
        load(strcat(resultsPaths{experiment}, filesep, crfVersions{crfver}, filesep, 'model.mat'));

        % Open test data
        [testdata.images, testdata.labels, testdata.masks, testdata.numberOfPixels] = openLabeledData(config.test_data_path, config.preprocessing);

        % Extract unary features
        fprintf(strcat('Computing unary features\n'));
        [testdata.unaryFeatures, config.features.unary.unaryDimensionality] = ...
            extractFeaturesFromImages(testdata.images, ...
                                      testdata.masks, ...
                                      config, ...
                                      config.features.unary.unaryFeatures, ...
                                      true);

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

        results.table = [results.qualityMeasures.se, results.qualityMeasures.sp, results.qualityMeasures.acc, results.qualityMeasures.precision, results.qualityMeasures.recall, results.qualityMeasures.fMeasure, results.qualityMeasures.matthews];
        disp(strcat('Se = ', num2str(mean(results.qualityMeasures.se))));
        disp(strcat('Sp = ', num2str(mean(results.qualityMeasures.sp))));
        disp(strcat('fMeasure = ', num2str(mean(results.qualityMeasures.fMeasure))));
        disp(strcat('matthews = ', num2str(mean(results.qualityMeasures.matthews))));
        

        if (config.compute_scores)
        
            % Encode labels
            yy = [];
            for i = 1 : length(testdata.labels)
                y = double(testdata.labels{i} > 0);
                y = y(testdata.masks{i});
                y(y==0) = -1;
                yy = [yy; y];
            end

            % If unary potentials
            if (strcmp(crfVersions{crfver},'up'))
               
                % Generate the precision/recall curve using only the unary
                % potentials
                [recalls,precisions,infoUP_pr] = vl_pr(double(yy), double(results.qualityMeasures.unaryPotentials));
                aucs = [aucs, infoUP_pr.auc];
                %h_pr = figure;
                %set(0,'CurrentFigure',h_pr)
                plot(recalls, precisions, '--', 'color', cc(experiment,:));
                %plot(recalls, precisions, 'r');
                hold on
                
            else
                
                % Generate the precision/recall curve using only the unary
                % and pairwise potentials
                [recalls,precisions,infoFCCRF_pr] = vl_pr(double(yy), double(results.qualityMeasures.scores));
                aucs = [aucs, infoFCCRF_pr.auc];
                plot(recalls, precisions, '-', 'color', cc(experiment,:));
                if ~(strcmp(datasetsNames{experiment},'HRF'))
                    scatter(humanObserverPerformances(experiment,2), humanObserverPerformances(experiment,1), 'MarkerEdgeColor',cc(experiment,:), 'MarkerFaceColor',cc(experiment,:));
                    %legend('UP','FC-CRF','2nd HO', 'Location','southeast');
                else
                    %legend('UP','FC-CRF', 'Location','southeast');
                end                
                
                %xlabel('Recall');
                %ylabel('Precision');
                %legend(strcat('Unary potentials - AUC = ',[''],num2str(infoUP_pr.auc)), strcat('FC-CRF - AUC =',[''],num2str(infoFCCRF_pr.auc)),'2nd human observer', 'Location','southeast');
                %title(datasetsNames{experiment});
                %hold off;
                
                %saveas(h_pr,strcat(exportfigures, filesep, datasetsNames{experiment}, '_pr_re_ho.pdf'));
                
            end
            
        end
        
    end

    
end

xlabel('Recall');
ylabel('Precision');
        
legend('DRIVE - UP', 'DRIVE - FCCRF', 'STARE-A - UP', 'STARE-A - FCCRF', 'STARE-B - UP', 'STARE-B - FCCRF', 'CHASEDB1-A - UP', 'CHASEDB1-A - FCCRF', 'HRF - UP', 'HRF - FCCRF')