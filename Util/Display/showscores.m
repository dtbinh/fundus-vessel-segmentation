function showscores(segmentations)

    for i = 1 : size(segmentations, 3)
        figure, imagesc(segmentations(:,:,i));
    end;

end