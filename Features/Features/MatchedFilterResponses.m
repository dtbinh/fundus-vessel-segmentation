
function [feature] = MatchedFilterResponses(I, mask, unary, options)

    % Set parameters
    if (~exist('options','var'))
        sigmas = sqrt([1 2 3 4]);
    else
        sigmas = options.sigmas;
    end

    % Set parameters
    angles = 0:15:165;
    L = 9;

    % Convert image to double
    I = double(I);

    % Preallocate the feature
    feature = zeros(size(I, 1), size(I, 2), length(sigmas));
    
    % For each sigma
    for j = 1 : length(sigmas)
    
        % Get the value of sigma
        sigma = sigmas(j);
        
        % Compute the filter bank
        fb = MatchedFilterBank(angles, ceil(3*sigma), sigma);
        %fb = MatchedFilterBank(angles, L, sigma);

        % Generate the convolved maps
        responses = zeros(size(I,1), size(I,2), length(angles));
        for i = 1 : size(fb, 3)

            % Convolve the image using the filter
            responses(:,:,i) = conv2(I, fb(:,:,i), 'same');

        end

        % Assign the maximum over angles
        feature(:,:,j) = max(responses(:,:,1:end-1), [], 3);

    end
    
    % Reduce dimensionality if it is not a unary feature
    if (~unary)
        feature = max(feature,[],3);
    end
        
end




function [filterBank] = MatchedFilterBank(theta, L, sigma)

    % Preallocate the filter bank
    filterBank = zeros(L, floor(6 * sigma + 1), length(theta));
    
    % For each angle
    for i = 1 : length(theta)
        
        % For each coordinate
        xx = 1;
        for x = -3 * sigma : 3 * sigma
            yy = 1;
            for y = floor(-L/2) : floor(L/2)
        
                % Compute u
                u = x * cosd(theta(i)) + y * sind(theta(i));
                
                % Compute the Gaussian kernel
                filterBank(yy, xx, i) = -exp((-u * u) / (2 * sigma * sigma));
                
                yy = yy + 1;
                
            end
            xx = xx + 1;
        end
        
        % Normalize the bank
        sumK = filterBank(:, :, i);
        filterBank(:,:,i) = filterBank(:,:,i) - (sum(sumK(:)) / ((size(filterBank,1) * size(filterBank,2))));
        
    end

end


