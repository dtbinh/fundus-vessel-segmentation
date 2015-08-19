

function [featconfig] = getFeatureConfiguration(selectedFeatures)

    getfeaturesparameters;
    
    % FEATURE LIST
    featconfig.size_CannyEdgeDetector = featconfig.size_CannyEdgeDetector * selectedFeatures(1);
    featconfig.size_DivergenceFeature = featconfig.size_DivergenceFeature * selectedFeatures(2);
    featconfig.size_EntropyOverScales = featconfig.size_EntropyOverScales * selectedFeatures(3);
    featconfig.size_Frangi1998 = featconfig.size_Frangi1998 * selectedFeatures(4);
    featconfig.size_GradientFeatures = featconfig.size_GradientFeatures * selectedFeatures(5);
    featconfig.size_KirschBasedGradient = featconfig.size_KirschBasedGradient * selectedFeatures(6);
    featconfig.size_LaplacianOfGaussian = featconfig.size_LaplacianOfGaussian * selectedFeatures(7);
    featconfig.size_Lupascu2010ElongatedFeatures = featconfig.size_Lupascu2010ElongatedFeatures * selectedFeatures(8);
    featconfig.size_Marin2011 = featconfig.size_Marin2011 * selectedFeatures(9);
    featconfig.size_Marin2011EnhancedImage = featconfig.size_Marin2011EnhancedImage * selectedFeatures(10);
    featconfig.size_Marin2011HomogeneizedImage = featconfig.size_Marin2011HomogeneizedImage * selectedFeatures(11);
    featconfig.size_MartinezPerez1999 = featconfig.size_MartinezPerez1999 * selectedFeatures(12);
    featconfig.size_MatchedFilterResponses = featconfig.size_MatchedFilterResponses * selectedFeatures(13);
    featconfig.size_MorletWavelet = featconfig.size_MorletWavelet * selectedFeatures(14);
    featconfig.size_Nguyen2013 = featconfig.size_Nguyen2013 * selectedFeatures(15);
    featconfig.size_Ricci2007 = featconfig.size_Ricci2007 * selectedFeatures(16);
    featconfig.size_Saleh2013 = featconfig.size_Saleh2013 * selectedFeatures(17);
    featconfig.size_Sinthanayothin1999 = featconfig.size_Sinthanayothin1999 * selectedFeatures(18);
    featconfig.size_Soares2006 = featconfig.size_Soares2006 * selectedFeatures(19);
    featconfig.size_Sofka2006 = featconfig.size_Sofka2006 * selectedFeatures(20);
    featconfig.size_Staal2004 = featconfig.size_Staal2004 * selectedFeatures(21);
    featconfig.size_Zana2001 = featconfig.size_Zana2001 * selectedFeatures(22);
    featconfig.size_Lindeberg2001 = featconfig.size_Lindeberg2001 * selectedFeatures(23);
    featconfig.size_Intensities = featconfig.size_Intensities * selectedFeatures(24);

    % Get the total number of features for the given configuration
    featconfig.numberOfFeatures = featconfig.size_CannyEdgeDetector + ...
        featconfig.size_DivergenceFeature + featconfig.size_EntropyOverScales + featconfig.size_Frangi1998 + ...
        featconfig.size_GradientFeatures + featconfig.size_KirschBasedGradient + featconfig.size_LaplacianOfGaussian + ...
        featconfig.size_Lupascu2010ElongatedFeatures + featconfig.size_Marin2011 + featconfig.size_Marin2011EnhancedImage + ...
        featconfig.size_Marin2011HomogeneizedImage + featconfig.size_MartinezPerez1999 + featconfig.size_MatchedFilterResponses + ...
        featconfig.size_MorletWavelet + featconfig.size_Nguyen2013 + featconfig.size_Ricci2007 + featconfig.size_Saleh2013 + ...
        featconfig.size_Sinthanayothin1999 + featconfig.size_Soares2006 + featconfig.size_Sofka2006 + featconfig.size_Staal2004 + ...
        featconfig.size_Zana2001 + featconfig.size_Lindeberg2001 + featconfig.size_Intensities;

end
