%% ANOVA testing to check for differences in cadaver group

load("stats_master.mat");
load("masterlist.mat");

% effect groups:
    % cad group: (1-5;6-10)
    % technique: 1-9

% technique ID list
tech = double(masterlist(2:end,3));
tech = floor(tech);

% cadaver list
cads = char(masterlist(2:end,1));
cads = double(cads(:,5)) - double('A');

cadGrp = cads;
cadGrp(cadGrp(:) < 5) = 0;
cadGrp(cadGrp(:)>4) = 1;

% stack XYZ data
coords = [];

for n = 1:10
    coords = [coords; data(:,1:3,n)];
end

coords(any(isnan(coords), 2), :) = [];

% store data as table
% 
t = table(coords(:,1), coords(:,2), cadGrp, tech, ...
    'VariableNames', {'X','Y', 'SurgicalGrp', 'Tech'});

[~,~, grpstats.X] = anova1(t.X, categorical(cadGrp));
    f = gcf; f.Name = "X: CADs 1-5 = 0, CADs 6-10 = 1";
    set(get(gca, 'title'), 'string', "X: CADs 1-5 = 0, CADs 6-10 = 1");
    ylabel("distraction (mm)"); xlabel("Cadaver Group");
[~,~,grpstats.Y] = anova1(t.Y, categorical(cadGrp));
    f = gcf; f.Name = "Y: CADs 1-5 = 0, CADs 6-10 = 1";
    set(get(gca, 'title'), 'string', "Y: CADs 1-5 = 0, CADs 6-10 = 1");
    ylabel("distraction (mm)"); xlabel("Cadaver Group");
[~,~, indstats.X] = anova1(t.X, categorical(cads));
    f = gcf; f.Name = "X: Individual CADs";
    set(get(gca, 'title'), 'string', "CADs X");
    ylabel("distraction (mm)"); xlabel("Cadaver");
[~,~,indstats.Y] = anova1(t.Y, categorical(cads));
    f = gcf; f.Name = "Y: Individual CADs";
    set(get(gca, 'title'), 'string', "CADs Y");
    ylabel("distraction (mm)"); xlabel("Cadaver");



% % check each cadaver
% t = table(coords(:,1), coords(:,2), string(cads), string(tech), ...
%     'VariableNames', {'X','Y', 'Cad', 'Tech'});
% Cds = table([1 2]', 'VariableNames', {'Coordinates'});
% 
% rm = fitrm(t, 'X-Y ~ Cad*Tech', 'WithinDesign', Cds);
% 
% ranovatbl = ranova(rm);



%% Extra code

% check X/Y/Z
% t = table(coords(:,1), coords(:,2), coords(:,3), cadGrp, tech, ...
%     'VariableNames', {'X', 'Y', 'Z', 'SurgicalGrp', 'Tech'});
% Cds = table([1 2 3]', 'VariableNames', {'Coordinates'});
% 
% rm = fitrm(t, 'X-Z ~ SurgicalGrp*Tech', 'WithinDesign', Cds);
