
% -------------------
% NGUYEN
% -------------------

%outputs = 'C:\Users\USUARIO\Dropbox\RetinalImaging\Writing\tmi2015paper\experiments\featureEngineering\Nguyen';
outputs = 'G:\Dropbox\RetinalImaging\Writing\tmi2015paper\experiments\featureEngineering\Nguyen';

% folder = 'C:\_tmi_experiments\ARIA\ALL\training';
% windowSize = 47;
% datasetname = 'ARIA';
% fakepad_extension = 50;
% 
% folder = 'C:\_tmi_experiments\CHASEDB1\training';
% windowSize = 89;
% datasetname = 'CHASEDB';
% fakepad_extension = 50;
% 
folder = 'C:\_tmi_experiments\DRIVE\training-validation';
windowSize = 43;
datasetname = 'DRIVE';
fakepad_extension = 50;
%
% folder = 'C:\_tmi_experiments\HRF\ALL\training';
% windowSize = 119;
% datasetname = 'HRF';
% fakepad_extension = 100;
%
% folder = 'C:\_tmi_experiments\STARE\training';
% windowSize = 43;
% datasetname = 'STARE';
% fakepad_extension = 50;


%parametersSize = 15:2:47;
parametersSize = 10:1:25;



% ----------------------------------------------------------------
preprocessingMethods = 1:2;

% Get images and filenames
[images, labels, masks] = getLabeledDataFilenames(folder);

% aucs <= preprocessing vs feature parameters
aucs_preprocessing_featparam = zeros(length(preprocessingMethods), length(parametersSize));
% for each preprocessing method
for i = 1 : length(preprocessingMethods)
    
    % initialize matrix with performances per image and parameter
    aucs_image_featparam = zeros(length(images), length(parametersSize));
    
    % compute performance for each image
    for j = 1 : length(images)
        
        % open image, labels and mask
        I = imread(strcat(folder, filesep, 'images', filesep, images{j}));
        I = double(I(:,:,2));
        label = imread(strcat(folder, filesep, 'labels', filesep, labels{j})) > 0;
        mask = imread(strcat(folder, filesep, 'masks', filesep, masks{j})) > 0;
        mask = mask(:,:,1)>0;
        % border expansion
        I = fakepad(I, mask, 5, fakepad_extension);
        mask2 = fakepad(double(mask), mask, 5, fakepad_extension);
        % assign -1 to the negative class
        label = double(label);
        label(label==0) = -1;
        
        % preprocess the image
        if (i==2)
            % remove background
            background = roifilt2(fspecial('gaussian', [windowSize windowSize], (windowSize-1)/3),I,mask2>0);
            I = I - double(background);
        end
        
        % for each parameter
        for k = 1 : length(parametersSize)
            options.w = parametersSize(k);
            f = Nguyen2013(I, mask, false, options);
            
            %[~,~,~,aucs_image_featparam(j,k)] = perfcurve2(double(label(mask)), f(mask), 1);
            
            [~,~,info] = vl_pr(double(label(mask)), f(mask));
            aucs_image_featparam(j,k) = info.auc;
        end
        
        j
        
    end
    
    figure, imagesc(aucs_image_featparam);
    
    aucs_preprocessing_featparam(i,:) = mean(aucs_image_featparam);
    
end

figure
plot([parametersSize; parametersSize]', aucs_preprocessing_featparam');
xlabel('Parameter value');
ylabel('AUC');
title(strcat('Nguyen - Parameters on ', {' '}, datasetname));
legend('Without preprocessing', 'With preprocessing', 'Location', 'southeast');
print(strcat(outputs, filesep, 'nguyen_', datasetname), '-dpng');
print(strcat(outputs, filesep, 'nguyen_', datasetname), '-dpdf');
