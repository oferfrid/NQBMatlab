function [res maxRs] = findCirc(Radii, Xs, Ys, img, rhoThresh,jump)
%% [res maxRs] = findCirc(Radii, Xs, Ys, img, rhoThresh,jump)
%--------------------------------------------------------------------------
% Purpose: This function finds the best fit circle in an image. This
%   function is NOT regular hough transfom for circles, but for the cases
%   that you know approximatley where and what size the circle is.
%
% Arguments : Radii - range of interesting radix i.e. 5:10 with jump or without...
%   Xs - range of Xs for the center
%   Ys - range of Ys for the center
%   img - gray-level 2D (and not 3D) image. results are in image coordinates
%   rhoThresh - aimed at ignoring img noise, only image gradients 
%             with Rho greater or equal to rhoThresh are considered
%   jump - the jump in the Radii range
%
% Results:
%   res is a [N,3] matrix where column 1&2 are Y&X cordinate respectvely,
%   column 3 is the radix.
%--------------------------------------------------------------------------
% Irit Levin. 03.2007

verbose = 0;

%% stage 1 - find pixels on edges 
filter = [0 1 2 1 0]'*[0 1 0 -1 0]./4;
%filter = filter./sum(filter(:));
dx = conv2(img,filter,'same');
dy = conv2(img,filter','same');

rho = sqrt(dx.^2 + dy.^2);
%theta = atan2(dy,dx);
[Y,X] = find(rho > rhoThresh);


Lx = length(Xs);
Ly = length(Ys);
Lr = length(Radii);

%% do a search of x and y and r and get the score
for i = 1:Lx % go over x in Xs
    x = Xs(i);
    XX = (X-x).^2;
    for j = 1:Ly % go over y in Ys
        y = Ys(j);
        d = sqrt((Y-y).^2 + XX);
        for k = 1:Lr % go over r in Radii
            r = Radii(k);            
            % [G,H] = find(abs(d-r*r) < 2*jump*jump); % all pixels that are at distance close to r from center
            [G,H] = find(abs(d-r) < 2*jump); % all pixels that are at distance close to r from center
            score(i,j,k) = length(G);
        end % k      
    end % j    
    if(verbose ==1)
        i
    end
end % i


maxVal = max(score(:));
[maxRs maxInds]= max(score,[],3);
if(verbose == 1)
    figure(111);
    %imagesc(Xs,Ys,maxRs);
    surf(maxRs);
end
[maxX,maxY] = find(maxRs==maxVal);
res = [Xs(maxX)',Ys(maxY)',Radii(maxInds(sub2ind(size(maxInds),maxX,maxY)))'];