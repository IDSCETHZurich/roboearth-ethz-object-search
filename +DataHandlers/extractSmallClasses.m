function smallClasses = extractSmallClasses(allClasses)
    %SMALLCLASSES = EXTRACTSMALLCLASSES(ALLCLASSES)
    %   Contains a list of which classes are considered small and returns
    %   the cell string array SMALLCLASSES that contains all matching
    %   classes from ALLCLASSES.
    smallList={...
        'bag',...
        'basket',...
        'book',...
        'bottle',...
        'bowl',...
        'box',...
        'clock',...
        'clothes',...
        'cup',...
        'cushion',...
        'electricalOutlet',...
        'faucet',...
        'floorMat',...
        'flowers',...
        'glass',...
        'lamp',...
        'paper',...
        'picture',...
        'plate',...
        'pot',...
        'tissueBox',...
        'towel',...
        'tray',...
        'vase'};
        
    smallClasses=allClasses(ismember(allClasses,smallList));
end

