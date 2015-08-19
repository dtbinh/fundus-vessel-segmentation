
function [config] = getConfiguration_DRIVE()

    % ---------------------------------------------------------------------

    % Identify data set
    config.dataset = 'DRIVE';

    % Configure paths
    config.dataset_path = 'C:\_tmi_experiments\DRIVE';
    
    % image, labels and masks original folder
    config.training_data_path = strcat(config.dataset_path, filesep, 'training');
    config.validation_data_path = strcat(config.dataset_path, filesep, 'validation');
    config.test_data_path = strcat(config.dataset_path, filesep, 'test');
    
    % output path
    config.output_path = 'C:\Users\USUARIO\Dropbox\RetinalImaging\Writing\tmi2015paper\experiments\featureSelection\DRIVE';

    % ---------------------------------------------------------------------
    % Scale factor
    config.scale_factor = 1;
    
    % ---------------------------------------------------------------------
    % Parameters to learn
    config.learn.modelSelection = 0;
    config.learn.theta_p = 0 * config.learn.modelSelection;
    config.learn.C = 1;
    
    % ---------------------------------------------------------------------
    % CRF configuration
    % CRF version
    % config.crfVersion='fully-connected';
    config.crfVersion = 'local-neighborhood-based';

    config.theta_p.initialValue = 1;
    config.theta_p.increment = 2;
    config.theta_p.lastValue = 15;

    % ---------------------------------------------------------------------
    % SOSVM configuration
    config.C.initialPower = -1;
    config.C.lastPower = 5;
    
    % ---------------------------------------------------------------------
    % General configuration
    [config] = getGeneralConfiguration(config);
    
    % ---------------------------------------------------------------------
    % Unary features
    config.features.unary.unaryFeatures = zeros(config.features.numberFeatures, 1);
    config.features.unary.unaryFeatures(1) = 1;     % Nguyen
    config.features.unary.unaryFeatures(2) = 1;     % Soares
    %config.features.unary.unaryFeatures(4) = 1;    % Azzopardi

    % Pairwise features
    config.features.pairwise.pairwiseFeatures = zeros(config.features.numberFeatures, 1);
    config.features.pairwise.pairwiseFeaturesDimensions = ones(length(config.features.features),1);
    config.features.pairwise.pairwiseFeatures(3) = 1;  % Zana
    %config.features.pairwise.pairwiseFeatures(4) = 1;  % Azzopardi

end