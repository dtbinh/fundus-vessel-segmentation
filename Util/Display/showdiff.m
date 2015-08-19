
function showdiff(diffMaps)

    for i = 1 : size(diffMaps, 4)
        figure, imshow(diffMaps(:,:,:,i));
    end;
    
end