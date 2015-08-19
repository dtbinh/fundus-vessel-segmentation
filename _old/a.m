
function [sumPairwisePotentials] = a(pairwiseFeatures, weights)

    % Estimate the size of the image
    height = size(pairwiseFeatures, 1);
    width = size(pairwiseFeatures, 2);

    % Get the weighted features
    weightedFeatures = zeros(size(pairwiseFeatures));
    for i = 1 : size(pairwiseFeatures, 3)
        weightedFeatures(:,:,i) = pairwiseFeatures(:,:,i)* weights(i);
    end
    
    % Initialize the vector to be returned
    sumPairwisePotentials = zeros(size(weightedFeatures, 3),1);
    
    % Estimate pairwise potentials
    for i = 1 : size(weightedFeatures, 3)
        
        % Get single pairwise feature
        singlePairwise = weightedFeatures(:,:,i);
        
        % Shift images up, down, left and right to compute the pairwise
        % differences
        shL = zeros(size(singlePairwise));
        shL(1:end,1:end-1) = singlePairwise(1:end,2:end);
        shR = zeros(size(singlePairwise));
        shR(1:end,2:end) = singlePairwise(1:end,1:end-1);
        shD = zeros(size(singlePairwise));
        shD(2:end,1:end) = singlePairwise(1:end-1, 1:end);
        shU = zeros(size(singlePairwise));
        shU(1:end-1,1:end) = singlePairwise(2:end,1:end);
        
        % Get the pairwise potentials for each point
        singlePotential = (abs(singlePairwise - shL) + eps + abs(singlePairwise - shR) + eps + abs(singlePairwise - shU) + eps + abs(singlePairwise - shD) + eps) * 2;
        %singlePotential = singlePotential .* mask;
        
        % Sum up for all pixels
        sumPairwisePotentials(i) = sum(singlePotential(:));

    end


end