function Lrgb = GetPlateLrgb(DirName)
% Lrgb = GetPlateLrgb(DirName)
% Creating a n*3 colormap for the a plate's colonies
% arguments:
%       DirName - the plates directory       
% returns
%       Lrgb - colormap

    % Load Data file
    dataFileStr=GetDataName(DirName);
    data=load(dataFileStr);
    filesName=data.FilesName;
   
    firstName=filesName{1};
    bg=imread(fullfile(DirName,firstName));
    
    lastName=filesName{length(filesName)};
    image=imread(fullfile(DirName,lastName));
    
    relevantArea=GetMask(data,size(image,1),size(image,2));
    
    Lrgb=image2Lrgb(image,bg,data.Limits,data.TH,relevantArea);
end

