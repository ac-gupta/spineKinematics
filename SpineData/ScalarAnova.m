%% Epsilon Anova

% load in distraction, sac, and trial order

% overall order
technique = ["MPerson SpineBoard", "Vacuum", "LTP Standard", "Scoop", "LogRoll",...
    "LTP", "MPerson Gurney", "MPerson Strap", "2Person lift"];

% Epsilon order:
E = [9 8 3 7 5 4 1 6 2];
E = 1:9;

load('Epsilon_Norm2.mat')

dist = distMaster;
sac = sacMaster;

%% Prepare data for Anova:

% collar is 0 0 0 1 1 1 (NC, C)
Collar = repmat([0 0 0 1 1 1]', 9, 1);
Technique = repmat(E-1, 6, 1);
Technique = Technique(:);

Subj = zeros(54,1);

% 
for n = 1:9
    tmpd{n} = cell2mat(dist{n}');
    tmps{n} = cell2mat(sac{n}');
    
    DistMean = mean(cell2mat(tmpd'),2);
    SacMean = mean(cell2mat(tmps'),2);
end

%% Anova
[~, ~, stats] = anovan(DistMean, {Technique, Collar}, 'model', 'interaction', 'varnames', {'Technique', 'Collar'});
figure('Name', 'Dist')
[results, ~, ~, gnames] = multcompare(stats);

[~, ~, stats] = anovan(SacMean, {Technique, Collar}, 'model', 'interaction', 'varnames', {'Technique', 'Collar'});
figure('Name', 'Sac')
[results, ~, ~, gnames] = multcompare(stats);