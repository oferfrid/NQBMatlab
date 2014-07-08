function myhandle = DrawCircles(radii,centers,lineWidthVal,lineStyleVal,circColor)
 % myhandle = circles(radii,centers,lineWidthVal,lineStyleVal,circColor)
        % Plots multiple circles as a single line object
        % Written by Brett Shoelson, PhD
        resolution = 2;
        theta=0:resolution:360;
        
        x_circle = bsxfun(@times,radii,cos(theta*pi/180));
        x_circle = bsxfun(@plus,x_circle,centers(:,1));
        x_circle = cat(2,x_circle,nan(size(x_circle,1),1));
        x_circle =  x_circle';
        x_circle = x_circle(:);
        
        y_circle = bsxfun(@times,radii,sin(theta*pi/180));
        y_circle = bsxfun(@plus,y_circle,centers(:,2));
        y_circle = cat(2,y_circle,nan(size(y_circle,1),1));
        y_circle =  y_circle';
        y_circle = y_circle(:);
        
        hold on;
        myhandle = plot(x_circle,y_circle);
        set(myhandle,...
            'linewidth',lineWidthVal,...
            'linestyle',lineStyleVal,...
            'color',circColor,...
            'tag','mycircles');
%         try
%             mycircs = findall(gcf,'tag','mycircles');
%             if ~isempty(mycircs)
%                 while true
%                     pause(1)
%                     if strcmp(get(mycircs(1),'visible'),'on')
%                         set(mycircs(1),'visible','off');
%                     else
%                         set(mycircs(1),'visible','on');
%                     end
%                 end
%             end
%         catch
%             disp('no flicker')
%         end
    end