
function [closed] = KirschBasedGradient(I, mask, unary)

    % Create a bunch of filters to enhance edges    
    filters = zeros(3, 3, 8);
    filters(:,:,1) = [5 -3 -3; 5 0 -3; 5 -3 -3];
    filters(:,:,2) = [-3 -3 -3; 5 0 -3; 5 5 -3];
    filters(:,:,3) = [-3 -3 -3; 5 0 -3; 5 5 -3];
    filters(:,:,4) = [-3 5 5; -3 0 5; -3 -3 -3];
    filters(:,:,5) = [-3 -3 -3; -3 0 -3; 5 5 5];
    filters(:,:,6) = [5 5 5; -3 0 -3; -3 -3 -3];
    filters(:,:,7) = [-3 -3 -3; -3 0 5; -3 5 5];
    filters(:,:,8) = [5 5 -3; 5 0 -3; -3 -3 -3];
    
    % Compute the max response over filters
    grayscaleimage = (zeros(size(I,1), size(I,2), 8));
    for i = 1 : 8
        grayscaleimage(:,:,i) = (conv2(double(I),filters(:,:,i),'same'));
    end
    grayscaleimage = max(grayscaleimage, [], 3);
    
    % Apply a morphological closing
    closed = imclose(grayscaleimage, strel('square',3)) .* double(mask);
    
end