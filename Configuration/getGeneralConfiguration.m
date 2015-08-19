function [config] = getGeneralConfiguration(config)

    % ---------------------------------------------------------------------
    % SOSVM configuration
    config.SOSVM.usePositivityConstraint = 1;
    
    % ---------------------------------------------------------------------
    % Preprocessing
    config.preprocessing.preprocess = 1;
    config.preprocessing.fakepad_extension = ceil( 50 * config.scale_factor );
    config.preprocessing.erosion = 5;%ceil(5 * config.scale_factor);

    % ---------------------------------------------------------------------
    % Model selection metric
    %config.modelSelectionMetric = 'auc';
    %config.modelSelectionMetric = 'matthews';
    config.modelSelectionMetric = 'fMeasure';
    %config.modelSelectionMetric = 'dice';

    % ---------------------------------------------------------------------
    % Feature configurations     
    % Intensities
        options.Intensities.winsize = ceil(35 * config.scale_factor);
        options.Intensities.fakepad_extension = config.preprocessing.fakepad_extension;
        options.Intensities.filter = 'median';
    % Nguyen
        options.Nguyen2013.w = ceil(15 * config.scale_factor);   
        options.Nguyen2013.step = ceil(2 * config.scale_factor);
    % Soares
        options.Soares2006.scales = ceil([2 3 4 5] * config.scale_factor);
    % Zana
        options.Zana2001.l = 9 * config.scale_factor;
        options.Zana2001.winsize = ceil(7 * config.scale_factor);
        options.Zana2001.Intensities = options.Intensities;
    % RESULTS ------------------------------------------------------------

    % General feature configuration
    config.features.features = {... 
        @Nguyen2013, ...
        @Soares2006, ...
        @Zana2001 ...
        };
    config.features.numberFeatures = length(config.features.features);

    % Assign options
    config.features.featureParameters = {...
        options.Nguyen2013, ...
        options.Soares2006, ...
        options.Zana2001 ...
        };
    
    % ---------------------------------------------------------------------
    % CRF configuration
    if strcmp(config.crfVersion,'local-neighborhood-based') % in case the method is local-neighborhood based
        config.learn.theta_p = 0;
    end

    % Theta_p learning
    config.theta_p.values = [3 7 5];
    config.theta_p.values = config.theta_p.values * config.scale_factor;

    % ---------------------------------------------------------------------
    % Constants
    config.biasMultiplier = 1;
    
end