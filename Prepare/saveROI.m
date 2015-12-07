function [destNames]=saveROI(Image,DestDirNames,ImageName,...
                             Plates2Cut,index,limits,rects)
% Save the roi for of each plate as long as limits are not being
% exceeded. Note that each plate has its own limits.
% arguments:
%     Image - the scanner's image to cut
%     DestDirNames - the location for saving the roi
%     ImageName - the name of the scanners image
%     Plates2Cut - relevant plates
%     index - undex of current scanner image
%     limits - the last index already being calculated for each plate.
%             if index is below plate's limit no roi is being saved.
%     rects - position data of roi
% return value:
%     destsNames - names array of saved roi
% Nir Dick 2015

    numOfDests=length(DestDirNames);
    
    destNames=cell(1,numOfDests);
    
    [pathstr,name,ext]=fileparts(ImageName);
    nameFormat=[name '_%d.tif'];
    for k=1:numOfDests
        % Get roi
        roi=imcrop(Image,rects{Plates2Cut(k)});
        
        % Calculate roi's file name
        currName=sprintf(nameFormat,Plates2Cut(k));
        destNames{k}=currName;
        
        % Save roi in current destination if needed
        if index>limits(k)
           currFile=fullfile(DestDirNames{k},currName);
           imwrite(roi,currFile);
        end
    end
end
