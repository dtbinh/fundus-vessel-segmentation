
% ARIA - ARMD
% imagePath = 'C:\_tmi_experiments\ARIA\ARMD\training\images\05_test.tif';
% maskPath = 'C:\_tmi_experiments\ARIA\ARMD\training\masks\05_test_mask.gif';
% outputPath = 'C:\Users\USUARIO\Dropbox\RetinalImaging\Writing\tmi2015paper\experiments\preprocessingExperiments\gaussianFilter\ARIA_all\aria_armd_05_test_';
% windowSize = 47;
% padsize = 50;

% ARIA - DR
% imagePath = 'C:\_tmi_experiments\ARIA\diabetic\training\images\(0001)aria_d_26.tif';
% maskPath = 'C:\_tmi_experiments\ARIA\diabetic\training\masks\(0001)aria_d_26_mask.gif';
% outputPath = 'C:\Users\USUARIO\Dropbox\RetinalImaging\Writing\tmi2015paper\experiments\preprocessingExperiments\gaussianFilter\ARIA_all\aria_diabetic_(0001)aria_d_26_mask_';
% windowSize = 47;
% padsize = 50;

% ARIA - Normal
% imagePath = 'C:\_tmi_experiments\ARIA\normal\training\images\aria_c_1_7.tif';
% maskPath = 'C:\_tmi_experiments\ARIA\normal\training\masks\aria_c_1_7_mask.gif';
% outputPath = 'C:\Users\USUARIO\Dropbox\RetinalImaging\Writing\tmi2015paper\experiments\preprocessingExperiments\gaussianFilter\ARIA_all\aria_normal_aria_c_1_7_';
% windowSize = 47;
% padsize = 50;

% CHASEDB
% imagePath = 'C:\_tmi_experiments\CHASEDB1\training\images\Image_01L.jpg';
% maskPath = 'C:\_tmi_experiments\CHASEDB1\training\masks\Image_01L_mask.png';
% outputPath = 'C:\Users\USUARIO\Dropbox\RetinalImaging\Writing\tmi2015paper\experiments\preprocessingExperiments\gaussianFilter\CHASEDB\chase_Image_01L_';
% windowSize = 89;
% padsize = 100;

% DRIVE
imagePath = 'C:\_tmi_experiments\DRIVE\training-validation\images\37_training.tif';
maskPath = 'C:\_tmi_experiments\DRIVE\training-validation\masks\37_training_mask.gif';
outputPath = 'C:\Users\USUARIO\Dropbox\RetinalImaging\Writing\tmi2015paper\experiments\preprocessingExperiments\gaussianFilter\DRIVE\drive_37_training_';
windowSize = 43;
padsize = 50;

% HRF - DR
% imagePath = 'C:\_tmi_experiments\HRF\diabetic-retinopathy\training\images\03_dr.jpg';
% maskPath = 'C:\_tmi_experiments\HRF\diabetic-retinopathy\training\masks\03_dr_mask.tif';
% outputPath = 'C:\Users\USUARIO\Dropbox\RetinalImaging\Writing\tmi2015paper\experiments\preprocessingExperiments\gaussianFilter\HRF_all\hrf_dr_03_dr_';
% windowSize = 119;
% padsize = 100;

% HRF - glaucoma
% imagePath = 'C:\_tmi_experiments\HRF\glaucoma\training\images\04_g.jpg';
% maskPath = 'C:\_tmi_experiments\HRF\glaucoma\training\masks\04_g_mask.tif';
% outputPath = 'C:\Users\USUARIO\Dropbox\RetinalImaging\Writing\tmi2015paper\experiments\preprocessingExperiments\gaussianFilter\HRF_all\hrf_glaucoma_04_g_';
% windowSize = 119;
% padsize = 100;

% HRF - normal
% imagePath = 'C:\_tmi_experiments\HRF\healthy\training\images\04_h.jpg';
% maskPath = 'C:\_tmi_experiments\HRF\healthy\training\masks\04_h_mask.tif';
% outputPath = 'C:\Users\USUARIO\Dropbox\RetinalImaging\Writing\tmi2015paper\experiments\preprocessingExperiments\gaussianFilter\HRF_all\hrf_healthy_04_h_';
% windowSize = 119;
% padsize = 100;

% STARE
% imagePath = 'C:\_tmi_experiments\STARE\training\images\04_test.tif';
% maskPath = 'C:\_tmi_experiments\STARE\training\masks\04_test_mask_man.gif';
% outputPath = 'C:\Users\USUARIO\Dropbox\RetinalImaging\Writing\tmi2015paper\experiments\preprocessingExperiments\gaussianFilter\STARE\stare_04_test_';
% windowSize = 43;
% padsize = 50;




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
image_without_preprocessing = ((I - min(I(mask))) / (max(I(mask)) - min(I(mask)))) .* double(mask);
imwrite(image_without_preprocessing,strcat(outputPath, 'withoutPreprocessing.png'));

% Estimate the background, remove it from the original image, prepare the
% result and save it
background = roifilt2(fspecial('gaussian', [windowSize windowSize], (windowSize-1)/3),I,mask>0);
image_with_preprocessing = I - background;
image_with_preprocessing = ((image_with_preprocessing - min(image_with_preprocessing(mask))) / (max(image_with_preprocessing(mask)) - min(image_with_preprocessing(mask)))) .* double(mask);
imwrite(image_with_preprocessing,strcat(outputPath, 'withPreprocessing.png'));