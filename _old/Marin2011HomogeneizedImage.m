
function [ih] = Marin2011HomogeneizedImage(I, mask, unary)

    % vessel central light reflex removal
    ig = imopen(I, strel('disk', 3, 8));

    % background homogenization
    i1 = imfilter(I, fspecial('average', [3 3]));
    i2 = imfilter(i1, fspecial('gaussian', [9,9], 1.8));
    ib = roifilt2(fspecial('average', [69 69]), i2, mask);
    
    % difference between Igamma and Ib
    d = (double(ig) - double(ib));

    % linear modification
    isc = double(((d - min(d(logical(mask)))) ./ (max(d(logical(mask))) - min(d(logical(mask))))) * 255);
    
    % get ih 
    g = isc + 128 - mode(isc(logical(mask)));
    ih = g;
    ih(g<0) = 0;
    ih(g>255) = 255;

end