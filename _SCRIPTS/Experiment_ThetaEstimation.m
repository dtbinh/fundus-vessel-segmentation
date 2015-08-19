
% PARAMETERS SETTING
features = {@CannyEdgeDetector, @EntropyOverScales, @Frangi1998, @GradientFeatures, ...
    @KirschBasedGradient, @LaplacianOfGaussian, @Lupascu2010ElongatedFeatures, ...
    @Marin2011, @Marin2011EnhancedImage, @Marin2011HomogeneizedImage, @MartinezPerez1999, @MatchedFilterResponses, ...
    @Nguyen2013, @Ricci2007, @Saleh2013, @Sinthanayothin1999, @Soares2006, @Sofka2006, @Staal2004, ...
    @Zana2001};
numberOfFeatures = length(param.features);
N = 8; % Max number of samples = 2^N


% Open images, labels and masks for the training set
[images, ~, masks, numberOfPixels] = openLabeledData(trainingroot);

dim1 = 0;
for i = 1 : length(masks)
    mask = masks{i};
    dim1 = dim1 + length(find(mask(:)==1));
end;

% For each feature
for f = 2 : numberOfFeatures
    
    % Select features
    selectedFeatures = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
    selectedFeatures(f) = 1;
    
    % Extract pairwise features
    [pairwisefeatures, pairwiseDimensionality] = extractFeaturesFromImages(images, masks, features, selectedFeatures, false);
    
    for pdim = 1 : pairwiseDimensionality
    
        % For each image, assign features to their corresponding position
        % in X
        X = zeros(dim1, 1);
        pos = 1;
        for j = 1 : length(pairwisefeatures)
            p = pairwisefeatures{j}; % Get all features of the j-th image
            p = p(:,pdim);
            X(pos : pos + size(p,1) - 1, 1) = p(:); % Assign the feature
            pos = pos + size(p,1); % Update the first position
        end

        p = X;
        stdevs = zeros(N,1); % Standard deviation of each median
        for n = 1 : N

            disp(strcat('Computing for 2^',num2str(n)));
            toComputeDeviation = zeros(5,1); % Fill an array with 5 different medians
            for i = 1 : 5
                pp = p(:); % get the pairwise feature
                medd = zeros(2^n,1); % n-medians
                for j = 1 : length(medd)
                    [rs, ind] = datasample(pp, 10000, 'Replace', false); % take a random sample
                    pp(ind)=[]; % remove rs from pp (sampling without replacement)
                    medd(j) = abs((median(pdist(rs)))); % estimate the median from the random sample
                end
                toComputeDeviation(i) = median(medd); % median of the n-medians
            end
            disp(toComputeDeviation);
            stdevs(n) = std(toComputeDeviation); % standard deviation of the medians of the n-medians
            disp(stdevs(n));

        end
        plot(stdevs);

    end
        
end