function [features] = Soares2006(I, mask, unary, options)

%
% Copyright (C) 2006  João Vitor Baldini Soares
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 51 Franklin Street, Fifth Floor,
% Boston, MA 02110-1301, USA.
%


% Set parameters
if (~exist('options','var'))
    scales = [2 3 4 5];
else
    scales = options.scales;
end

%paderosionsize = 5;

%I = Intensities(I, mask, unary, options.Intensities);

I = (double(I) - min(I(:))) / (max(I(:)) - min(I(:)));

% Inverting so vessels become brighter.
I = 1 - I;

% % Makes the image larger before creating artificial extension, so the
% % wavelet doesn't have border effects
% [sizey, sizex] = size(I);
% 
% bigimg = zeros(sizey + 100, sizex + 100);
% bigimg(51:(50+sizey), 51:(50+sizex)) = I;
% 
% bigmask = logical(zeros(sizey + 100, sizex + 100));
% bigmask(51:(50+sizey), (51:50+sizex)) = mask;
% 
% % Creates artificial extension of image.
% bigimg = fakepad(bigimg, bigmask, paderosionsize, 50);

features = [];

% Below, creates the maximum wavelet response over angles and adds
% them as pixel features
bigimg = I;
fimg = fft2(bigimg);

k0x = 0;

for k0y = [3]
  for a = scales
    for epsilon = [4]
      % Maximum transform over angles.
      trans = maxmorlet(fimg, a, epsilon, [k0x k0y], 10);
      %trans = trans(51:(50+sizey), (51:50+sizex));
      
      % Adding to features
      features = cat(3, features, trans);
    end
  end
end

if (~unary)
    features = max(features, [], 3);
end