function Plates2Colonies(Plates,Descriptions,Tresholds)
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

