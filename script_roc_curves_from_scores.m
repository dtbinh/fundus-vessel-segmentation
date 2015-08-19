
warning('off','all');

% Datasets names
datasetsNames = {...
       'DRIVE', ...
       'STARE-A', ...
       'STARE-B', ...
       'CHASEDB1-A',...
       'CHASEDB1-B'...%, ...
       'HRF'...
    };

%cc=linspecer(length(datasetsNames));
%h_roc = figure;


humanObserverPerformances = [...
    0.7760, 0.9730; ...
    0.9385, 0.9365; ...
    0.9022, 0.9341; ...
    0.7425, 0.9793; ...
    0.8362, 0.9724];

crfVersions = {'up','fccrf'};

% Root folder where the results are going to be stored
rootResults = 'G:\Dropbox\RetinalImaging\Writing\tmi2015paper\paper\figures\rocCurves\SCORES';

exportfigures = 'G:\Dropbox\RetinalImaging\Writing\tmi2015paper\paper\figures\rocCurves';


for experiment = 1 : length(datasetsNames)

    figure;
    hold on;
    
    load(strcat(rootResults, filesep, datasetsNames{experiment}, '_labels.mat'));
    
    for crfver = 1 : length(crfVersions)
        
            load(strcat(rootResults, filesep, datasetsNames{experiment}, '_', crfVersions{crfver}, '.mat'));
        
            if (strcmp(crfVersions{crfver},'up'))
                
                % Generate the ROC curve for unary potentials
                [ses,sps,infoUP] = vl_roc(double(labels), double(results_up.qualityMeasures.unaryPotentials));
                plot(1 - sps, ses, '--');
                axis([0 0.5 0.5 1]);
                hold on;
                
            else
                
                [ses,sps,infoFCCRF] = vl_roc(double(labels), double(results_fullycrf.qualityMeasures.scores));
                plot(1 - sps, ses,'-');
                if ~(strcmp(datasetsNames{experiment},'HRF'))
                    scatter(1-humanObserverPerformances(experiment,2), humanObserverPerformances(experiment,1));
                    legend(strcat('Unary potentials - AUC=',num2str(infoUP.auc)),strcat('Fully-connected CRF - AUC=',num2str(infoFCCRF.auc)),'2nd human observer', 'Location','southeast');
                else
                    legend(strcat('Unary potentials - AUC=',num2str(infoUP.auc)),strcat('Fully-connected CRF - AUC=',num2str(infoFCCRF.auc)), 'Location','southeast');
                end
                title(datasetsNames{experiment});
                xlabel('FPR (1 - Specificity)');
                ylabel('TPR (Sensitivity)');
                
                hold off;
                
                
                saveas(gcf, strcat(exportfigures, filesep, datasetsNames{experiment}, '_all_roc_ho.pdf'));
                
            end
        
    end
    
end