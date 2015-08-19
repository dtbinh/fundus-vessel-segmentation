
function [delta] = lossCB(param, y, tildey)

    delta = length(find(y~=tildey));
    
end