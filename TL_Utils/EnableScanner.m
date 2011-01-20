function ErrorMsg = EnableScanner(InstanceID)
% ErrorMsg = EnableScanner(InstanceID)
% -------------------------------------------------------------------------
% NOTICE:
% to use this script you must first download 'devcon' and add to the
% computer path where the exe is, through 'enviromental variables' in the
% computer managment.
%
% Purpose: 
%   This function enables a scanner according to the Inctance ID
% Arguments : 
%   InstanceID - a string starts with @
% Returns :
%   ErrorMsg - an Error massege in case of faliure. 
% -------------------------------------------------------------------------
% Irit Levin. 25.10.2007

ErrorMsg = '';
cmd = ['devcon enable "', InstanceID, '"'];
[stat, res]=system(cmd);
if strfind(res, 'No devices enabled')
    ErrorMsg = res;
end
