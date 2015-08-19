

% folder = 'C:\_tmi_experiments\CHASEDB1\training';
% outputs = 'C:\Users\USUARIO\Dropbox\RetinalImaging\Writing\tmi2015paper\experiments\preprocessingExperiments\gaussianFilter\CHASEDB';
% dataset_name = 'CHASEDB';
% windowSizes = 65:6:235;
% fakepad_size = 100;

% folder = 'C:\_tmi_experiments\STARE\training';
% outputs = 'C:\Users\USUARIO\Dropbox\RetinalImaging\Writing\tmi2015paper\experiments\preprocessingExperiments\gaussianFilter\STARE';
% dataset_name = 'STARE';
% windowSizes = 25:6:145;
% fakepad_size = 50;

% folder = 'C:\_tmi_experiments\ARIA\ALL\training';
% outputs = 'C:\Users\USUARIO\Dropbox\RetinalImaging\Writing\tmi2015paper\experiments\preprocessingExperiments\gaussianFilter\ARIA_all';
% dataset_name = 'ARIA';
% windowSizes = 25:6:125;
% fakepad_size = 50;

folder = 'C:\_tmi_experiments\DRIVE\training';
%outputs = 'C:\Users\USUARIO\Dropbox\RetinalImaging\Writing\tmi2015paper\experiments\preprocessingExperiments\gaussianFilter\DRIVE';
outputs = 'G:\Dropbox\RetinalImaging\Writing\tmi2015paper\experiments\preprocessingExperiments\gaussianFilter\DRIVE';
dataset_name = 'DRIVE';
windowSizes = 25:6:65;
fakepad_size = 50;

% folder = 'C:\_tmi_experiments\HRF\ALL\training';
% outputs = 'C:\Users\USUARIO\Dropbox\RetinalImaging\Writing\tmi2015paper\experiments\preprocessingExperiments\gaussianFilter\HRF_all';
% dataset_name = 'HRF';
% windowSizes = 105:10:405;
% fakepad_size = 100;



% ----------------------------------------------------------------

% Open images
config.preprocessing.fakepad_extension = fakepad_size;
[images, labels, masks, numberOfPixels] = openLabeledData(folder, config.preprocessing);

% Concatenate labels
labels_ = [];
masks2 = masks;
for i = 1 : length(labels)
    % array of labels
    lab = labels{i};
    lab = lab(masks{i});
    labels_ = [labels_; lab(:)];
    % array of masks
    masks{i} = masks{i} > 0;
    % array of extended masks
    images{i} = fakepad(double(images{i}), double(masks{i}), 5, fakepad_size);
    mm = double(masks{i});
    mm(mm==1) = 255;
    masks2{i} = fakepad(mm, masks{i}, 5, fakepad_size)>0;
    i
end

%
% Preprocess each image using the given window size
figure
hold all;
aucs = zeros(length(windowSizes),1);
xlabel('False positive rate');
ylabel('True positive rate');
title(strcat('ROC curve - Without CLAHE Preprocessing - ', {' '}, dataset_name));

for i = 1 : length(windowSizes)
    
    preprocessed = [];
    for j = 1 : length(images)
        
        I = images{j};
        background = roifilt2(fspecial('gaussian', [windowSizes(i) windowSizes(i)], (windowSizes(i)-1)/3), I, masks2{j});
        I = I - double(background);
        
        I = imcomplement(I);
        I = I(masks{j});
        
        preprocessed = [preprocessed; I(:)];
        
        fprintf(strcat(num2str(j),'-'));
        
    end
    fprintf('\n');
    
    % generate ROC curve without using CLAHE
    [~,~,info] = vl_pr(double(labels_), preprocessed);
    aucs(i) = info.auc;
   
    disp(i);
    
end
hold off





figure, plot(windowSizes, aucs);
xlabel('Window size');
ylabel('AUC');
title('Window size vs. AUC');
legend('Preprocessing');
print(strcat(outputs, filesep, dataset_name, '_searchWindowSizes'), '-dpdf')
print(strcat(outputs, filesep, dataset_name, '_searchWindowSizes'), '-dpng')

clear preprocessed