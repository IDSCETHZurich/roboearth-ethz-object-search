classdef LocationEvidenceGenerator<LearnFunc.EvidenceGenerator
    %LOCATIONEVIDENCEGENERATOR Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function evidence=getEvidence(obj,data,varargin)
            if length(varargin)==1
                if strcmpi(varargin{1},'relative')
                    evidence=obj.orderRelativeEvidenceSamples(data);
                    return
                elseif strcmpi(varargin{1},'absolute')
                    evidence=obj.orderAbsoluteEvidenceSamples(data);
                    return
                end
            end
            error('LocationEvidenceGenerator:getEvidence:wrongInput',...
                'The varargin argument has to be ''relative'' or ''absolute''.')
        end
        
        function evidence=getEvidenceForImage(obj,data,index)
            allNames={data.getObject(index).name};
            baseIndices=ismember(allNames,data.getLargeClassNames());
            evidence.names=allNames(baseIndices);
            
            objectPos=obj.getPositionEvidence(data,index);
            objectPos=objectPos(:,baseIndices);
            
            evidence.absEvi=obj.getPositionForImage(data,index);
            
            evidence.relEvi=obj.getRelativeEvidence(objectPos,evidence.absEvi);
        end
    end
    
    methods(Abstract,Static,Access='protected')
        evidence=getRelativeEvidence(sourcePos,targetPos)
        evidence=getAbsoluteEvidence(pos)
        pos=getPositionEvidence(images,index)
        pos=getPositionForImage(images,index)
    end
    methods(Abstract,Static)
        distance=evidence2Distance(evidence)
    end
    
    methods(Access='protected')
        function samples=orderRelativeEvidenceSamples(obj,images)
            classes=images.getClassNames();
            samples=cell(length(classes),length(classes));
            for i=1:length(images)
                pos=obj.getPositionEvidence(images,i);
                evidence=obj.getRelativeEvidence(pos,pos);
                
                ind=images.className2Index({images.getObject(i).name});
                for o=1:length(ind)
                    for t=o+1:length(ind)
                        samples{ind(o),ind(t)}(end+1,:)=evidence(o,t,:);
                        samples{ind(t),ind(o)}(end+1,:)=evidence(t,o,:);
                    end
                end
            end
        end
        function samples=orderAbsoluteEvidenceSamples(obj,images)
            classes=images.getClassNames();
            samples=cell(length(classes),length(classes));
            for i=1:length(images)
                pos=obj.getPositionEvidence(images,i);
                evidence=obj.getAbsoluteEvidence(pos);
                
                ind=images.className2Index({images.getObject(i).name});
                for o=1:length(ind)
                    for t=o+1:length(ind)
                        samples{ind(o),ind(t)}(end+1,1,:)=evidence(o,o,:);
                        samples{ind(o),ind(t)}(end,2,:)=evidence(o,t,:);
                        samples{ind(t),ind(o)}(end+1,1,:)=evidence(t,t,:);
                        samples{ind(t),ind(o)}(end,2,:)=evidence(t,o,:);
                    end
                end
            end
        end
    end
    
end

