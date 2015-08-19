
function [feature] = LaplacianOfGaussian(I, mask, unary)

    % Set the scales
    sigmas = [1 2 3 4];

    % Take the laplacian of gaussian over scales
    logs = zeros(size(I,1), size(I,2), length(sigmas));
    sigmas = sqrt(sigmas);
    counter = 1;
    for sigma = sigmas
        logs(:,:,counter) = imfilter(I, fspecial('log', [ceil(3 * sigma) ceil(3 * sigma)], sigma));
        counter = counter + 1;
    end
    
    % Reduce dimensionality if it is a pairwise feature
    if (unary)
        feature = logs;
    else
        feature = max(logs,[],3);
    end

end