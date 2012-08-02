classdef ROCEvaluationData<Evaluation.EvaluationData
    
    methods
        function addData(obj,newData,dataName,classSubset)
            if nargin<4
                classSubset=true(1,size(newData.tp,2));
            end
            obj.curves(end+1).tp=newData.tp(:,classSubset);
            obj.curves(end).fp=newData.fp(:,classSubset);
            obj.curves(end).pos=newData.pos(:,classSubset);
            obj.curves(end).neg=newData.neg(:,classSubset);
            obj.curves(end).name=dataName;
        end
    end
    methods(Access='protected')
        function drawImpl(obj)
            for c=length(obj.curves):-1:1
                tpRate(:,c)=sum(obj.curves(c).tp,2)/sum(obj.curves(c).pos);
                fpRate(:,c)=sum(obj.curves(c).fp,2)/sum(obj.curves(c).neg);
            end
            
            plot(obj.myAxes,fpRate,tpRate,'-')

            axis(obj.myAxes,[0 max(1,max(max(fpRate))) 0 1])
            legend(obj.myAxes,{obj.curves.name},'location','southeast')
            xlabel(obj.myAxes,'false positive rate')
            ylabel(obj.myAxes,'true positive rate')
        end
    end
end