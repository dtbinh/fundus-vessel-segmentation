
% Load state of the art values
stateOfTheArtDRIVE;
stateOfTheArtWorks = stateOfTheArtDRIVEWorks;
stateOfTheArtSensitivity = stateOfTheArtDRIVESe;
stateOfTheArtSpecificity = stateOfTheArtDRIVESp;

humanExpertSensitivity = 0.776;
humanExpertSpecificity = 0.973;

ourMethodSensitivities = 0.7660;
ourMethodSpecificities = 0.9732;

localNeighborhoodSensitivity = 0.6978;
localNeighborhoodSpecificity = 0.9848;

figure;

% Set the axis labels
xlabel('Specificity');
ylabel('Sensitivity');

% Draw the other works
hold on
color = linspace(1,10,length(stateOfTheArtSensitivity));
for i = 1 : length(stateOfTheArtSensitivity)
    scatter(stateOfTheArtSpecificity(i), stateOfTheArtSensitivity(i), 25, color(i), 'fill');
end

% Draw the human expert
scatter(humanExpertSpecificity, humanExpertSensitivity, 36, '*', 'r');

% Draw the local neighborhood based values
scatter(localNeighborhoodSpecificity, localNeighborhoodSensitivity, 36, '*', 'b');

% Draw out method metrics
scatter(ourMethodSpecificities, ourMethodSensitivities, '+', 'b');

theLegend = [stateOfTheArtWorks {'2nd human observer'} {'Local-neighborhood based CRF'} {'Our method'}];
legend(theLegend);    

% Set the axis scale
axis([0.6 1.0 0.6 1.0]);

drawnow            
hold off
