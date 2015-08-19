
warning('off','all');

% Datasets names
% datasetsNames = {...
% %       'DRIVE', ...
%         'STARE-A' ...
%         'STARE-B' ...
% %        'CHASEDB1-A',...
% %        'HRF'...
%     };
% datasetsNames = {...
%         'STARE-A' ...
%         'STARE-B' ...
%         'CHASEDB1-B'...
%     };
datasetsNames = {...
      'DRIVE', ...
      'CHASEDB1-A',...
      'HRF'...
    };

cc=linspecer(length(datasetsNames));
h_roc = figure;
axis([0 0.5 0.5 1]);
grid on
hold on
xlabel('FPR (1 - Specificity)');
ylabel('TPR (Sensitivity)');


% humanObserverPerformances = [...
% %    0.7760, 0.9730; ...
%     0.9385, 0.9365; ...
%     0.9022, 0.9341; ...
% %    0.7425, 0.9793; ...
%     0.8362, 0.9724];
% humanObserverPerformances = [...
%     0.9385, 0.9365; ...
%     0.9022, 0.9341; ...
%     0.8362, 0.9724];
humanObserverPerformances = [...
    0.7760, 0.9730; ...
    0.7425, 0.9793];
    


% Flag indicating if the value of C is going to be tuned according to the
% validation set
learnC = 1;
% CRF versions that are going to be evaluated
crfVersions = {'up','fully-connected'};

% C values
cValue = 10^2;

% Root dir where the data sets are located
rootDatasets = '/home/ignacioorlando/_tmi_experiments';

% Root folder where the results are going to be stored
rootResults = '/home/ignacioorlando/results-last-all';


exportfigures = '/home/ignacioorlando/';



% Creating data set paths
datasetsPaths = cell(length(datasetsNames), 1);
for i = 1 : length(datasetsNames)
    datasetsPaths{i} = strcat(rootDatasets, filesep, datasetsNames{i});
end

% Creating results paths
resultsPaths = cell(length(datasetsNames), 1);
for i = 1 : length(datasetsNames)
    resultsPaths{i} = strcat(rootResults, filesep, datasetsNames{i});
end



legends_entries = {};
leg_counter = 1;
for experiment = 1 : length(datasetsNames)

    for crfver = 1 : length(crfVersions)
        
        % Load the configuration
        load(strcat(resultsPaths{experiment}, filesep, crfVersions{crfver}, filesep, 'config.mat'));
        root = strcat(resultsPaths{experiment}, filesep, crfVersions{crfver});
        config.compute_scores = 1;
        config.preprocessing.removeBackground = 0;
        config.experiment = crfVersions{crfver};

        % Load the model
        load(strcat(resultsPaths{experiment}, filesep, crfVersions{crfver}, filesep, 'model.mat'));

        % Open test data
        [testdata.images, testdata.labels, testdata.masks, testdata.numberOfPixels] = openLabeledData(strcat(datasetsPaths{experiment}, filesep, 'test'), config.preprocessing);

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
        
            % encode labels
            yy = [];
            for i = 1 : length(testdata.labels)
                y = double(testdata.labels{i} > 0);
                y = y(testdata.masks{i});
                y(y==0) = -1;
                yy = [yy; y];
            end

            % if unary potentials
            if (strcmp(crfVersions{crfver},'up'))
                
                % Generate the ROC curve for unary potentials
                [ses,sps,infoUP] = vl_roc(double(yy), double(results.qualityMeasures.unaryPotentials));
                % plot the curve                
                plot(1 - sps, ses, '--', 'color', cc(experiment,:));
                
                % add the legend entry
                if ~(strcmp(datasetsNames{experiment},'CHASEDB1-A'))
                    legends_entries{leg_counter} = strcat(datasetsNames{experiment}, ' - UP - (AUC=', num2str(infoUP.auc),')');
                else
                    legends_entries{leg_counter} = strcat('CHASEDB1 - UP - (AUC=', num2str(infoUP.auc),')');
                end
                
            else
                
                % Generate the ROC curve for unary and pairwise potentials
                [ses,sps,infoFCCRF] = vl_roc(double(yy), double(results.qualityMeasures.scores));
                % plot the curve
                plot(1 - sps, ses,'-', 'color', cc(experiment,:));
                
                % if chasedb1-a is not the data set
                if ~(strcmp(datasetsNames{experiment},'CHASEDB1-A'))
                    
                    % add the legend
                    legends_entries{leg_counter} = strcat(datasetsNames{experiment}, ' - FC-CRF - (AUC=', num2str(infoFCCRF.auc), ')');
                    % if it is not hrf, show the second human observer
                    % performance
                    if ~(strcmp(datasetsNames{experiment},'HRF'))
                        scatter(1-humanObserverPerformances(experiment,2), humanObserverPerformances(experiment,1), 'MarkerEdgeColor',cc(experiment,:), 'MarkerFaceColor',cc(experiment,:));
                        leg_counter = leg_counter + 1;
                        legends_entries{leg_counter} = strcat(datasetsNames{experiment}, ' - 2nd HO');
                    end       
                    
                else
                    
                    legends_entries{leg_counter} = strcat('CHASEDB1 - FC-CRF - (AUC=', num2str(infoFCCRF.auc), ')');
                    scatter(1-humanObserverPerformances(experiment,2), humanObserverPerformances(experiment,1), 'MarkerEdgeColor',cc(experiment,:), 'MarkerFaceColor',cc(experiment,:));
                    leg_counter = leg_counter + 1;
                    legends_entries{leg_counter} = strcat('CHASEDB1 - 2nd HO');
                    
                end
                
                
            end
            
        end
        
        leg_counter = leg_counter + 1;
        
    end

    legend(legends_entries, 'Location','southeast');
    %saveas(strcat(exportfigures, filesep, '_roccurve.pdf'));
    %savefig(strcat(exportfigures, filesep, '_roccurve.fig'));
    print(strcat(exportfigures, filesep, '_roccurve2.pdf'),'-dpdf');

    

    
end
        