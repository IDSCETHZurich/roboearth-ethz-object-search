classdef NYUDetLoader<DataHandlers.NYULoader
    %SUNLOADER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Constant)
        trainSet='detectionsTrain.mat'
        testSet='detectionsTest.mat'
    end
    
    methods
        function obj=NYUDetLoader(filePath)
            obj=obj@DataHandlers.NYULoader(filePath);
            if ~exist(fullfile(obj.path,obj.trainSet),'file') ||...
                    ~exist(fullfile(obj.path,obj.testSet),'file')
                warning('Detections are not extracted yet');
            end
        end
        function extractDetections(obj,groundTruthLoader,detector)
            data=obj.runDetector(groundTruthLoader.getData(groundTruthLoader.trainSet),...
                groundTruthLoader.path,detector);
            data.save(fullfile(obj.path,obj.trainSet))
            
            data=obj.runDetector(groundTruthLoader.getData(groundTruthLoader.testSet),...
                groundTruthLoader.path,detector);
            data.save(fullfile(obj.path,obj.testSet))
        end
    end
    methods(Access='protected')
        function data=runDetector(obj,data,path,detector)
            nData=length(data);
            collectedObjects=cell(1,nData);
            parfor i=1:nData
                %if mod(i,round(nData/10))==0
                    disp(['detecting image ' num2str(i) '/' num2str(nData)])
                %end
%                 data(i).annotation.object=[];
%                 for c=1:length(classes)
%                     data(i).annotation.object=[data(i).annotation.object,...
%                         detector.detectClass(classes{c},...
%                         imread(fullfile(imgPath,data(i).annotation.folder,data(i).annotation.filename)))];
%                 end
%                 collectedObjects{i}=[];
                for c=1:length(obj.classes)
                    tmpObjects=detector.detectClass(obj.classes(c).name,...
                        imread(fullfile(path,obj.imageFolder,data.getFolder(i),data.getFilename(i))));
                    tmpLoaded=load(fullfile(path,obj.depthFolder,data.getFolder(i),data.getDepthname(i)));
                    for o=1:length(tmpObjects)
                        size(tmpLoaded.depth)
                        disp(tmpObjects(o).polygon.x)
                        disp(tmpObjects(o).polygon.y)
                        collectedObjects{i}=[collectedObjects{i},...
                            DataHandlers.Object3DStructure(tmpObjects(o).name,...
                            tmpObjects(o).score,tmpObjects(o).polygon.x,tmpObjects(o).polygon.y,...
                            tmpLoaded.depth,data.getCalib(i))];
                    end
                end
            end
            for i=1:nData    
                data.setObject(collectedObjects{i},i);
            end
        end
    end
end