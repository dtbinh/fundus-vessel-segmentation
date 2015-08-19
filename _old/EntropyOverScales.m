
function [feature] = EntropyOverScales(I, mask, unary)

    % Set scales
    sigmas = sqrt([1 2 3 4]);

    % Preallocate the features
    feature = zeros(size(I,1), size(I,2), length(sigmas));
    
    % For each scale, compute the entropy filter
    for i = 1 : length(sigmas)
        feature(:,:,i) = entropyfilt(imfilter(I, fspecial('gaussian', [ceil(3 * sigmas(i)) ceil(3 * sigmas(i))], sigmas(i))), true(3));
    end
    
    % If it is a pairwise feature, get the maximum over scales
    if (~unary)
        feature = max(feature, [], 3);
    end

end