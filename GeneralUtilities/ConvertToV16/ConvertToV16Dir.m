function ConvertToV16Dir(root,reg,prefix)
    subds=subdir(root)';
    subds=subds(~cellfun('isempty',regexp(subds,reg)));
    xlswrite(fullfile(root,'subdsV16.xls'),subds);
    [num,txt]=xlsread(fullfile(root,'subdsV16.xls'));
    dirsNum=length(txt);
    for i=1:dirsNum
        ConvertToV16(txt{i},prefix);
    end
end
