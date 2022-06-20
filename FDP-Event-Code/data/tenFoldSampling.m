function tenFoldSampling(normalizedAltmanEvents)
    DATASETNAME = 'altmanEvents';
    KFOLDSIZE = 10

% run n-nfold 
% get infomation of risk and normal firm
    distressFirmsSet = getDistressDataset(normalizedAltmanEvents);
    nonDistressFirmsSet = getNormalDataset(normalizedAltmanEvents);
    
    % 10 fold partition for distressFirmsSet firms and nonDistressFirmsSet firms (by index)
    distressFirmsIndex = cvpartition(size(distressFirmsSet,1), 'Kfold', KFOLDSIZE);
    nonDistressFirmsIndex = cvpartition(size(nonDistressFirmsSet,1), 'Kfold', KFOLDSIZE);
    
    for KFoldSize = 1 : KFOLDSIZE
        % prepare training data and testing data (get the complete firm data by index)
        trainingSet = [distressFirmsSet(distressFirmsIndex.training(KFoldSize),:); nonDistressFirmsSet(distressFirmsIndex.training(KFoldSize),:)];
        testingSet = [distressFirmsSet(distressFirmsIndex.test(KFoldSize),:); nonDistressFirmsSet(distressFirmsIndex.test(KFoldSize),:)];
        sampleSet.testingSets{KFoldSize} = testingSet;
        sampleSet.trainingSets{KFoldSize} = trainingSet;
        
        % get distressFirmsSet firms and non distressFirmsSet firms 
        distressFirmsSetofTraining = getDistressDataset(trainingSet);
        nonDistressFirmsSetofTraining = getNormalDataset(trainingSet);
        
        % 10 fold partition for trainingSets sets and validation sets (by index)
        distressFirmsIndexofTraining = cvpartition(size(distressFirmsSetofTraining,1),'kfold',KFOLDSIZE);
        nonDistressFirmsIndexofTraining = cvpartition(size(nonDistressFirmsSetofTraining,1),'kfold',KFOLDSIZE);
        
        
        % n fold of training validation sets
        for KFoldSizeofTraining = 1 : KFOLDSIZE
        
            % preapre trainingSets set and validation set  (get the complete firms data by index)
            sampleSet.trainingValidationSets{KFoldSize}.trainingSets{KFoldSizeofTraining} = [distressFirmsSetofTraining(distressFirmsIndexofTraining.training(KFoldSizeofTraining),1:end) ; nonDistressFirmsSetofTraining(nonDistressFirmsIndexofTraining.training(KFoldSizeofTraining),1:end)];
            sampleSet.trainingValidationSets{KFoldSize}.validationSets{KFoldSizeofTraining} = [distressFirmsSetofTraining(distressFirmsIndexofTraining.test(KFoldSizeofTraining),1:end) ; nonDistressFirmsSetofTraining(nonDistressFirmsIndexofTraining.test(KFoldSizeofTraining),1:end)];
        end
    end
    
    % save file 
    fileName = [DATASETNAME, '_', num2str(KFOLDSIZE), 'fold.mat'];
    save (fileName);
 
end
