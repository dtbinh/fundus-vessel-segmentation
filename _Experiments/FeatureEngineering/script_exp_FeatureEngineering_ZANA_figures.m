tic
whereIsDropbox = 'G:';
%whereIsDropbox = 'C:\Users\USUARIO';

% ARIA - ARMD
% imagePath = 'C:\_tmi_experiments\ARIA\ARMD\training\images\05_test.tif';
% maskPath = 'C:\_tmi_experiments\ARIA\ARMD\training\masks\05_test_mask.gif';
% outputPath = strcat(whereIsDropbox,'\Dropbox\RetinalImaging\Writing\tmi2015paper\experiments\featureEngineering\Zana\zana_ARIA\aria_armd_05_test_zana_');
% windowSize = 47;
% padsize = 50;
% options.l = 24;

% ARIA - DR
% imagePath = 'C:\_tmi_experiments\ARIA\diabetic\training\images\(0001)aria_d_26.tif';
% maskPath = 'C:\_tmi_experiments\ARIA\diabetic\training\masks\(0001)aria_d_26_mask.gif';
% outputPath = strcat(whereIsDropbox,'\Dropbox\RetinalImaging\Writing\tmi2015paper\experiments\featureEngineering\Zana\zana_ARIA\aria_diabetic_(0001)aria_d_26_zana_');
% windowSize = 47;
% padsize = 50;
% options.l = 24;

% ARIA - Normal
% imagePath = 'C:\_tmi_experiments\ARIA\normal\training\images\aria_c_1_7.tif';
% maskPath = 'C:\_tmi_experiments\ARIA\normal\training\masks\aria_c_1_7_mask.gif';
% outputPath = strcat(whereIsDropbox,'\Dropbox\RetinalImaging\Writing\tmi2015paper\experiments\featureEngineering\Zana\zana_ARIA\aria_normal_aria_c_1_7_zana_');
% windowSize = 47;
% padsize = 50;
% options.l = 24;

% CHASEDB
% imagePath = 'C:\_tmi_experiments\CHASEDB1\training\images\Image_01L.jpg';
% maskPath = 'C:\_tmi_experiments\CHASEDB1\training\masks\Image_01L_mask.png';
% outputPath = strcat(whereIsDropbox,'\Dropbox\RetinalImaging\Writing\tmi2015paper\experiments\featureEngineering\Zana\zana_CHASEDB\chase_Image_01L_zana_');
% windowSize = 89;
% padsize = 100;
% options.l = 36;

% DRIVE
imagePath = 'C:\_tmi_experiments\DRIVE\training-validation\images\37_training.tif';
maskPath = 'C:\_tmi_experiments\DRIVE\training-validation\masks\37_training_mask.gif';
outputPath = strcat(whereIsDropbox,'\Dropbox\RetinalImaging\Writing\tmi2015paper\experiments\featureEngineering\Zana\zana_DRIVE\drive_37_training_');
windowSize = 43;
padsize = 50;
options.l = 18;

% HRF - DR
% imagePath = 'C:\_tmi_experiments\HRF\diabetic-retinopathy\training\images\03_dr.jpg';
% maskPath = 'C:\_tmi_experiments\HRF\diabetic-retinopathy\training\masks\03_dr_mask.tif';
% outputPath = strcat(whereIsDropbox,'\Dropbox\RetinalImaging\Writing\tmi2015paper\experiments\featureEngineering\Zana\zana_HRF\hrf_dr_03_dr_');
% windowSize = 119;
% padsize = 100;
% options.l = 49;

% HRF - glaucoma
% imagePath = 'C:\_tmi_experiments\HRF\glaucoma\training\images\04_g.jpg';
% maskPath = 'C:\_tmi_experiments\HRF\glaucoma\training\masks\04_g_mask.tif';
% outputPath = strcat(whereIsDropbox,'\Dropbox\RetinalImaging\Writing\tmi2015paper\experiments\featureEngineering\Zana\zana_HRF\hrf_glaucoma_04_g_');
% windowSize = 119;
% padsize = 100;
% options.l = 49;

% HRF - normal
% imagePath = 'C:\_tmi_experiments\HRF\healthy\training\images\04_h.jpg';
% maskPath = 'C:\_tmi_experiments\HRF\healthy\training\masks\04_h_mask.tif';
% outputPath = strcat(whereIsDropbox,'\Dropbox\RetinalImaging\Writing\tmi2015paper\experiments\featureEngineering\Zana\zana_HRF\hrf_healthy_04_h_');
% windowSize = 119;
% padsize = 100;
% options.l = 49;

% STARE
% imagePath = 'C:\_tmi_experiments\STARE\training\images\04_test.tif';
% maskPath = 'C:\_tmi_experiments\STARE\training\masks\04_test_mask_man.gif';
% outputPath = strcat(whereIsDropbox,'\Dropbox\RetinalImaging\Writing\tmi2015paper\experiments\featureEngineering\Zana\zana_STARE\stare_04_test_');
% windowSize = 43;
% padsize = 50;
% options.l = 20;




% -------------------------------------------

% Open the image and get only the green part
I = imread(imagePath);
I = I(:,:,2);

% Open the mask and make it boolean
mask = imread(maskPath);
mask = mask(:,:,1) > 0;

% Border extension
I = fakepad(double(I), double(mask>0), 5, padsize);

% Prepare the image and save it
f = Zana2001(I, mask, false, options);
feature_without_preprocessing = ((f - min(f(mask))) / (max(f(mask)) - min(f(mask)))) .* double(mask);
imwrite(feature_without_preprocessing,strcat(outputPath, 'withoutPreprocessing.png'));

% Estimate the background, remove it from the original image, compute the
% feature, prepare the result and save it
background = roifilt2(fspecial('gaussian', [windowSize windowSize], (windowSize-1)/3),I,mask>0);
feature_with_preprocessing = Zana2001(I - background, mask, false, options);
feature_with_preprocessing = ((feature_with_preprocessing - min(feature_with_preprocessing(mask))) / (max(feature_with_preprocessing(mask)) - min(feature_with_preprocessing(mask)))) .* double(mask);
imwrite(feature_with_preprocessing,strcat(outputPath, 'withPreprocessing.png'));
toc