function PlotPlateColoniesNumbers(TimeGap,VecCen,ColoniesStatus,...
                                  Times,forMovie)
    if nargin < 7
       forMovie=false; 
    end
    
    %% resize for movie
    if forMovie
        VecCen = round(VecCen/2);
    end


    %% numbering the colonies
    % All colonies at time TimeGap 
    % (includes noise and colonies close to border)
    FileNum  = find(Times <= TimeGap, 1, 'last');
    ColoniesNum = size(VecCen,1);
    
    hold on;
  
    for k=1:ColoniesNum
        if VecCen(k,FileNum,1)>0
            colourText = 'w';
            WeightText = 'normal';
            FirstTime = find(VecCen(k,:,1), 1, 'first');
            % marking in red the new colonies
            if FirstTime == FileNum
                colourText = 'r';
                WeightText = 'demi';
            end

            % marking in blue the colonies that are going to disapear
            if FileNum<length(Times)
                if ~VecCen(k,FileNum+1,1)
                    colourText = 'b';
                    WeightText = 'demi';
                end
            end

            % Check for excluded bacteris
            if ColoniesStatus(k)==1
                colourText = 'm';
            elseif ColoniesStatus(k)==2
                colourText = 'y';
            end   

            text (VecCen(k,FirstTime,1),...
                     VecCen(k,FirstTime,2),...
                     num2str(k),'color',colourText ,'BackgroundColor','none',...
                     'FontSize',8, 'FontWeight', WeightText,...
                     'HorizontalAlignment','center','VerticalAlignment','middle');
        end
    end
end

