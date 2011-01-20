function InstanceIdVec = FindAllScanners
% InstanceIdVec = FindAllScanners
% -------------------------------------------------------------------------
% NOTICE :
% to use this script you must first download 'devcon' and add to the
% computer path where the exe is, through 'enviromental variables' in the
% computer managment.
%
% Purpose: This function gets all the scanners ids
%
% description:
%   devcon returns all the IDs of a device in this format:
%   "USB\VID_04B8&PID_0122\5&32488A7&0&3
%         Name: EPSON Perfection 3490/3590
%         Hardware ID's:
%             USB\Vid_04b8&Pid_0122&Rev_0110
%             USB\Vid_04b8&Pid_0122
%         Compatible ID's:
%             USB\Class_ff&SubClass_ff&Prot_ff
%             USB\Class_ff&SubClass_ff
%             USB\Class_ff                     "
%   the instance ID, which is the unique ID per scanner, is the one that's
%   right before the 'Name:'
%
% Returns:
%   InstanceIdVec - A cell array of the Instance ID names.
%   ErrorMsg - an error massage.
% -------------------------------------------------------------------------
% Irit Levin. 25.10.2007

NEXT_LINE  = 10;         % the ASCII code for new line

%ErrorMsg   = '';
InstanceId = '';

% getting all the Instance IDs of the scanners 
[stat, ImagingDevices] = system('devcon hwids =Image');
if (stat == 0)
    % k is the number of devices connected
    k = strfind(ImagingDevices, 'Name:');
    % turning the scanners string into ASCII code
    doubleImagingDevices = double(ImagingDevices);
    if length(k)
        startPos = 1;
        fid = fopen('ScannerList.txt','w');
        % getting the instance id for each scanner
        for i=1:length(k)
            endPos = k(i);
            truncImagingDevices = ...
                doubleImagingDevices(1,startPos:endPos);
            truncImagingDevices = [10, truncImagingDevices];
            IDstart             = find(truncImagingDevices == NEXT_LINE);
            InstanceId          = ...
                char(truncImagingDevices(1,IDstart(end-1):IDstart(end)));
            InstanceIdVec(i)    = {['@',strtrim(InstanceId)]};          
            startPos = endPos;
        end
        % writing into 'ScannerList.txt'
        fid = fopen('ScannerList.txt','w');
        for j=1:length(k)-1
           fprintf(fid, '%s\n', char(InstanceIdVec(j)));
        end
        fprintf(fid, '%s', char(InstanceIdVec(length(k))));
        fclose(fid);
    else
    % if there's no scanner found, returns en error massage
        InstanceIdVec = {};
        %ErrorMsg = 'ERROR - No scanners were detected';
    end
end