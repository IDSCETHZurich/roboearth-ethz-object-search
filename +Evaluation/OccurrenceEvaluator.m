classdef OccurrenceEvaluator<Evaluation.Evaluator
    %OCCURRENCEEVALUATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess='protected')
        evidenceGenerator
    end
    
    properties(Constant)
        thresholds=linspace(0,1,Evaluation.Evaluator.nThresh)';
    end
    
    methods
        function result=evaluate(obj,testData,occurrenceLearner)
            result.conditioned=obj.calculateStatistics(testData,occurrenceLearner,'full');
            result.baseline=obj.calculateStatistics(testData,occurrenceLearner,'baseline');
            
            myNames=occurrenceLearner.getLearnedClasses();
            result.conditioned.names=myNames;
            result.baseline.names=myNames;
        end
    end
    
    methods(Access='protected',Abstract)
        decisions=decisionImpl(obj,myDependencies)
    end
    
    methods(Access='protected')
        function result=calculateStatistics(obj,testData,occLearner,mode)
            
            if strcmpi(mode,'baseline')
                calcBaseline=true;
            else
                calcBaseline=false;
            end
            
            myNames=occLearner.getLearnedClasses();
            
            for i=length(myNames):-1:1
                if calcBaseline
                    searchIndices=testData.className2Index(myNames{i});
                else
                    searchIndices=testData.className2Index([myNames(i) occLearner.model.(myNames{i}).parents]);
                end
                
                evidence=occLearner.evidenceGenerator.getEvidence(testData,searchIndices,1:length(testData),'single');
                tmpSize=size(evidence);
                boolEvidence=zeros([2 tmpSize(2:end)]);
                boolEvidence(1,:)=evidence(1,:);
                boolEvidence(2,:)=sum(evidence(2:end,:),1);
                
                if calcBaseline
                    decisions=obj.decisionBaseline(occLearner.model.(myNames{i}).margP);
                else
                    decisions=obj.decisionImpl(occLearner.model.(myNames{i}));
                end
                
                neg=repmat(boolEvidence(1,:),[size(decisions,1) 1]);
                pos=repmat(boolEvidence(2,:),[size(decisions,1) 1]);
                
                result.tp(:,i)=sum(pos.*(decisions(:,:)==2),2);
                result.fp(:,i)=sum(neg.*(decisions(:,:)==2),2);
                result.pos(1,i)=sum(boolEvidence(2,:),2);
                result.neg(1,i)=sum(boolEvidence(1,:),2);
                
                result.expectedUtility(1,i)=occLearner.model.(myNames{i}).expectedUtility;
            end
        end
        
        function decisions=decisionBaseline(obj,margP)
            decisions=ones(length(obj.thresholds),1);
            tmpCP=margP(2*ones(length(obj.thresholds),1),:);
            decisions(tmpCP>=obj.thresholds)=2;
        end
    end
end

