function [id,SourceDir,AppearanceTime ] = getAppearanceTime( SourceDirs )
 

DATA_FILE_NAME='data.mat';

    id = [];
    SourceDir=cell(0);
    AppearanceTime=[];
   
    
    if(~iscell(SourceDirs))
        SourceDirs = {SourceDirs};
    end
    
    
    for i=1:length(SourceDirs)
        % Load data file
        data=load(fullfile(SourceDirs{i},DATA_FILE_NAME));
        
        indexes = 1:length(data.IgnoredColonies);
        indexes = indexes((~data.IgnoredColonies)&(data.Area(end,:)>0)');
        id = [id indexes];
        SourceDir=[SourceDir{:}  repmat(SourceDirs(i),[1 length(indexes) ])];
        [~,I]=max(data.Area(:,indexes)>0,[],1);
        PlateAppearanceTime = data.FilesDateTime(I);
        AppearanceTime=[AppearanceTime PlateAppearanceTime];
       
        
    end
    

end

