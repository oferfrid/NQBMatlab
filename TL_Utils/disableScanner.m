function ErrorMsg = disableScanner(InstanceID)
% ErrorMsg = disableScanner
% -------------------------------------------------------------------------
% NOTICE:
% to use this script you must first download 'devcon' and add to the
% computer path where the exe is, through 'enviromental variables' in the
% computer managment.
%
% Purpose: 
%   This function disables a scanner according to the Inctance ID
% Arguments : 
%   InstanceID - a string starts with @
% Returns :
%   ErrorMsg - an Error massege in case of faliure.
% -------------------------------------------------------------------------
% Irit Levin. 25.10.2007

ErrorMsg = '';
cmd = ['C:\I386\devcon disable "', InstanceID, '"'];
[stat, res]=system(cmd);
if strfind(res, 'No devices disabled.')
    ErrorMsg = res;
end
