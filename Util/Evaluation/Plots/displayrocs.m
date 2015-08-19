
function displayrocs(X, Y, X_, Y_)

    figure, plot(X, Y);
    hold on;
    plot(X_, Y_,'b-.');
    hold on;
    plot([0 1],[0 1],'r-.');

end