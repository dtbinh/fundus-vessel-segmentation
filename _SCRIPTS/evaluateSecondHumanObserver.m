
testroot = 'C:\_journalExperiments\DRIVE\test';

allQualityMeasures.se = [];
allQualityMeasures.sp = [];
allQualityMeasures.acc = [];
allQualityMeasures.precision = [];
allQualityMeasures.recall = [];
allQualityMeasures.fMeasure = [];

for i = 1 : 20
    
    % Open both the ground truth and the 2nd human observer annotations
    if (i < 10)
        y = imread(strcat(testroot, '\labels\0', num2str(i), '_manual1.gif'));
        yhat = imread(strcat(testroot, '\labels2\0', num2str(i), '_manual2.gif'));
        mask = imread(strcat(testroot, '\masks\0', num2str(i), '_test_mask.gif'));
    else
        y = imread(strcat(testroot, '\labels\', num2str(i), '_manual1.gif'));
        yhat = imread(strcat(testroot, '\labels2\', num2str(i), '_manual2.gif'));
        mask = imread(strcat(testroot, '\masks\', num2str(i), '_test_mask.gif'));
    end
    
    mask(mask>0) = 1;
    mask = logical(mask);
    y(y>0) = 1;
    yhat(yhat>0) = 1;
    
    % Compute quality measures
    qualityMeasures = getQualityMeasures(yhat(mask), y(mask));
    allQualityMeasures.se = [allQualityMeasures.se qualityMeasures.se];
    allQualityMeasures.sp = [allQualityMeasures.sp qualityMeasures.sp];
    allQualityMeasures.acc = [allQualityMeasures.acc qualityMeasures.acc];
    allQualityMeasures.precision = [allQualityMeasures.precision qualityMeasures.precision];
    allQualityMeasures.recall = [allQualityMeasures.recall qualityMeasures.recall];
    allQualityMeasures.fMeasure = [allQualityMeasures.fMeasure qualityMeasures.fMeasure];
    
end

[averageQualityMeasures] = getAverageMeasures(allQualityMeasures);