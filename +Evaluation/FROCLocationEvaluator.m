classdef FROCLocationEvaluator<Evaluation.LocationEvaluator
    %CANDIDATELOCATIONEVALUATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function obj=FROCLocationEvaluator(analyseAllImages)
            obj=obj@Evaluation.LocationEvaluator(analyseAllImages);
        end
    end
    
    methods(Access='protected')
        function result=scoreClass(~,inRange,candidateProb)
%             if ~all(any(inRange,2))
%                 disp('bing')
%                 disp(inRange)
% %                 keyboard
%             end
            
            inRange=inRange&(cumsum(inRange,2)==1|inRange==0);
            result.tp=sum(inRange,1);
            result.pointProb=candidateProb;

            result.pos=size(inRange,1);
            
%             if ~all(any(inRange,2))
%                 disp('bing2')
%                 disp(inRange)
% %                 keyboard
%             end
        end
        
        function result=combineResults(obj,collectedResults,classesSmall)
            for c=size(collectedResults,2):-1:1
                good=cellfun(@(x)~isempty(x),collectedResults(:,c));
                positive(1,c)=sum(cellfun(@(x)x.pos,collectedResults(good,c)),1);
                negative(1,c)=sum(good);
                
                tmpTP=cellfun(@(x)x.tp',collectedResults(good,c),'uniformoutput',false);
                truePos{1,c}=vertcat(tmpTP{:});
                tmpThresh=cellfun(@(x)x.pointProb',collectedResults(good,c),'uniformoutput',false);
                threshold{1,c}=vertcat(tmpThresh{:});
            end
            
            tmpBaseline=Evaluation.EvaluationData(classesSmall,...
                [0;sum(positive,2)],[0;sum(negative,2)],sum(positive,2),sum(negative,2));
            
            for c=length(classesSmall):-1:1
                [pcTP(:,c),pcFP(:,c)]=obj.reduceEvidence(truePos{c},threshold{c});
            end
            result.perClass=Evaluation.EvaluationData(classesSmall,...
                pcTP,pcFP,positive,negative,tmpBaseline);
            
            [cumTP,cumFP]=obj.reduceEvidence(vertcat(truePos{:}),vertcat(threshold{:}));
            
            result.cummulative=Evaluation.EvaluationData(classesSmall,...
                cumTP,cumFP,sum(positive,2),sum(negative,2),tmpBaseline);
%             
%             keyboard
        end
        
        function [tpSmall,fpSmall]=reduceEvidence(obj,tp,prob)
            if ~isempty(tp)
                [~,permIndex]=sort(prob,'descend');

                tpSort=tp(permIndex);
                tpSum=cumsum(tpSort);
                fpSum=cumsum(~tpSort);

                selector=[true;(tpSort(2:end-1)>0 & tpSort(3:end)==0);true];

                tp=tpSum(selector);
                fp=fpSum(selector);

                tpSmall=tp(round(linspace(1,length(tp),obj.nThresh)));
                fpSmall=fp(round(linspace(1,length(fp),obj.nThresh)));
            else
                tpSmall=zeros(obj.nThresh,1);
                fpSmall=zeros(obj.nThresh,1);
            end
        end
%         function [tp,prob,pos,neg]=scoreClass(obj,data,locationLearner,targetClass)
%             disp(['running for class ' targetClass])
%             
%             dataIndices=1:length(data);
%             for i=length(data):-1:1
%                 goodObjects{i}=data.getObject(i);
%                 goodObjects{i}=goodObjects{i}(ismember({goodObjects{i}.name},targetClass));
%                 goodData(i)=~isempty(goodObjects{i});
%             end
%             
%             if ~obj.allImages
%                 dataIndices=dataIndices(goodData);
%             end            
%             
%             tp=false(1,0);
%             pointProb=[];
%             pos=0;
%             neg=0;
%             
%             for i=dataIndices
%                 probVec=obj.probabilityVector(data,i,locationLearner,targetClass);
%                 locVec=data.get3DPositionForImage(i);
%                 [probVec,permIndex]=sort(probVec,'descend');
%                 locVec=locVec(:,permIndex);
%                 
%                 candidatePoints=[];
%                 candidateProb=[];
%                 while ~isempty(locVec)
%                     candidatePoints(:,end+1)=locVec(:,1);
%                     candidateProb(1,end+1)=probVec(:,1);
%                     pointsOutside=sum((candidatePoints(:,end*ones(1,size(locVec,2)))-locVec).^2,1)>obj.maxDistance^2;
%                     locVec=locVec(:,pointsOutside);
%                     probVec=probVec(:,pointsOutside);
%                 end
%                 
%                 truePoints=[goodObjects{i}.pos];
%                 
%                 inRange=false(size(truePoints,2),size(candidatePoints,2));
%                 if ~isempty(truePoints)
%                     candidatePoints=permute(candidatePoints,[3 2 1]);
%                     truePoints=permute(truePoints,[2 3 1]);
%                     inRange=sum((truePoints(:,ones(1,size(candidatePoints,2)),:)-...
%                         candidatePoints(ones(1,size(truePoints,1)),:,:)).^2,3)<obj.maxDistance^2;
%                     inRange=inRange&(cumsum(inRange,2)==1|inRange==0);
%                 end
%                 
%                 tp=[tp any(inRange,1)];
%                 pointProb=[pointProb candidateProb];
% 
%                 pos=pos+length(goodObjects{i});
%                 neg=neg+1;
%             end
%             
%             [prob,permIndex]=sort(pointProb,'descend');
%             
%             tp=tp(permIndex)';
%             prob=prob';
%             tpSum=cumsum(tpSort);
%             fpSum=cumsum(~tpSort);
%             
%             selector=[true (tpSort(2:end-1) & ~tpSort(3:end)) true];
%             
%             tp=tpSum(selector);
%             fp=fpSum(selector);
%             prob=prob(selector);
% 
%             tp=tp(round(linspace(1,length(tp),obj.nThresh)));
%             fp=fp(round(linspace(1,length(fp),obj.nThresh)));
%             prob=prob(round(linspace(1,length(fp),obj.nThresh)));
%             
%             disp(['finished for ' targetClass])
%         end
    end
    
end
