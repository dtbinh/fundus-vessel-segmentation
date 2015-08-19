
function [ricci] = Ricci2007(I, mask, unary)

    % Get the green inverted channel
    I = 1 - im2double(I);

    % Preallocate the features
    ricci = zeros(size(I,1), size(I,2), 2);
    
    % Assign the line response and get the best angles
    [ricci(:,:,1), ang]  = get_lineresponse(I, 0:15:165, 15, 15); 
    
%     % Get the closest principal angle for the orthogonal line
%     ang = mod(ang + 90, 180);
%     mod45 = mod(ang, 45);
%     ang = idivide(uint8(ang), 45);
%     ang(mod45 > 22.5) = ang(mod45 > 22.5) + 1;
%     ang = double(ang * 45);
%     
%     % Compute the response of the perpendicular line
%     [ricci(:,:,2), ~] = get_lineresponse(I, ang, 15, 3);

end

