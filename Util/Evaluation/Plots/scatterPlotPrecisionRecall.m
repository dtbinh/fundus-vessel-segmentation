
function scatterPlotPrecisionRecall

    % Compute the F1-score isocurves
    [precisionDomain, recallDomain] = ndgrid(linspace(0, 1, 100));
    fScore = 2 * (precisionDomain .* recallDomain) ./ (precisionDomain + recallDomain);
    c = contour(fScore, 5);
%     s = getcontourlines(c, 10);
%     plot(s(1).x, s(1).y, 'b', s(4).x, s(4).y, 'b');

end


function s = getcontourlines(c, numberOfCurves)

    sz = size(c, numberOfCurves);
    ii = 1;
    jj = 1;
    
    while ii < sz
        n = c(2, ii);
        s(jj).v = c(1, ii);
        s(jj).x = c(1, ii+1:ii+n);
        s(jj).y = c(2,ii+1:ii+n);
        ii = ii + n + 1;
        jj = jj + 1;
    end

end