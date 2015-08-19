
function [segmentations, qualityMeasures] = getBunchSegmentations(config, data, model)

    % Memory allocation
    segmentations = cell(size(data.images));
    
    % Preallocate quality measures 
    qualityMeasures.se = [];
    qualityMeasures.sp = [];
    qualityMeasures.acc = [];
    qualityMeasures.precision = [];
    qualityMeasures.recall = [];
    qualityMeasures.fMeasure = [];
    qualityMeasures.matthews = [];
    qualityMeasures.auc = [];
    qualityMeasures.aucUP = [];
    qualityMeasures.unaryPotentials = [];
    qualityMeasures.scores = [];
    
    % Segment each individual image in data
    for i = 1:length(data.images)

        % Print the name of the image being processed
        fprintf('Segmenting image number %i/%i\n', i, length(data.images));

        % Get image, mask, annotations, ground truth and features
        mask = data.masks{i};
        y = data.labels{i};
        X = data.unaryFeatures{i};
        pairwiseKernels = data.pairwiseKernels{i};

        % Get the segmentation and the evaluation metrics 
        [segmentations{i}, currentQualityMeasures] = getSegmentationFromData2(config, mask, y, X, pairwiseKernels, model);
        
        % Concatenate quality measures
        qualityMeasures.se = [qualityMeasures.se, currentQualityMeasures.se];
        qualityMeasures.sp = [qualityMeasures.sp, currentQualityMeasures.sp];
        qualityMeasures.acc = [qualityMeasures.acc, currentQualityMeasures.acc];
        qualityMeasures.precision = [qualityMeasures.precision, currentQualityMeasures.precision];
        qualityMeasures.recall = [qualityMeasures.recall, currentQualityMeasures.recall];
        qualityMeasures.fMeasure = [qualityMeasures.fMeasure, currentQualityMeasures.fMeasure];
        qualityMeasures.matthews = [qualityMeasures.matthews, currentQualityMeasures.matthews];
        qualityMeasures.auc = [qualityMeasures.auc, currentQualityMeasures.auc];
        qualityMeasures.aucUP = [qualityMeasures.aucUP, currentQualityMeasures.aucUP];
        qualityMeasures.unaryPotentials = [qualityMeasures.unaryPotentials, currentQualityMeasures.unaryPotentials];
        qualityMeasures.scores = [qualityMeasures.scores, currentQualityMeasures.scores];

    end
    
end