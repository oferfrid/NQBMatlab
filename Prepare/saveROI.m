function [destNames]=saveROI(Image,DestDirNames,ImageName,...
                             Plates2Cut,index,limits,rects)

    numOfDests=length(DestDirNames);
    
    destNames=cell(1,numOfDests);
    
    [pathstr,name,ext]=fileparts(ImageName);
    nameFormat=[name '_%d.tif'];
    for k=1:numOfDests
        % Get roi
        roi=imcrop(Image,rects{k});
        
        % Calculate roi's file name
        currName=sprintf(nameFormat,Plates2Cut(k));
        destNames{1,k}=currName;
        
        % Save roi in current destination if needed
        if index>limits(k)
           currFile=fullfile(DestDirNames{1,k},currName);
           imwrite(roi,currFile);
        end
    end
end

