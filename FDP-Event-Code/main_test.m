%% initializing
% informations of model
loadGlobalVariable
eventIndex = [11:14]; 
altmanIndex = [6:10];

%% build models and test
% set file name of the 10 fold  
fileName = sprintf('%s_%dfold.mat', DATASETNAME, KFOLDSIZE);

% initialize models (Baseline & Proposed)
BASELINE = EnsembleBaggedTreeModel(KFOLDSIZE, thresholdList, 'ALTMAN');
PROPOSED = EnsembleBaggedTreeModel(KFOLDSIZE, thresholdList, 'ALTMAN+Event');

% initialize sample set
sampleSet = DataSet(KFOLDSIZE, DATASETPATH, fileName);

% build models and test
    for foldIter = 1:KFOLDSIZE
        % Baseline 
        BaseLineSelectedFeatureSet = altmanIndex;
        BASELINE.trainModelandRecord(sampleSet.getTrainingSets(foldIter), BaseLineSelectedFeatureSet, foldIter);
        [confusionMatrix, resultList, probResult ] = BASELINE.testModelwithThreshold(sampleSet.getTestingSets(foldIter), BASELINE.featureSet{foldIter}, BASELINE.model{foldIter});
        %[BaseLineconfusionMatrix, BaseLineresultList, BaseLineprobResult ] = BASELINE.testModelwithThreshold(sampleSet.getTestingSets(foldIter), BASELINE.featureSet{foldIter}, BASELINE.model{foldIter});
        BASELINE.confusionMatrix = [BASELINE.confusionMatrix confusionMatrix];
        BASELINE.prob{foldIter} = probResult;
        BASELINE.testingResult{foldIter} = resultList;
        
        % Proposed
        ProposedSelectedFeatureSet = [altmanIndex eventIndex];
        PROPOSED.trainModelandRecord(sampleSet.getTrainingSets(foldIter), ProposedSelectedFeatureSet, foldIter);
        [confusionMatrix, resultList, probResult ] = PROPOSED.testModelwithThreshold(sampleSet.getTestingSets(foldIter), PROPOSED.featureSet{foldIter}, PROPOSED.model{foldIter});
        %[ProposedconfusionMatrix, ProposedresultList, ProposedprobResult ] = PROPOSED.testModelwithThreshold(sampleSet.getTestingSets(foldIter), PROPOSED.featureSet{foldIter}, PROPOSED.model{foldIter});
        PROPOSED.confusionMatrix = [PROPOSED.confusionMatrix confusionMatrix];
        PROPOSED.prob{foldIter} = probResult;
        PROPOSED.testingResult{foldIter} = resultList;
    end
%% test results

% Initialize the class of model analyzes
modelAnalysis = ModelAnalysis(costList, thresholdList, sampleSet.getAllData());
% Draw DET curve
selectedThres = modelAnalysis.drawDetCurve([0 1 0 1], BASELINE, PROPOSED);
% Wilcoxon-signed rank test
[pvalue, ~] = modelAnalysis.doWilcoxonTest(selectedThres, [BASELINE; PROPOSED]);

% See the detailed information of Type I and Type II
[cost, typeI, typeII, averageofTestResultandMissclassificationCosts, chosenIndex] = modelAnalysis.getCostPackage(PROPOSED, selectedThres(2,:));

disp(cost)
disp(pvalue)
disp(typeI)
disp(typeII)

