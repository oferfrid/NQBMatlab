function TLAllPlates(DirVec, DescriptionVec)
% TLAllPlates(DirVec, DescriptionVec)
% -------------------------------------------------------------------------
% Purpose: runs TimeLapse for all the directories in 'DirVec'.
% Arguments: DirVec(optional) - cell array of the dirctories
%       DescriptionVec(optional) - cell array of the descriptions
% -------------------------------------------------------------------------

if nargin==1
    DirNum = size(DirVec,1);
    DescriptionVec =repmat({''},DirNum,1);
end

if nargin==0
    DirNum = 0;
    morePlates = 'Y';
    while strcmp(upper(morePlates), 'Y')
        DirName = uigetdir;
        if (~isequal(DirName,0))
            DirNum = DirNum + 1;
            DirVec{DirNum} = DirName;
            desc = input('Description: ','s');
            DescriptionVec{DirNum} = desc;
        end
        morePlates = input('Do you want more plates? Y/N [Y]: ', 's');
        if isempty(morePlates)
            morePlates = 'Y';
        end
    end
end
DirNum = length(DirVec);
for i=1:length(DirVec)
    if (length(DirVec{i})>0)
        DirNum = i;
    end
end

for k=1:DirNum
    disp('');
    disp('_____________________________________________________');
    disp([char(DirVec(k)) ' ' char(DescriptionVec(k))]);
    TimeLapse(char(DirVec(k)), char(DescriptionVec(k)));
end