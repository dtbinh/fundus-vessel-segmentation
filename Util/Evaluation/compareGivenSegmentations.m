
function [qualityMeasures, averageQualityMeasures] = compareGivenSegmentations(segmentations, masks, groundtruth)
   
    qualityMeasures.se = [];
    qualityMeasures.sp = [];
    qualityMeasures.acc = [];
    qualityMeasures.precision = [];
    qualityMeasures.recall = [];
    qualityMeasures.fMeasure = [];
    qualityMeasures.matthews = [];
    qualityMeasures.dice = [];
    
    for i = 1:length(segmentations)

        disp(i);
        
        mask = masks{i};
        if (size(mask,3)>0)
            mask = mask(:,:,1);
        end
        mask(mask>0) = 1;
        mask(mask<=0) = 0;
        masks{i} = logical(mask);
        
        % Get the evaluation metrics 
        segm = logical(segmentations{i});
        gt = logical(groundtruth{i});
        %figure, imshow(segm);
        %figure, imshow(gt);
        currentQualityMeasures = getQualityMeasures(segm(logical(masks{i})), logical(gt(logical(masks{i}))));
        
        % Concatenate quality measures
        qualityMeasures.se = [qualityMeasures.se, currentQualityMeasures.se];
        qualityMeasures.sp = [qualityMeasures.sp, currentQualityMeasures.sp];
        qualityMeasures.acc = [qualityMeasures.acc, currentQualityMeasures.acc];
        qualityMeasures.precision = [qualityMeasures.precision, currentQualityMeasures.precision];
        qualityMeasures.recall = [qualityMeasures.recall, currentQualityMeasures.recall];
        qualityMeasures.fMeasure = [qualityMeasures.fMeasure, currentQualityMeasures.fMeasure];
        qualityMeasures.matthews = [qualityMeasures.matthews, currentQualityMeasures.matthews];
        qualityMeasures.dice = [qualityMeasures.dice, currentQualityMeasures.dice];

    end
    
    qualityMeasures.table = [qualityMeasures.se; qualityMeasures.sp; qualityMeasures.acc; qualityMeasures.precision; qualityMeasures.recall; qualityMeasures.fMeasure; qualityMeasures.matthews];
    qualityMeasures.table = qualityMeasures.table';
    
    [averageQualityMeasures] = getAverageMeasures2(qualityMeasures);

end


