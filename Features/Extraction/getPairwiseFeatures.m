
function [pairwiseKernels] = getPairwiseFeatures(pairwiseFeatures, deviations)

    % Copy pairwise features in pairwise kernels
    pairwiseKernels = pairwiseFeatures;
    
    % For each image
    for i = 1:length(pairwiseFeatures)
        
        % Divide features by the standard deviation.
        pairwiseKernels{i} = bsxfun(@rdivide, pairwiseFeatures{i}, deviations');
        
    end

end