function ProcessPlates(SourceDirs,LogFiles,Descriptions)
    logFlag=true;
    descFlag=true;
    
    if nargin<2 || isempty(LogFiles)
        logFlag=false;
    elseif ~iscell(LogFiles)
        LogFiles={LogFiles};
    end
    
    if nargin<3
        descFlag=false;
    elseif ~iscell(Descriptions)
        Descriptions={Descriptions};
    end
    
    for i=1:length(SourceDirs)
        currPlateDir=SourceDirs{i};
        Images2Colonies(currPlateDir);
        if logFlag
            SetStartingTime(currPlateDir,'',LogFiles{i});
        end
        
        if descFlag
            SetDescription(currPlateDir,Descriptions{i})
        end
    end
end

