function [edgefeatures] = CannyEdgeDetector(I, mask, unary, options)

    % Assign the sigmas and the thresholds
    if (~exist('options','var'))
        sigmas = sqrt([1 2 3 4]);
    else
        sigmas = options.sigmas;
    end
    thresh = 0.1:0.2:0.9;

    % Generate multiscale images
    multiscales = cell(length(sigmas));
    for i = 1 : length(sigmas)
        multiscales{i} = imfilter(I, fspecial('gaussian', [ceil(3 * sigmas(i)) ceil(3 * sigmas(i))], sigmas(i)));
    end
    
    % Find edges using different sigmas and thresholds and accumulate
    % them
    multiscaleEdges = zeros(size(I,1), size(I,2), length(sigmas));
    for s = 1 : length(sigmas)
        for t = thresh
            multiscaleEdges(:,:,s) = multiscaleEdges(:,:,s) + edge(multiscales{s}, 'canny', t);
        end
    end
    
    % Reduce dimensionality if it is a pairwise feature
    if (unary)
        % Return all the sigmas
        edgefeatures = multiscaleEdges;
    else
        % Get the maximum response over sigmas
        edgefeatures = max(multiscaleEdges, [], 3);
    end
      
end