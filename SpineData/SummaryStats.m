%% Summary Statistics

% from 54x1 to 3x18

mat = SacMean;

means = reshape(mat, 3, []);
mu = mean(means);
stdev = std(means);
mu = reshape(mu, 2, [])';
stdev = reshape(stdev, 2, [])';

