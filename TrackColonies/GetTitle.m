function Title=GetTitle(Time,ColoniesN,Desc)
    Title = sprintf('%s, %5d minutes, Number of colonies: %4d', ...
                   Desc,Time, ColoniesN);
end