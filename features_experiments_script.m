% -------------------------------------------------------------------------
%                          FEATURES EXPERIMENTS
% -------------------------------------------------------------------------

% Experiment configuration

% MODEL SELECTION METRICS
param.modelSelectionMetric = 'matthews';

% THINGS TO LEARN
param.learn_theta_p = 0;
param.learnC = 1;
param.performModelSelection = 0;

% BIAS MULTIPLIER
param.biasMultiplier = 1;

% CRF VERSION
param.crfVersion='fully-connected';
%param.crfVersion = 'local-neighborhood-based';

% VALUE OF C
param.C = 10000;
param.c_initialPower = 0;
param.c_lastPower = 6;

% FEATURES SIZES
param.pairwiseFeaturesDimensions = [1 1 1 5 1 1 1 1 1 1 1 1 1 1 1] ;

% FEATURES SELECTED
% Unary features
param.unaryFeatures = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]; 

% Pairwise features
param.pairwiseFeatures = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];


% ----------------------------------------------------------
% DON'T TOUCH THIS

% Feature functions
param.features = {@CannyEdgeDetector, @Frangi1998, ...
    @KirschBasedGradient, ...
    @Marin2011, @Marin2011EnhancedImage, @MartinezPerez1999, @MatchedFilterResponses, ...
    @Nguyen2013, @Ricci2007, @Saleh2013, @Sinthanayothin1999, @Soares2006, @Staal2004, @Zana2001};
param.numberOfFeatures = length(param.features);

% END DON'T TOUCH THIS
% ----------------------------------------------------------


% -------------------------------------------------------------------------
%                            CALL IT, BABE!
% -------------------------------------------------------------------------
% DRIVE ******************************************************************
% param.dataset = 'drive'
% trainingroot = 'C:\_journalExperiments\DRIVE\training'; % TRAINING DATA
% validationroot = 'C:\_journalExperiments\DRIVE\validation'; % VALIDATION DATA
% testroot = 'C:\_journalExperiments\DRIVE\test'; % TEST SET
% STARE ******************************************************************
% param.dataset = 'stare'
% trainingroot = 'C:\_journalExperiments\STARE\training'; % TRAINING DATA
% validationroot = 'C:\_journalExperiments\STARE\validation'; % VALIDATION DATA
% testroot = 'C:\_journalExperiments\STARE\test'; % TEST SET
% CHASEDB1 ***************************************************************
% param.dataset = 'chasedb'
trainingroot = 'C:\_journalExperiments\CHASEDB1\training'; % TRAINING DATA
validationroot = 'C:\_journalExperiments\CHASEDB1\validation'; % VALIDATION DATA
testroot = 'C:\_journalExperiments\CHASEDB1\test'; % TEST SET


[results, param] = retinalVesselSegmentation2(trainingroot, validationroot, testroot, param);

