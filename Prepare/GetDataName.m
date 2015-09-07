function name = GetDataName(SourceDir)
% name = GetDataName(SourceDir)
% Calculate the expected data name of sent directory
% SourceDir - The directory
    [~,dir,~]=fileparts(SourceDir);
    name=[dir '_data.mat'];
    name=fullfile(SourceDir,name);
end

