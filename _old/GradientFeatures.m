
function [features] = GradientFeatures(I, mask, unary)

    % Set the scales
    sigmas = sqrt([1 2 3 4]);

    % Get gradients and directions
    gradients = zeros(size(I,1), size(I,2), length(sigmas));
    gradientDirections = zeros(size(I,1), size(I,2), length(sigmas));
    for i = 1 : length(sigmas)
        [gradients(:,:,i), gradientDirections(:, :, i)] = imgradient(double((imfilter(I, fspecial('gaussian', [ceil(3 * sigmas(i)) ceil(3 * sigmas(i))], sigmas(i))))));     
    end
    
    % If it is a pairwise feature, reduce dimensionality
    if (~unary)
        gradients = max(gradients, [], 3);
        gradientDirections = mean(gradientDirections, 3);
    end
    
    % Cat features
    features = cat(3, gradients, gradientDirections);
    
end