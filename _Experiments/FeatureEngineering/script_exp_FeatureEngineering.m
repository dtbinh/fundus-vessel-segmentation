
folder = 'C:\_tmi_experiments\DRIVE\training-validation';
windowSize = 31;

parametersSize = 3:2:15;
preprocessingMethods = 1:2;
fakepad_extension = 50;


% ----------------------------------------------------------------

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
        % border expansion
        I = fakepad(I, mask, 5, fakepad_extension);
        
        % preprocess the image
        if (i==2)
            % remove background
            background = medfilt2(I, [windowSize windowSize]);
            I = I - double(background);
        end
        
        % for each parameter
        for k = 1 : length(parametersSize)
            options.FrangiScaleRange = [0 parametersSize(k)];
            f = Frangi1998(I, mask, 0, options);
            [~,~,~,aucs_image_featparam(j,k)] = perfcurve(double(label(mask)), f(mask), 1);
        end
        
    end
    
    figure, imagesc(aucs_image_featparam);
    
    aucs_preprocessing_featparam(i,:) = mean(aucs_image_featparam);
    
end

figure
plot([parametersSize; parametersSize]', aucs_preprocessing_featparam');
xlabel('Parameter value');
ylabel('AUC');
title('Frangi - Parameters on DRIVE');
legend('Without preprocessing', 'With preprocessing');
