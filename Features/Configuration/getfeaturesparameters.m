
% Generic parameters
featconfig.generic_scales = [1 2 4 8];
featconfig.generic_length = 15;
featconfig.generic_angles = 0:15:179;

% Matched Filter Response
featconfig.MatchedFilterResponse_L = 9;

% Nguyen et al, 2013
% Multiscale line detector
featconfig.Nguyen2013_w = featconfig.generic_length;
featconfig.Nguyen2013_step = 2;

% Zana et al, 2001
featconfig.Zana2001_length = 9;

% Canny edge detector
featconfig.Canny_thresholds = 0.1:0.2:0.9;



% FEATURES SIZES
% Assign the size of every feature
featconfig.size_CannyEdgeDetector = 1;
featconfig.size_DivergenceFeature = 3;
featconfig.size_EntropyOverScales = 1;
featconfig.size_Frangi1998 = 1;
featconfig.size_GradientFeatures = 2;
featconfig.size_KirschBasedGradient = 1;
featconfig.size_LaplacianOfGaussian = 1;
featconfig.size_Lupascu2010ElongatedFeatures = 5;
featconfig.size_Marin2011 = 5;
featconfig.size_Marin2011EnhancedImage = 1;
featconfig.size_Marin2011HomogeneizedImage = 1;
featconfig.size_MartinezPerez1999 = 1;
featconfig.size_MatchedFilterResponses = length(featconfig.generic_scales);
featconfig.size_MorletWavelet = 2;
featconfig.size_Nguyen2013 = 1;
featconfig.size_Ricci2007 = 2;
featconfig.size_Saleh2013 = 1;
featconfig.size_Sinthanayothin1999 = 1;
featconfig.size_Soares2006 = length(featconfig.generic_scales);
featconfig.size_Sofka2006 = 1;
featconfig.size_Staal2004 = 1;
featconfig.size_Zana2001 = 2;
featconfig.size_Lindeberg2001 = 3;
featconfig.size_Intensities = 1;

% Size of the longest feature vector
featconfig.longestfeaturevector = featconfig.size_CannyEdgeDetector + ...
    featconfig.size_DivergenceFeature + featconfig.size_EntropyOverScales + featconfig.size_Frangi1998 + ...
    featconfig.size_GradientFeatures + featconfig.size_KirschBasedGradient + featconfig.size_LaplacianOfGaussian + ...
    featconfig.size_Lupascu2010ElongatedFeatures + featconfig.size_Marin2011 + featconfig.size_Marin2011EnhancedImage + ...
    featconfig.size_Marin2011HomogeneizedImage + featconfig.size_MartinezPerez1999 + featconfig.size_MatchedFilterResponses + ...
    featconfig.size_MorletWavelet + featconfig.size_Nguyen2013 + featconfig.size_Ricci2007 + featconfig.size_Saleh2013 + ...
    featconfig.size_Sinthanayothin1999 + featconfig.size_Soares2006 + featconfig.size_Sofka2006 + featconfig.size_Staal2004 + ...
    featconfig.size_Zana2001 + featconfig.size_Lindeberg2001 + featconfig.size_Intensities;
