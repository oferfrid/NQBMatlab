function copyScannerFiles(TotalScanners, ScannerNo)
sourceDir = uigetdir;
if isequal(sourceDir,0)
    return;
end
destDir = uigetdir;
if isequal(destDir,0)
    return;
end
dirOutput = dir(fullfile(sourceDir, '*.tif'));
FileVec   = {dirOutput.name}';
for i=ScannerNo:TotalScanners:length(FileVec)
    disp(num2str(i));
    copyfile(fullfile(sourceDir,char(FileVec(i))) , destDir);
    %movefile(fullfile(sourceDir,char(FileVec(i))) , destDir);
end