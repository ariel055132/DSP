classdef ModelAnalysis < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        kFold;
        costList;
        thresholdList;
        typeIerrorList;
        typeIIerrorList;
        numofRisk;
        numofNormal;
    end
    
    methods
        
        % Purpose: initializing the ModelAnalysis object
        % Input: costList (10 cost)
        %        threhsoldList (100 thresholds)
        %        sampleSet
        % Output: obj (ModelAnalysis object)
        function obj = ModelAnalysis(costList,thresholdList, sampleSet)
            obj.costList = costList;
            obj.thresholdList = thresholdList;
            [obj.numofRisk, obj.numofNormal]=obj.computetheNumofRiskandNormal(sampleSet);
            obj.kFold =  size(sampleSet.trainingSets, 2);
            for i = 1:length(thresholdList)*3
                if mod(i,3)== 1 % acc
                elseif mod(i,3) == 2 % typeI indexes
                    obj.typeIerrorList = [obj.typeIerrorList i];
                elseif mod(i,3) == 0 % typeII indexes
                    obj.typeIIerrorList = [obj.typeIIerrorList i];
                end
            end
        end
        
        % Purpose: calculate the number of bankrupt Firms and normal Firms in the experiment dataset
        % Input: sampleSet 
        % Output: numberofRisk (number of bankrupt firms)
        %         numberofNormal (number of normal firms)
        function [numOfRisk, numOfNormal] = computetheNumofRiskandNormal(obj, sampleSet)
            Normal = 0;
            Risk = 0;
            Risk = sum(sampleSet.trainingSets{1}(:,1));
            Risk = Risk + sum(sampleSet.testingSets{1}(:,1));
            totalNum = size(sampleSet.trainingSets{1},1) + size(sampleSet.testingSets{1},1);
            Normal = totalNum - Risk;
            
            
            numOfRisk = Risk;
            numOfNormal = Normal;
        end
        
        % Purpose: Reshape the confusion matrix from 3(acc, typeI, typeII)X(100(thresholds)X10(10folds)X5(sampleSets)) to (3(acc, typeI, typeII)X100(thresholds))X(10(10folds)X5(sampleSets)), so the further calculation will be more convenient
        % Input: confusionMatrixAll (confusion matrix of all sampleSet)
        %       numberofTotalFold (number of total fold - 50)
        % Output: reshapedData (reshaped confusionMatrix)
        function [reshapedData] = reshapeData(obj,confusionMatrixAll,numberofTotalFold)
            reshapedData = [];
            thresholdListSize = size(obj.thresholdList, 2);
            for i = 1:thresholdListSize
                temp = [];
                for j = 1:numberofTotalFold
                    cutTime = i+(j-1)*thresholdListSize;
                    list(i,j) = cutTime;
                    temp(:,j) = confusionMatrixAll(:,cutTime);
                end
                reshapedData = [reshapedData ;temp];
            end
        end
        
        % Purpose: merge the confusionMatrix of all 5 sampleSets
        % Input: allModel (all models build by the 5 sampleSets)
        % Output: confusionMatrixAll (confusion matrix of all sampleSets)
        function [confusionMatrixAll] = mergeResult(obj,allModel)
            confusionMatrixAll = [];
            if ~iscell(allModel)
                confusionMatrixAll = allModel.getConfusionMatrixList();
            else
                for i = 1:size(allModel, 2)
                    confusionMatrixAll = [confusionMatrixAll allModel{i}.getConfusionMatrixList()];
                end
            end
            [confusionMatrixAll] = obj.reshapeData(confusionMatrixAll, size(allModel, 2)*obj.kFold);
            
        end
                    
        % Purpose: calculate the misscalssificationCost for each threshold in each fold
        % Input: mergedConfusionMatrix (confusionMatrixs of 5 sampleSets)
        % Output: cost (missclassificationCosts of 50 folds of the threshold with the minimum missclassificationCost sum
        %         typeI (typeI of 50 folds of the threshold with the minimum missclassificationCost sum)
        %         typeII (typeII of 50 folds of the threshold with the minimum missclassificationCost sum)
        %         averageofTestResultsandMissclassificationCosts (average (acc, typeI, typeII, missclassificationCost) of 50 folds of the threshold with the minimum missclassificationCost sum)
        %         chosenIndex (chosenIndex of the threshold with the minimum missclassificationCost sum)
        function [cost,typeI,typeII, averageofTestResultsandMissclassificationCosts, chosenIndex ] = calculateCost(obj, mergedConfusionMatrix, selectedThreshold)
            %             CostList,RiskNum,NormalNum,typeIerrorList,typeIIerrorList
            averageofTestResultsandMissclassificationCosts = zeros(3, size(obj.costList, 2));
            chosenIndex=[];
            for k = 1:size(obj.costList,2)
                for i =1:size(mergedConfusionMatrix, 1)/3 %thresold
                    currentThresholdInfoRowIndex = (i-1)*3+1; % starting row index of current threshold's confusion list (acc, typeI, typeII)  
                    for j = 1:size(mergedConfusionMatrix, 2)%fold
                         %Eq: Miscost = Type1 * cost ratio * number of bankrupt firms + Type2 * number of normal firms
                         misclassificationCost(i,j) = mergedConfusionMatrix(1+currentThresholdInfoRowIndex,j)*obj.numofRisk*obj.costList(k) + mergedConfusionMatrix(2+currentThresholdInfoRowIndex,j)*obj.numofNormal;
                    end
                end
%                 totalCost = sum(misclassificationCost, 2);
                averageCost = mean(misclassificationCost, 2);
                index= selectedThreshold(k)
                
                chosenIndex= [chosenIndex; index];
                cost(k,:) = misclassificationCost(index, :);
                typeI(k, :) =  mergedConfusionMatrix(1+(index-1)*3+1, :);
                typeII(k, :) = mergedConfusionMatrix(2+(index-1)*3+1, :);
                averageofTestResultsandMissclassificationCosts(1, k) = mean(mergedConfusionMatrix((index-1)*3+1,:))*100;
                averageofTestResultsandMissclassificationCosts(2, k) = mean(mergedConfusionMatrix((index-1)*3+2,:))*100;
                averageofTestResultsandMissclassificationCosts(3, k) = mean(mergedConfusionMatrix((index-1)*3+3,:))*100;
                averageofTestResultsandMissclassificationCosts(4,k) = mean(averageCost(index));
            end
        end
        
        % Purpose: calculate missclassificationCost and do wilcoxon test
        function [result] = compareModels(obj,allCost)
            % allCost = �n�Ψӭp��CostTable�����
            % costList = Cost��List�A�ݨϥΪ̭n�p�⪺Cost������
            pValues = [];
            %% �p��C�@�C��������
            % j = classifier�ƶq
            % i = cost�ƶq
            for j = 1:size(allCost,1)
                for i = 1:size(allCost,2)
                    meanofMissclassificationCosts(j,i) = mean(allCost(j,i,:));
                end
            end
            
            %% ��X�����ȳ̧C�b����model�A�M�᮳�L�ӷ�base���Lmodel��C��cost����ư�signrankTest
            for i = 1:size(obj.costList,2)
                [~,indexofBestModel] = min(meanofMissclassificationCosts(:,i));
                for j = 1:size(allCost,1)
                    %  for current cost, get the missclassificationcosts of the threshold
                    % which has the min missclassificationcost sum for the
                    % models (best model and the model to compare) 
                    missclassificationCostsofBestModel = reshape(allCost(indexofBestModel,i,1:end),1,size(allCost,3)); 
                    missclassificationCostsofcurrentModel = reshape(allCost(j,i,1:end),1,size(allCost,3));
                     pValue(j) = signrank(missclassificationCostsofBestModel,missclassificationCostsofcurrentModel);
%                     [~, temp(j)] = ttest2(temp1,temp2)   
                end
                pValues = [pValues; pValue];
            end
            %% �N�̫ᵲ�G�^��
            result = pValues;
        end
        
        % Purpose: draw DET Curve to compare the typeI, typeII by  thresholds
        % Input: axisRange (typeI, typeII axis range)
        %        varargin (from matlab, models to compare)
        % drawDetCurve([0 1 0 1], ATLMANSVM, ATLMANLDA)
%         function drawDetCurve(obj, axisRange ,varargin)
        function [selectedThres] = drawDetCurve(obj, axisRange ,varargin)
            typeIerrorList = []
            typeIIerrorList = []
            accuracyList = []
            
            %design to plot at most 4 line
            %can rewrite to plot more
                        for i = 1:length(obj.thresholdList)*3
                            if mod(i,3)== 1 % acc
                                accuracyList = [accuracyList, i];
                            elseif mod(i,3) == 2 % typeI
                                typeIerrorList = [typeIerrorList i];
                            elseif mod(i,3) == 0 % typeII
                                typeIIerrorList = [typeIIerrorList i];
                            end
                        end
                        
                typeIerrorList = [302 typeIerrorList 301]
                typeIIerrorList = [301 typeIIerrorList 302]
            %% draw DET curve
            styleList = {'b*--' 'mo--' 'r^--' 'c<--' 'ks--' 'y+--' 'gh--' 'bv--' 'bs--'};
            str1 = '#0072BD';
            color1 = sscanf(str1(2:end),'%2x%2x%2x',[1 3])/255;
            str2 = '#D95319';
            color2 = sscanf(str2(2:end),'%2x%2x%2x',[1 3])/255;
            str3 =  '#EDB120';
            color3 = sscanf(str3(2:end),'%2x%2x%2x',[1 3])/255;
            colorList = {'k' 'r' 'g' 'b' 'c' 'm' 'y'  color1 color2  color3}
            nameList = {'EERCost1' 'EERCost1.5' 'EERCost2' 'EERCost2.5' 'EERCost3' 'EERCost3.5' 'EERCost4' 'EERCost5' 'EERCost6' 'EERCost7' }
            findX= []
            EERlist=[]
            selectedThres=[]
            for i = 1:length(varargin)
                thres=[]
                curData = obj.mergeResult(varargin{i});
                meansofMergedConfusionMatrix = mean(curData, 2); % mean of each row
                meansofMergedConfusionMatrix = [meansofMergedConfusionMatrix ;1 ;0]
                
                plot(meansofMergedConfusionMatrix(typeIerrorList, 1), meansofMergedConfusionMatrix(typeIIerrorList,1), styleList{i}, 'DisplayName', varargin{i}.DISCRIPTION);
                hold on;
%                  
                %% calculation of EER value
                % False Rejection Rate (FRR) : Type I Error Rate
                % False Acceptance Rate (FAR) : Type II Error Rate
                % Equal Error Rate (EER) by FAR=FRR
                FRR = meansofMergedConfusionMatrix(typeIerrorList, 1);
                FAR = meansofMergedConfusionMatrix(typeIIerrorList,1);
                
                %% cost ratio
                % comment the condition (only line 260, 263, 268 and 271) if you want to show how we apply costList
                for j = 1:size(obj.costList,2)
                    indexsofThresholds=find ((obj.costList(j)*FRR)-FAR<=0,1,'last'); % index of thresholds whose typeI < typeII
                    y1 = [0 1];
                    if (i == 1)
                        % a line decided by the two threshold points (typeI, typeII)
                        % Draw EER line for each cost ratio
                        if(j == 1) 
                            findX(j)= 1;
                        else
                            % calculate y-axis using equation ((y-y1)/(y2-y1)) = ((x-x1)/(x2-x1)) || m = y/x
                            medx1 = median([FRR(indexsofThresholds), FRR(indexsofThresholds+1)])
                            medx2 = median([FAR(indexsofThresholds), FAR(indexsofThresholds+1)])
                            findX(j) = medx1/medx2; % y=mx --> x=y/m
                        end
                        x1 = [0 findX(j)];
                        if (j==1)%
                            line(x1', y1', 'Color',colorList{j}, 'DisplayName', nameList{j})
                            hold on
                        end%
                    end
                    x1 = [0 findX(j)];
                    % find intersection then mark
                    [typeIEER, typeIIEER]=polyxpoly(x1, y1, FRR, FAR)
                    if(j==1)% 
                        plot(typeIEER,typeIIEER,'o', 'MarkerSize',5,'LineWidth',2,'Color','black','MarkerFaceColor','k','DisplayName',num2str(typeIEER))
                        hold on
                    end%
                    %save selected threshold and EER
                    EERlist(i,j) = typeIEER; %EERlist(2,j) = typeIIEER; 
                    dist = find(FRR - EERlist(i,j)  <= 0, 1, 'last')-1
                    thres = [thres; dist]
                end
                %%
                selectedThres(i,:) = thres
                if i==1
                    hold on;
                end
            end
            legend('show');
            xlabel('TypeII');
            ylabel('TypeI');
            set(gca,'YTick',[0:0.05:1]);
            set(gca,'XTick',[0:0.05:1]);
            axis(axisRange);
           % legend('M0', 'M1', 'M2', 'M3')
        end

        % Purpose: get Cost Package of the models of 5 sampleSets
        % Input: all 5 models base on the sampleSet
        % Output: cost (missclassificationCosts of 50 folds of the threshold with the minimum missclassificationCost sum
        %         typeI (typeI of 50 folds of the threshold with the minimum missclassificationCost sum)
        %         typeII (typeII of 50 folds of the threshold with the minimum missclassificationCost sum)
        %         average (average (acc, typeI, typeII, missclassificationCost) of 50 folds of the threshold with the minimum missclassificationCost sum)
        %         chosenIndex (chosenIndex of the threshold with the minimum missclassificationCost sum)
        
        function [cost,typeI,typeII, average, chosenIndex ] = getCostPackage(obj, allModel, selectedThreshold)
             mergedConfusionMatrix=obj.mergeResult(allModel);
             [cost,typeI,typeII, average, chosenIndex ] = obj.calculateCost(mergedConfusionMatrix, selectedThreshold);
        end
        
        % Purpose: calculate missclassificationcosts and do wilcoxon test
        % Input: models to compare
        % Output: p-values 
        % doWilcoxon(ATLMANSVM, ALTMANLDA)
        function [output, descripe] = doWilcoxonTest(obj, selectedThreshold, varargin )
            % nargin: number of input arguments
            allCost=[];
            models={}
            
            for i = 1:size(varargin{1},1)
                models{i} = varargin{1}(i,:)
            end
            
            for i = 1:size(models,2)
                [mergedConfusionMatrix] = obj.mergeResult(models{i});
                allCost(i,:,:) = obj.calculateCost(mergedConfusionMatrix, selectedThreshold(i,:));
                descripe{i} = models{i}.DISCRIPTION;
            end
            output = obj.compareModels(allCost);
        end
    end
% selectedThres = modelAnalysis.drawDetCurve([0 1 0 1], model1, model2)
% modelAnalysis.doWilcoxonTest(selectedThres, [model 1; model 2])

end

