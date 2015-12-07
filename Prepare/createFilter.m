function filter = createFilter(filterLevel)
%Copyright 2008 Nathalie Q. Balaban Lab, Michael Mumcuoglu, Giora Engel, Amitai Zernik
%the program is distributed under the terms of the GNU General Public License.
%
%createFilter creates a gaussian blur filter
%
%filterLevel - the pascal level to use for the gausiian blur filter.
%returns a 2d convolution filter.

%if (filterLevel < 0 || filterLevel > 5)
%    error 'filterLevel should be > 0 and < 5'
%end

%prepare the pascal row (1d)
filter = [1];
for i = 1:filterLevel
    filter = conv(filter,[0.5 0.5]);
end

%create a 2d filter from the 1d pascal row and return
filter = filter'*filter;