classdef EnsembleBaggedTreeModel < handle & ModelToolkit 
    %UNTITLED12 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        KFOLD;
        DISCRIPTION;
        model;
        testingResult;
        confusionMatrix;
        prob; 
        thresholdList;
        featureSet;
        featureWeightSet;
    end
    
    methods
        function obj = EnsembleBaggedTreeModel(KFold,thresholdList, discription)
           obj.KFOLD = KFold;
            obj.prob = cell(1, KFold);
            obj.testingResult = cell(1, KFold);
            obj.thresholdList = thresholdList;
            obj.DISCRIPTION = discription;
            obj.featureSet = cell(1, obj.KFOLD);
            obj.featureWeightSet = cell(1, obj.KFOLD);
            obj.confusionMatrix = [];
            obj.model = cell(1, obj.KFOLD);
        end
        function model = trainModelandRecord(obj, trainData, Featureset, curFold)
            template = templateTree(...
                'MaxNumSplits', 100);
%                 'MaxNumSplits', 665);
            model = fitcensemble(...
                trainData(:, Featureset), ...
                trainData(:,1), ...
                'Method', 'Bag', ...
                'NumLearningCycles', 100, ...
                'Learners', template, ...
                'ClassNames', [0; 1]);
            obj.model{curFold} = model;
            obj.featureSet{curFold} = Featureset;
            obj.featureWeightSet{curFold} = predictorImportance(model)';
        end
        function testRecordedModel(obj, testData, curFold)
            
            featureSet = obj.featureSet{curFold};
            Model = obj.model{curFold};
            [result,probResult] = predict(Model, testData(:, featureSet))
            obj.testingResult{curFold} = result;
            obj.prob{curFold} = probResult;
            obj.confusionMatrix(:, curFold) = obj.getConfusionMatrix(testData(:, 1), result);
        end
        function model = trainModel(obj, trainData, featureSet)
            template = templateTree(...
                'MaxNumSplits', 345);
            model = fitcensemble(...
                trainData(:, featureSet), ...
                trainData(:,1), ...
                'Method', 'Bag', ...
                'NumLearningCycles', 100, ...
                'Learners', template, ...
                'ClassNames', [0; 1]);
        end
        function [confusionMatrix, result, probResult ]= testModel(obj, testData, featureSet, Model)
           [result,probResult] = predict(Model, testData(:, featureSet))
            confusionMatrix=obj.getConfusionMatrix(testData(:, 1), result);
        end
        function output = getConfusionMatrix(obj, testingAns, testingResult)
            correctCount = 0; %判斷正常的總數
            typeIICount = 0;     %答案是危機被誤判成正常總數
            typeICount = 0;     %答案是正常被誤判成危機總數
            numOfTestingData = numel(testingAns); %有幾筆testingData
            numOfNormalAns = 0; %正常答案有幾個
            numOfDistressAns = 0; %危機答案有幾個
            %訓練執行計算FAR&FRR筆數
            for v = 1:numOfTestingData
                
                if ( testingAns(v) == 0 ) %正常答案
                    numOfNormalAns = numOfNormalAns + 1;
                else % 危機答案
                    numOfDistressAns = numOfDistressAns + 1;
                end
                
                if ( testingAns(v) == 0 && testingResult(v) == 1 ) %正常判成危機
                    typeIICount = typeIICount + 1;
                elseif ( testingAns(v) == 1 && testingResult(v) == 0 ) %危機判成正常
                    typeICount = typeICount + 1;
                else %判斷正常
                    correctCount = correctCount + 1;
                end
            end
            accuracy = correctCount / numOfTestingData;
            typeI = typeICount / numOfDistressAns;
            typeII = typeIICount / numOfNormalAns;
            output = [accuracy; typeI; typeII];
        end
        function [result, probResult]=testRecordedModelwithThreshold(obj, testData, curFold)
            featureSet = obj.featureSet{curFold};
      
            Model = obj.model{curFold};
            curTime = (curFold-1)*length(obj.thresholdList)+1;
            [result,probResult] = predict(Model, testData(:, featureSet))
            for piter = 1:length(obj.thresholdList)
                threshold = obj.thresholdList(piter);
                resultT = [];
                for titer = 1:size(probResult)
                    
                     if probResult(titer, 2) >= threshold
                        resultT(titer, 1) = 1;
                    else
                        resultT(titer, 1) = 0;
                    end
                end
                obj.testingResult{curFold}=[obj.testingResult{curFold} resultT];
                obj.prob{curFold} = probResult;
                obj.confusionMatrix(:, curTime) = obj.getConfusionMatrix(testData(:, 1), resultT);
                curTime = curTime + 1;
            end
            
        end
        function [confusionMatrix, resultList, probResult ]= testModelwithThreshold(obj, testData, featureSet, Model)
            [result,probResult] = predict(Model, testData(:, featureSet))
            for piter = 1:length(obj.thresholdList)
                threshold = obj.thresholdList(piter);
                resultT = [];
                for titer = 1:size(probResult)
                    
                    if probResult(titer, 2) >= threshold
                        resultT(titer, 1) = 1;
                    else
                        resultT(titer, 1) = 0;
                    end
                    
                end
                resultList{piter} = resultT;
                confusionMatrix(:, piter) = obj.getConfusionMatrix(testData(:, 1), resultT);    
            end
%             confusionMatrix=obj.getConfusionMatrix(testData(:, 1), resultT);
        end
        function [output] = getConfusionMatrixList(obj)
            output = obj.confusionMatrix;
        end
        function output = getFeatureSet(obj, curFold)
            output = obj.featureSet{curFold};
        end
    end
end