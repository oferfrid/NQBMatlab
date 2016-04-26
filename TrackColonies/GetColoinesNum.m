function [ColoinesNum] = GetColoinesNum(SourceDir)
% Returns the number of relevant colonies in masked area
% Arguments:
% SourceDir - the directory
% Nir Dick 26.4.2016
    dataName=GetDataName(SourceDir);
    data=load(dataName);
    ColoinesNum=sum(data.IgnoredColonies==0);
end
