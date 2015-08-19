
function [features] = Lupascu2010ElongatedFeatures(I, mask, unary)

    % Principal directions: eigenvectors
    [lambdas1, maxeigenvectors, mineigenvectors, lambdas2] = eigeninformation(I, mask, sqrt(2));
    eigenvectors = cat(3, maxeigenvectors, mineigenvectors);
    
    % Mean curvature: average of eigenvalues of the Hessian matrix
    lambdas = cat(3, lambdas1, lambdas2);
    meanCurvature = mean(lambdas,3);
    
    features = cat(3, meanCurvature, eigenvectors);
    
end