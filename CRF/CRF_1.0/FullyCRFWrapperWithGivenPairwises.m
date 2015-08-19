
function y = FullyCRFWrapperWithGivenPairwises(config, unaryPotentials, mask, pairwiseFeatures, weights)
    
    % Permute dimensions of the unary potentials
    unaryPotentials = permute(unaryPotentials,[3 1 2]);
    pairwiseFeatures = permute(pairwiseFeatures, [1 2 3]);

    % Get the segmentation
   
    y = (fullyCRFwithGivenPairwises(int32(size(mask, 1)), int32(size(mask, 2)), ...
           single(unaryPotentials), single(pairwiseFeatures), ...
           single(weights), int32(size(pairwiseFeatures, 3)), ...
           single(2 * config.theta_p.finalValues.^2)))>0;

end