
function [featureFilter] = generateFeatureFilter(selectedFeatures, sizes)

    featureFilter = [];
    for i = 1 : length(selectedFeatures)
        featureFilter = cat(1, featureFilter, ones(sizes(i),1) * selectedFeatures(i));
    end
    featureFilter = logical(featureFilter);

end