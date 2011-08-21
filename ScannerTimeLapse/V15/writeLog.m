function writeLog(logFile, msg)
fid = fopen(logFile,'a');
fprintf(fid, '%s   %s\n', datestr(now), msg);
fclose(fid);