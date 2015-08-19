
function showseg(segmentations)

    for i = 1 : size(segmentations, 3)

        s = segmentations(:,:,i);
        s(s == 1) = 255;
        s(s < 255) = 0;

        figure, imshow(s);

    end;

end