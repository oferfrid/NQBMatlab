function name = GetDataName(SourceDir)
    [~,dir,~]=fileparts(SourceDir);
    name=[dir '_data.mat'];
    name=fullfile(SourceDir,name);
end

