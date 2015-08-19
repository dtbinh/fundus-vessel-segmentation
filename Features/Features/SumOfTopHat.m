
function [result] = SumOfTopHat(I, mask, options)

    % if there are options in the field
    if (exist('options','var'))
        l = options.length;
        angles = options.angles;
    else
        l = 9;
        angles = 0:22.5:180;
    end
    
    % take the complement of the image
    I = imcomplement(I);

    % compute the top hat transformation using structuring elements at
    % different angles
    features = zeros(size(I,1), size(I,2), length(angles));
    for i = 1 : length(angles)
        features(:,:,i) = imtophat(I, strel('line',l,angles(i)));
    end
    
    % take the maximum over angles
    result = sum(features, 3) .* double(mask);


end

