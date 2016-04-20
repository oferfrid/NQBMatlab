function h = multiHistograms(data, Xedges, Color_)
%% h = multiHistograms(data, Xedges, Color_)
% creates m histograms (1d histograms) on 3d axis
% Arguments: data - m cells of data points for histograms
%            Xedges - edges of bins of histogram
%            Color_ - m cells of colours;
% -------------------------------------------------------------------------
% Irit L. Reisman 01.2016
% based on http://www.mathworks.com/matlabcentral/answers/259767-3d-histgram-plot-for-n-m-matrix-visualize-result-monte-carlo-simulation
    
    %%
    % Create histograms and rotate them into place
    max_val = 0;
    for i=1:length(data)
      g = hgtransform('Matrix',makehgtform('translate',[0 i 0], ...
                                           'xrotate',pi/2));
      if i==1
          hold on
      end
      h = histogram(data{i}, Xedges ,'FaceAlpha',0.8,'FaceColor',Color_{i},...
          'Normalization','pdf');
      h.Parent = g;
      max_val = max(max_val,max(h.Values));
    end
    
    %%
    % Setup axes correctly
    az=22 ;el=8;
    set(gca,'SortMethod','depth')
    xlim([min(Xedges) max(Xedges)])
    ylim([1 length(data)])
    zlim([0 max_val])
    view([az,el]) %view(3)
    xlabel('Value')
    ylabel('Series')
    zlabel('Probability')
    box on
    grid on
end