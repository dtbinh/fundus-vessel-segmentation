
function [feature] = Lindeberg2001(I, mask, unary)
    
    sigmas = [1 2 3 4];

    ML = zeros(size(I,1), size(I,2), length(sigmas));
    N = zeros(size(I,1), size(I,2), length(sigmas));
    A = zeros(size(I,1), size(I,2), length(sigmas));
    
    sigmas = sqrt(sigmas);

    % For each scale
    count = 1;
    for sigma = sigmas
        
        % Compute the second derivative
        [Lx, Ly] = gradient(double(I));
        [Lxx, Lxy] = gradient(Lx);
        [~, Lyy] = gradient(Ly);
        
        % Compute Gamma-normalized derivatives
        Lpp = ((sigma^(3/2)) / 2) * (Lxx + Lyy - sqrt(((Lxx - Lyy).^2) + (4 * Lxy.^2)));
        Lqq = ((sigma^(3/2)) / 2) * (Lxx + Lyy + sqrt(((Lxx - Lyy).^2) + (4 * Lxy.^2)));
        
        % Maximum absolute value of the principal curvature
        ML = max(Lpp, Lqq);
        
        % N-gamma-norm
        N(:,:,count) = ((Lpp.^2) - (Lqq.^2)).^2;
        
        % Gamma-normalized principal curvature difference
        A(:,:,count) = (Lpp - Lqq).^2;
        
        count = count + 1;
    end
    
    feature = zeros(size(I,1), size(I,2), 3);
    feature(:,:,1) = max(ML,[],3);
    feature(:,:,2) = max(N,[],3);
    feature(:,:,3) = max(A,[],3);

end