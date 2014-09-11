function Lrgb = GetPlateLrgb(DirName)
    % Load Data file
    dataFileStr=fullfile(DirName,GetDefaultDataName);
    data=load(dataFileStr);
    filesName=data.FilesName;
   
    firstName=filesName{1};
    bg=imread(fullfile(DirName,firstName));
    
    lastName=filesName{length(filesName)};
    image=imread(fullfile(DirName,lastName));
    
    relevantArea=GetMask(data,size(image,1),size(image,2));
    
    Lrgb=image2Lrgb(image,bg,data.Limits,data.TH,relevantArea);
end

