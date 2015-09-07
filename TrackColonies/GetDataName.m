function name = GetDataName(SourceDir)
% name = GetDataName(SourceDir)
% Returns the expected data name for sent directory.
% arguments:
%     SourceDir - directory
% Nir Dick 2015

    [~,dir,~]=fileparts(SourceDir);
    name=[dir '_data.mat'];
    name=fullfile(SourceDir,name);
end

