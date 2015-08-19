
function [roc_X, roc_Y, AUC] = rocCurveEvaluation(scores, labels)

    % build the roc curve
    [roc_X, roc_Y, ~, AUC, ~, ~, ~] = perfcurve(labels, scores, 1);

end