clc;
clear all;
% Load mat file
load("HHT\HHT Lab Data\HHT_Lab\HHT_data_L1R1.mat");
load("HHT\HHT Lab Data\HHT_Lab\HHT_data_L1R0.mat");

% Merge both data L1R0 and L1R1 into one matrix
X = vertcat(HHT_data_L1R1, HHT_data_L1R0);

numberDimensions = 3;
% Use PCA function to reduce dimension of The Raw Feature from 25 dimension to 3 dimension
% get the score value
% the first column is corresponds to PC1
% the second column is corresponds to PC2
[coeff, score, latent] = pca(X);

pc1_L1R1 = score(1:250, 1);
pc2_L1R1 = score(1:250, 2);
pc3_L1R1 = score(1:250, 3);

pc1_L1R0 = score(250:500, 1);
pc2_L1R0 = score(250:500, 2);
pc3_L1R0 = score(250:500, 3); 

% Visualize the result using scatter function
% Divide the result of PCA into half
% the first half is L1R0
figure
scatter3(pc1_L1R0, pc2_L1R0, pc3_L1R0, 'Marker', '^', 'MarkerFaceColor', 'blue');

hold on
% the second half is L1R1
scatter3(pc1_L1R1, pc2_L1R1, pc3_L1R1, 'Marker', 's', 'MarkerFaceColor', 'red');

hold off
grid on
