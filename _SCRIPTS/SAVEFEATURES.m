
for i = 1 : size(x,3)

    ppp = x(:,:,i);
    
    mx = max(ppp(logical(mask)));
    mn = min(ppp(logical(mask)));
    
    ppp = ppp .* mask;
    
    imgScaled = (ppp - mn) / (mx - mn);
    
    imwrite( uint8(round(imgScaled*255)), ...
        strcat('G:\Dropbox\RetinalImaging\Writing\journalVersion\Modifications\modifications_features\featuresOverPreprocessedImage\_drive\', num2str(i), '.png'));
    
end