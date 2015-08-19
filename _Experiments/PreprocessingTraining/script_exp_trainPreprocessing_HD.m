

% folder = 'C:\_tmi_experiments\CHASEDB1\training';
% outputs = 'C:\Users\USUARIO\Dropbox\RetinalImaging\Writing\tmi2015paper\experiments\preprocessingExperiments\gaussianFilter\CHASEDB';
% dataset_name = 'CHASEDB';
% windowSizes = 25:2:205;
% fakepad_size = 100;

folder = 'C:\_tmi_experiments\STARE\training';
outputs = 'C:\Users\USUARIO\Dropbox\RetinalImaging\Writing\tmi2015paper\experiments\preprocessingExperiments\gaussianFilter\STARE';
dataset_name = 'STARE';
windowSizes = 25:2:81;
fakepad_size = 50;

% folder = 'C:\_tmi_experiments\ARIA\ALL\training';
% outputs = 'C:\Users\USUARIO\Dropbox\RetinalImaging\Writing\tmi2015paper\experiments\preprocessingExperiments\gaussianFilter\ARIA_all';
% dataset_name = 'ARIA';
% windowSizes = 25:2:80;
% fakepad_size = 50;

% folder = 'C:\_tmi_experiments\DRIVE\training';
% outputs = 'C:\Users\USUARIO\Dropbox\RetinalImaging\Writing\tmi2015paper\experiments\preprocessingExperiments\gaussianFilter\DRIVE';
% dataset_name = 'DRIVE';
% windowSizes = 25:2:65;
% fakepad_size = 50;

% folder = 'C:\_tmi_experiments\HRF\ALL\training';
% outputs = 'C:\Users\USUARIO\Dropbox\RetinalImaging\Writing\tmi2015paper\experiments\preprocessingExperiments\gaussianFilter\HRF_all';
% dataset_name = 'HRF';
% windowSizes = 101:2:161;
% fakepad_size = 100;



% ----------------------------------------------------------------

% Get images and filenames
[images, labels, masks] = getLabeledDataFilenames(folder);

   
% initialize matrix with performances per image and parameter
aucs_image_featparam = zeros(length(images), length(windowSizes));

% compute performance for each image
for j = 1 : length(images)

    % open image, labels and mask
    I = imread(strcat(folder, filesep, 'images', filesep, images{j}));
    I = double(I(:,:,2));
    label = imread(strcat(folder, filesep, 'labels', filesep, labels{j})) > 0;
    mask = imread(strcat(folder, filesep, 'masks', filesep, masks{j})) > 0;
    mask = mask(:,:,1)>0;
    % border expansion
    I = fakepad(I, mask, 5, fakepad_size);
    mask2 = fakepad(double(mask), mask, 5, fakepad_size);
    % assign -1 to the negative class
    label = double(label);
    label(label==0) = -1;



    % for each parameter
    for k = 1 : length(windowSizes)

        % remove background
        background = roifilt2(fspecial('gaussian', [windowSizes(k) windowSizes(k)], (windowSizes(k)-1)/3),I,mask2>0);
        f = imcomplement(I - double(background));

        [~,~,info] = vl_roc(double(label(mask)), f(mask));
        aucs_image_featparam(j,k) = info.auc;
    end

    j

end
    
figure, imagesc(aucs_image_featparam);
    
aucs_preprocessing_featparam = mean(aucs_image_featparam);
    

figure, plot(windowSizes, aucs_preprocessing_featparam);
xlabel('Window size');
ylabel('AUC');
title('Window size vs. AUC');
legend('Preprocessing');
print(strcat(outputs, filesep, dataset_name, '_searchWindowSizes'), '-dpdf')
print(strcat(outputs, filesep, dataset_name, '_searchWindowSizes'), '-dpng')
