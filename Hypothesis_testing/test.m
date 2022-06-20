% Wilcoxon signed rank test
 
clc;
clear all;

% see Wilcoxon Test Lab Session PPT page 4 to complete the code
% and adjust to which samples that will be used
% load csv file
load("Hypothesis_testing\groupSample1.mat");
load("Hypothesis_testing\groupSample2.mat");
load("Hypothesis_testing\groupSample3.mat");
load("Hypothesis_testing\groupSample4.mat");
load("Hypothesis_testing\groupSample5.mat");
load("Hypothesis_testing\groupSample6.mat");

% see Wilcoxon Test Lab Session PPT page 5 to complete the code
% performing wilcoxon signed rank test based (small sample size)
% method : exact
[p,h,stats] = signrank(groupSample3(:,1) ,groupSample4(:,1) , 'tail', 'both', 'alpha', 0.05, 'method','exact');

% method : approximate
[p2,h2,stats2] = signrank(groupSample3(:,1), groupSample4(:,1), 'tail', 'both', 'alpha', 0.05, 'method','approximate');

% performing wilcoxon signed rank test based (large sample size)
% method : exact
[p3,h3,stats3] = signrank(groupSample5(:,1), groupSample6(:,1), 'tail', 'both', 'alpha', 0.05, 'method','exact');

% method : approximate
[p4,h4,stats4]= signrank(groupSample5(:,1), groupSample6(:,1), 'tail', 'both', 'alpha', 0.05, 'method','approximate');
