

dataset = {'DRIVE','CHASEDB1-A','HRF','STARE-A','STARE-B','STARE-C'};
root = 'C:\Users\USUARIO\Dropbox\RetinalImaging\Writing\tmi2015paper\results2\';
export_root = 'C:\Users\USUARIO\Dropbox\RetinalImaging\Writing\tmi2015paper\paper\figures\boxplots';
%metric = 'matthews';
%metric = 'fMeasure';
%metric = 'se';
metric = 'sp';


figure;

for i = 1 : length(dataset)
   
    load(strcat(root, dataset{i}, filesep, 'fully-connected', filesep, 'results.mat'));
    FC = getfield(results.qualityMeasures, metric);
    
    load(strcat(root, dataset{i}, filesep, 'up', filesep, 'results.mat'));
    UP = getfield(results.qualityMeasures, metric);
    
    h = subplot(2,3,i), boxplot([UP',FC'],'labels',{'Unary potentials','FC-CRF'})

    if (strcmp(metric,'matthews'))
        ylabel('MCC');
    elseif (strcmp(metric,'se'))
        ylabel('Sensitivity');
    elseif (strcmp(metric,'sp'))
        ylabel('Specificity');
    elseif (strcmp(metric,'fMeasure'))
        ylabel('F1-score');
    end
    
    title(dataset{i})
    
    
end

if (strcmp(metric,'matthews'))
    metric = 'MCC';
elseif (strcmp(metric,'fMeasure'))
    metric = 'F1-score';
end
saveas(h,strcat(export_root, filesep, 'complete', '_', metric, '.pdf'));