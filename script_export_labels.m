
warning('off','all');

% Datasets names
datasetsNames = {...
      'DRIVE', ...
      'STARE-A', ...
      'STARE-B', ...
      'CHASEDB1-A'...%, ...
      'HRF'...
    };

% Root dir where the data sets are located
rootDatasets = 'C:\_tmi_experiments\';

% Root folder where the results are going to be stored
rootExportLabels = 'C:\Users\USUARIO\Dropbox\RetinalImaging\Writing\tmi2015paper\paper\figures\rocCurves\SCORES';


% Creating data set paths
datasetsPaths = cell(length(datasetsNames), 1);
for i = 1 : length(datasetsNames)
    datasetsPaths{i} = strcat(rootDatasets, datasetsNames{i});
end

% Creating results paths
resultsPaths = cell(length(datasetsNames), 1);
for i = 1 : length(datasetsNames)
    resultsPaths{i} = strcat(rootExportLabels, filesep, datasetsNames{i});
end



for experiment = 1 : length(datasetsNames)
        
    % Open test data
    test_data_path = strcat(datasetsPaths{experiment}, filesep, 'test');
    masksFolder = strcat(test_data_path, filesep, 'masks', filesep);
    labelsFolder = strcat(test_data_path, filesep, 'labels', filesep);
    disp('Loading masks');
    all_masks = openMultipleImages(masksFolder);
    disp('Loading labels');
    all_labels = openMultipleImages(labelsFolder);

    labels = [];
    for i = 1 : length(all_labels)
        lbls = all_labels{i};
        msk = all_masks{i} > 0;
        msk = msk(:,:,1);
        labels = [labels; lbls(msk)];
    end
    labels = double(labels>0);
    labels(labels==0) = -1;
    
    save(strcat(resultsPaths{experiment}, '_labels.mat'), 'labels');
    
end
        