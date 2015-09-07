function Plates2Colonies(Plates,Descriptions,Tresholds)
% function Plates2Colonies(Plates,Descriptions,Tresholds)
% Processing sent plates, for 'processing' meaning please
% read Images2Colonies description.
% arguments:
%       Plates - array of plates numbers.       
%       Descriptions - description for each plate
%       tresholds - colonies TH for each plate
% Nir Dick 2015
    PlatesNum = length(Plates);

    if nargin < 2
        Descriptions =repmat({''},PlatesNum,1);
    end

    if nargin < 3
        Tresholds=repmat({GetDefaultTH},PlatesNum,1);
    end

   disp('start processing all plates:');
   disp('----------------------------');
   for k=1:PlatesNum
       disp([Plates{k} ' ' Descriptions{k}]);
       SetDescription(fullfile(Plates{k},GetDefaultDataName),Descriptions{k});
       images2Colonies(Plates{k},0,Tresholds{k});
   end
   disp('----------------------------');
   disp('end of process.');
end

