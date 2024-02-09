%% Check mean XYZ Raw Displacements of polhemus sensors for each cadaver

load("stats_master.mat")
%% Plot

stats = mean(data, 'omitnan');
stats = squeeze(stats);
summary = mean(stats');


sdv(1,:) = stats(1,:) + summary(4);
sdv(2,:) = stats(1,:) - summary(4);

sdv(3,:) = stats(2,:) + summary(5);
sdv(4,:) = stats(2,:) - summary(5);

sdv(5,:) = stats(3,:) + summary(6);
sdv(6,:) = stats(3,:) - summary(6);

x = [1:10 10:-1:1];

inBet(1,:) = [sdv(1,:), fliplr(sdv(2,:))];
inBet(2,:) = [sdv(3,:), fliplr(sdv(4,:))];
inBet(3,:) = [sdv(5,:), fliplr(sdv(6,:))];


figure()
hold on

errorbar(stats(1,:), stats(4,:),'r.', 'markersize', 18);
errorbar(stats(2,:), stats(5,:),'b.', 'markersize', 18);
errorbar(stats(3,:), stats(6,:),'.','color', "#EDB120", 'markersize', 18);

yline(summary(1),'r', 'linewidth', 2);
yline(summary(2),'b', 'linewidth', 2);
yline(summary(3),'color', "#EDB120", 'linewidth', 2);

fill(x, inBet(1,:), 'r', 'facealpha', 0.3, 'edgecolor', 'none');
fill(x, inBet(2,:), 'b', 'facealpha', 0.3, 'edgecolor', 'none');
fill(x, inBet(3,:), [0.8500 0.3250 0.0980], 'facealpha', 0.3, 'edgecolor', 'none');

sub = {"Alpha", "Beta", "Charlie", "Delta", "Epsilon","Fred", "Gamma",...
"Hector", "Iota", "Kappa"};
xticklabels(sub);

legend("X", "Y", "Z", "","","","","","","");







