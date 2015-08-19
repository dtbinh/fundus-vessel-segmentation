
function [segmentation] = CRFInference(config, unaryPotentials, mask, pairwiseFeatures, weights)
      
     % Check what version of the CRF it is going to be utilized 
     if strcmp(config.crfVersion,'local-neighborhood-based')
        segmentation = logical(LocalNeighborhoodBasedCRF(unaryPotentials, mask, pairwiseFeatures, weights));
     else
        segmentation = logical(FullyCRFWrapperWithGivenPairwises(config, unaryPotentials, mask, pairwiseFeatures, weights));
     end
    
end