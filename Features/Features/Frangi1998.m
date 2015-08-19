
function [frangiFeature] = Frangi1998(I, mask, unary, options)

    % Set the parameters
    if ~exist('options','var')
        options.FrangiScaleRange = [0 3];
        options.FrangiScaleRatio = 2;
    end
    options.unary = unary;
    
    % Preprocess the image
    I = Intensities(I, mask, unary, options.Intensities);
    
    % Compute features
    [frangiFeature, ~, ~] = FrangiFilter2D(double(I), options);
    
end