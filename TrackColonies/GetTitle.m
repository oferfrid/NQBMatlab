function Title=GetTitle(Time,ColoniesN,Desc)
    Title = sprintf('%s, %5d minutes, Number of colonies: %4d', ...
                   Desc,round(Time*24*60), ColoniesN);
end