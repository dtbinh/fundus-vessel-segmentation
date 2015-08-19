
% Select unary features
%unaryFeatures = features_prompt('Unary features:');
unaryFeatures = [0 0 1 0 0 1 0 0 0 0 0 0 0 1 0];
param.unaryFeaturesConfiguration = getFeatureConfiguration(unaryFeatures);

% Select pairwise features
%pairwiseFeatures = features_prompt('Pairwise features:');
pairwiseFeatures = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 1];
param.pairwiseFeaturesConfiguration = getFeatureConfiguration(pairwiseFeatures);

param.humanObserverPerformance = [0.7763 0.9723];
param.biasMultiplier = 200000000;
param.learnC = 1;
param.numberOfFeatures = 15;
param.performModelSelection = 0;
param.crfVersion = 'fully-connected';
%param.crfVersion = 'local-neighborhood-based';

root = 'C:\_miccaiExperiments\crossvalidation\STARE';

[results] = crossvalidateSegmentation(root, param);

save('C:\crossValidatedSTARE.mat', 'results'); 