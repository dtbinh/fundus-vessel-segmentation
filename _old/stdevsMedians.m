

N = 20; % Max number of samples
stdevs = zeros(N,1); % Standard deviation of each median
for n = 1 : N

    toComputeDeviation = zeros(5,1); % Fill an array with 5 different medians
    for i = 1 : 5
        pp = p(:); % get the pairwise feature
        medd = zeros(n,1); % n-medians
        for j = 1 : length(medd)
            [rs, ind] = datasample(pp, 10000, 'Replace', false); % take a random sample
            pp(ind)=[]; % remove rs from pp (sampling without replacement)
            medd(j) = abs((median(pdist(rs)))); % estimate the median from the random sample
        end
        toComputeDeviation(i) = median(medd); % median of the n-medians
    end
    stdevs(n) = std(toComputeDeviation); % standard deviation of the medians of the n-medians
    disp(stdevs(n));
    
end
figure, plot(stdevs);