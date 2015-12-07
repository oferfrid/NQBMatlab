function CreateBoardHintByName(...
                      inputImagePath,NumberOfPlates,FileName,PlateDiamiter)
    %CreateBoardHintByName( inputImagePath,NumberOfPlates,FileName,[PlateDiamiter])
    % returns  a list of all relative centers and radiuses of the Board.
    % inputImage: the name source image from the scanner
    % NumberOfPlates: the number of plates in the Board
    % PlateDiamiter: in mm
    % this function postulate an A4 scanner sise.
    % created by Nir Dick 7/12/2015
    im=imread(inputImagePath);
    im=im(:,:,1:3);
    CreateBoardHint(im,NumberOfPlates,FileName,PlateDiamiter);
end

