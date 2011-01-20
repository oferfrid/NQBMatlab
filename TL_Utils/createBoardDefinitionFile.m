function createBoardDefinitionFile(Img, Board)
%% createBoardDefinitionFile(Img, Board)
%--------------------------------------------------------------------------
% Purpose: Creating a "Board Definition File"
% Description: finds the plates iteratively and fixes the search range
% Arguments: Img - A grayscale image, taken by the scanner at a resolution
%       of 300 dpi.
%       Board 
%--------------------------------------------------------------------------
% Irit Levin Reisman. 04.09 

MaxD = 5;
Range = 10;
MaxTrials = 15;
Trial = 0;

cont = true;
FileName = sprintf('BoardDefinitionFile_%02d', Board);

while (cont == true && Trial < MaxTrials)
    %reading old parameter file
    BoardDefFile = load(FileName);
    oldLxlim = BoardDefFile.Lxlim;
    oldUxlim = BoardDefFile.Uxlim;
    oldLylim = BoardDefFile.Lylim;
    oldUylim = BoardDefFile.Uylim;

    % finding circle parameters
    [circlesVec]=findPlates(Img, Board);
    Lxlim = circlesVec(:,1)-Range;
    Uxlim = circlesVec(:,1)+Range;
    Lylim = circlesVec(:,2)-Range;
    Uylim = circlesVec(:,2)+Range;
    Lrlim = circlesVec(:,3)-Range;
    Urlim = circlesVec(:,3)+Range;
    
    % finding delta from original definition file
    dLxlim = abs(oldLxlim-Lxlim);
    dLylim = abs(oldLylim-Lylim);
    
    % saving new parameter file
    save(FileName,'Lxlim','Uxlim','Lylim','Uylim','Lrlim','Urlim');
    
    if ~(any(dLxlim>MaxD) || any(dLylim>MaxD))
        cont = false;
    end
    
    Trial = Trial+1;
end

