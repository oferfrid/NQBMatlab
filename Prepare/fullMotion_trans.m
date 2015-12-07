function [u v] = fullMotion_trans(im1, im2, guess, margin, mask)
%Copyright 2008 Nathalie Q. Balaban Lab, Michael Mumcuoglu, Giora Engel, Amitai Zernik
%the program is distributed under the terms of the GNU General Public License.
%
%motion_trans - calculates small motion between two grayscale images. uses
% translation-only iterative LK algorithm.
%
%im1, im2 - first and second images (grayscale, double)
%guess - initial guess (a vector of [u v], to start the motion 
% detection from
%margin - the length of the images margins to ignore when calculating
% motion. a frame of margin width is omitted in calculations.
%[u v] - the resulting translation parameters to apply on im2.

%use a drivative convolution of -1 0 1. this specific kernel is used so
%the the derivative is exactly aligned on the image.
DERIVE_CONV = [1 0 -1];
%initialize a pascal blur filter.
FILTER = createFilter(2);

%calculate horizontal and vertical derivatives. remove margins.
Ix = conv2(conv2(im2, FILTER, 'same'), DERIVE_CONV,  'same');
Iy = conv2(conv2(im2, FILTER, 'same'), DERIVE_CONV', 'same');
%crop matrices to remove the margins
Ix = Ix(1+margin:end-margin, 1+margin:end-margin);
Iy = Iy(1+margin:end-margin, 1+margin:end-margin);
if (~exist('mask'))
   mask = ones(size(im1)); 
end
mask = mask(1+margin:end-margin, 1+margin:end-margin);

%calculate the A matrix of the LK translation-only algorithm.
A = [sum(sum(mask.*Ix.*Ix)) sum(sum(mask.*Ix.*Iy)); sum(sum(mask.*Ix.*Iy)) sum(sum(mask.*Iy.*Iy))];

%initialize translation result to start from the guess
translation = guess;

num_of_iterations = 0;
%iterate till convergence
while (1)
    num_of_iterations = num_of_iterations + 1;

    %back-warp im1 using the current inverted translation params
    im3 = warp_trans(im1, -1*translation(1), -1*translation(2), 1, 'linear');

    %calculate the temporal derivative and crop the margins
    It = conv2(im2, FILTER, 'same')-conv2(im3, FILTER, 'same');
    It = It(1+margin:end-margin, 1+margin:end-margin);

    %calculate the b vector of the LK translation-only algorithm
    b = [-1*sum(sum(mask.*Ix.*It)); -1*sum(sum(mask.*Iy.*It))];

    if ((sum(isnan(A(:))) > 0) || (sum(isinf(A(:))) > 0))
        disp 'WARNING: A contains NAN or INF! returning 0 motion.'
        translation(1) = 0;
        translation(2) = 0;
        break;
    end        
    
    %solve the equations, and get the vector of [dx, dy] relative to
    % the last iteration.
    delta = inv(A)*b; %%MM%% was: pinv

    if (isnan(sum(delta)))
        disp 'WARNING: delta is NAN! returning 0 motion.'
        translation(1) = 0;
        translation(2) = 0;
        break;
    end        
    
    %update the approximation
    translation = translation + delta;

    %finish if error is small enough (norm is of 1/100 pixels)
    if (norm(delta) < 1e-2) %%MM%% was: 1e-1 %%%%%%%%%%%%
        break;
    end
    
    %finish is number of iterations exceeds 100
    if (num_of_iterations == 100)
        disp 'LK does not converge after 100 iterations... returning 0 motion.'
        translation(1) = 0;
        translation(2) = 0;
        break;
    end
end

%return the calculated translation
u = translation(1);
v = translation(2);