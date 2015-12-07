function warp_images(basename_old, basename_new, indices, motions)
%Copyright 2008 Nathalie Q. Balaban Lab, Michael Mumcuoglu, Giora Engel, Amitai Zernik
%the program is distributed under the terms of the GNU General Public License.

acc_u = 0;
acc_v = 0;

for ii = 1:length(indices)
    ind = indices(ii)
    old_name = sprintf(basename_old, ind);
    new_name = sprintf(basename_new, ind);
    im = im2double(imread(old_name));
    acc_u = acc_u + motions(ii, 1);
    acc_v = acc_v + motions(ii, 2);
    warped = warp_trans(im, acc_u, acc_v, 0, 'cubic');
    imshow(warped,[]);pause(1/10);
    imwrite(warped, new_name, 'BitDepth', 16);
end