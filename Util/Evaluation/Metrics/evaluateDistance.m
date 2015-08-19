
function [ret, value] = evaluateDistance(humanObserver, currentVector, bestVector)
    if (pdist2(humanObserver, currentVector) < pdist2(humanObserver, bestVector))
        ret = 1; % Return 1 if currentVector is closer to the humanObserver than bestVector
        value = pdist2(humanObserver, currentVector);
    elseif (pdist2(currentVector,[1 1]) < pdist2(humanObserver, [1 1])) && (pdist2(currentVector,[1 1]) < pdist2(bestVector, [1 1]))
        ret = 2; % Return 2 if currentVector is better than the humanObserver and the bestVector
        value = pdist2(currentVector,[1 1]);
    else
        ret = 0; % Return 0 if currentVector is away from the humanObserver
        value = pdist2(humanObserver, currentVector);
    end    
end