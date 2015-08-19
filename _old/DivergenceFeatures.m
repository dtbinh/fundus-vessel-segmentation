
function [features] = DivergenceFeatures(I, mask, unary)

    I = double(I);
    
    highcontrastcenterlines = zeros(size(I));
    bloodvesselcandidates = (zeros(size(I)));
    sigmas = sqrt(0.2:1:4);
    for k = -1 : 6
        
        % High contrast centerlines
        psi_1 = 0.4 + 0.05 * (k - 1);
        for sigma = sigmas
            for theta = 0:15:179
                highcontrastcenterlines = highcontrastcenterlines + removeArtifacts(getNormalizedDivergence(I,sigma,theta) > psi_1);
            end
        end
        
        % Detection of blood vessel-like objects
        psi_3 = 1 + 0.5 * (k - 1);    
        for sigma = sigmas
            for theta = [0 45]
                bloodvesselcandidates = bloodvesselcandidates + ...
                    removeArtifacts(getDivergence(I, sigma, theta) ./ (imfilter(I/255, fspecial('gaussian', [ceil(3*sigma) ceil(3*sigma)], sigma))) > psi_3);
            end
        end
        
    end
    
    % Low contrast centerlines
    sigmas = sqrt(3:1:5);
    for sigma = sigmas
        lowcontrastcenterlines = zeros(size(I));
        lowcontrastcenterlines = max( ...
            getNormalizedDivergence(I,sigma,0) ./ (imfilter(I/255, fspecial('gaussian',[ceil(3*(sigma)) ceil(3*(sigma))],(sigma)))), ...
            lowcontrastcenterlines );
    end
    lowcontrastcenterlines = removeArtifacts(lowcontrastcenterlines > 1);
    
    
    features = cat(3,highcontrastcenterlines,lowcontrastcenterlines,bloodvesselcandidates);
    
    
end



function [g] = getDivergence(I, sigma, angle)

    % Filter image with Gaussian
    filtered = imfilter(I, fspecial('gaussian', [41 41], sigma));
    
    % Compute the gradient vector field
    [xx, yy] = gradient(filtered);
    
    % Rotation matrix
    rotMat = [cosd(angle), -sind(angle); sind(angle), cosd(angle)];
    
    % Compute rotated field
    vR = [double(xx(:)), double(yy(:))] * rotMat;
    U = reshape(vR(:,1), size(xx));
    V = reshape(vR(:,2), size(yy));
    
    % Divergence
    g = divergence(1:size(I,2), 1:size(I,1), U, V);
    
end


function [ng] = getNormalizedDivergence(I, sigma, angle)

    % Filter image with Gaussian
    filtered = imfilter(I, fspecial('gaussian', [41 41], sigma));
    
    % Compute the gradient vector field
    [xx, yy] = gradient(filtered);
    norms = sqrt(xx.^2 + yy.^2);
    xx = xx ./ norms;
    yy = yy ./ norms;
    
    % Rotation matrix
    rotMat = [cosd(angle), -sind(angle); sind(angle), cosd(angle)];
    
    % Compute rotated field
    vR = [double(xx(:)), double(yy(:))] * rotMat;
    rotxx = reshape(vR(:,1), size(xx));
    rotyy = reshape(vR(:,2), size(yy));
    
    % Divergence
    ng = divergence(1:size(I,2), 1:size(I,1), rotxx, rotyy);

end


function [newbw] = removeArtifacts(bw)
    newbw = bwareaopen(bwmorph(bw,'skel'), 50);
end