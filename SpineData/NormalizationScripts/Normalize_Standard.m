%% Normalizing Function
% Relies on normFunction.m and
% masterlist.mat(can be generated with trial_master.m).

clearvars -except nData masterlist
 addpath 'C:\Users\acgis\Documents\GitHub\spineKinematics\SpineData\CustomMatlabScripts'
addpath 'C:\Users\acgis\Documents\GitHub\spineKinematics\SpineData\Statistics'
 
 %% Read in Data
% Read in data
load('masterlist.mat')
homeDir = "C:/Users/acgis/Documents/GitHub/SpineKinematics/SpineData/ProcessedData/";
sacData = [];
plt = "Y";

PatPath = "Epsilon";

dataDir = homeDir + PatPath + "/";

[inds] = findTrialInfo(PatPath);

i = 0;

for n = inds
    i = 1+i;
    fname = dataDir+masterlist(n, 1);
    sacData{i} = csvread(fname+ "_sacMM.txt");
    distData{i} = (csvread(fname+"_distractionRight.txt"));
    kinematics{i}(:,:) = (csvread(fname+"_Kinematics.txt"));

    
    % remove spikes
    [sacData{i}, distData{i}, kinematics{i}] = ...
        rmspikes(sacData{i}(5:end-5), distData{i}(5:end-5), kinematics{i}(5:end-5,:));
    
    % create technique order list
    tmpTechs(i,:) = strsplit(masterlist(n,2), ' ');
    techName{i} = strsplit(tmpTechs(i,2), '_');
end

[cadTechOrder, trialInfo] = findTechOrder(techName);

%% Normalize Everything
technique = ["MPerson SpineBoard", "Vacuum", "LTP Standard", "Scoop", "LogRoll",...
    "LTP Flexed Knees", "MPerson Gurney", "MPerson Strap", "2Person lift"];

for case_tech = [1 2 3 4 5 6 7 8 9]
    cad_tech = find(cadTechOrder == case_tech);
    if isempty(cad_tech)
        disp("No Data for " + technique(case_tech));
        continue
    end
        
    collarCond{case_tech} = trialInfo(trialInfo == technique(case_tech),2) == "C";
    trials = find(trialInfo == technique(case_tech));
    
    for i = 1:length(trials)
        
        tmpd.dist{i} = distData{trials(i)};
        tmpd.sac{i} = sacData{trials(i)};
        tmpd.kin{i} = kinematics{trials(i)};
        
        x = linspace(0, 100, length(tmpd.dist{i}));
        xq = 0:0.1:100;
       
        dist{case_tech}{i} = interp1(x, tmpd.dist{i}, xq);
        
        x = linspace(0, 100, length(tmpd.sac{i}));
        xq = 0:0.1:100;
        sac{case_tech}{i} = interp1(x, tmpd.sac{i}, xq);
        
        x = linspace(0, 100, length(tmpd.kin{i}));
        xq = 0:0.1:100;
        kin{case_tech}{i} = interp1(x, tmpd.kin{i}, xq);
        
    end 
    plotNorm(sac{case_tech}, dist{case_tech}, xq, tmpd.sac, tmpd.dist, ...
        technique(case_tech), collarCond{case_tech}, plt, PatPath);
end

%% change cells into matrices
% 1-9 cells for each technique (may be empty if the technique wasn't
% tested). Each cell has cells for each trial; instead, stack them as a
% nx1001 matrix where n = number of trials. Add cell for collar conditions.

for n = 1:9
    nData.(PatPath){n}{1} = cell2mat(dist{n}');
    nData.(PatPath){n}{2} = cell2mat(sac{n}');
    nData.(PatPath){n}{3} = cell2mat(kin{n}');
        nData.(PatPath){n}{3} = permute(reshape(nData.(PatPath){n}{3}', 6,1001,[]), [2 1 3]);
    nData.(PatPath){n}{4} = collarCond{n};
end   
    
%% Plot Normalized Distraction

figure('Name', PatPath + " nDist", 'Position',  [0, 40, 760, 750]);

% number of subplots is the same as number of techniques tested
techsTested = sort(cadTechOrder(cadTechOrder~=0));
plots = length(techsTested);

t = tiledlayout(plots, 1, 'TileSpacing', 'Compact');

for i = techsTested
   nexttile
   title(technique(i))
   xtickformat('percentage')
   hold on
   % plot means
   plot(xq, mean(nData.(PatPath){i}{1}(nData.(PatPath){i}{4}, :)), 'r');
   plot(xq, mean(nData.(PatPath){i}{1}(~nData.(PatPath){i}{4}, :)), 'b');
   
   for j = 1:length(nData.(PatPath){i}{4})
       if nData.(PatPath){i}{4}(j) == true
           c = [1 0 0 0.2];
       else
           c = [0 0 1 0.2];
       end
       plot(xq, nData.(PatPath){i}{1}(j, :), 'color', c, 'linestyle', '--')
   end    
end

title(t, PatPath + " Normalized Distraction (mm)");
ylabel(t, 'Distraction (mm)');
xlabel(t, '% Activity');
leg = legend('Collar', 'No Collar', 'Box', 'Off', 'Orientation', 'Horizontal', 'AutoUpdate', 'off');
leg.Layout.Tile = 'south';

if plt == "Y"
    saveas(gcf, PatPath + "Dist_normalized.jpg");
end

%% Plot Normalized SAC

figure('Name', PatPath + " nSAC", 'Position',  [0, 40, 760, 750]);

% number of subplots is the same as number of techniques tested
techsTested = sort(cadTechOrder(cadTechOrder~=0));
plots = length(techsTested);

t = tiledlayout(plots, 1, 'TileSpacing', 'Compact');

for i = techsTested
   nexttile
   title(technique(i))
   xtickformat('percentage')
   hold on
   % plot means
   plot(xq, mean(nData.(PatPath){i}{2}(nData.(PatPath){i}{4}, :)), 'r');
   plot(xq, mean(nData.(PatPath){i}{2}(~nData.(PatPath){i}{4}, :)), 'b');
   
   for j = 1:length(nData.(PatPath){i}{4})
       if nData.(PatPath){i}{4}(j) == true
           c = [1 0 0 0.2];
       else
           c = [0 0 1 0.2];
       end
       plot(xq, nData.(PatPath){i}{2}(j, :), 'color', c, 'linestyle', '--')
   end    
end

title(t, PatPath + " Normalized SAC (mm^2)");
ylabel(t, 'SAC (mm^2)');
xlabel(t, '% Activity');
leg = legend('Collar', 'No Collar', 'Box', 'Off', 'Orientation', 'Horizontal', 'AutoUpdate', 'off');
leg.Layout.Tile = 'south';

if plt == "Y"
    saveas(gcf, PatPath + "SAC_normalized.jpg");
end

%% Plot Normalized F/E

figure('Name', PatPath + " nFE", 'Position',  [0, 40, 760, 750]);

% number of subplots is the same as number of techniques tested
techsTested = sort(cadTechOrder(cadTechOrder~=0));
plots = length(techsTested);

t = tiledlayout(plots, 1, 'TileSpacing', 'Compact');

for i = techsTested
   nexttile
   title(technique(i))
   xtickformat('percentage')
   hold on
   % plot means
   plot(xq, mean(squeeze(nData.(PatPath){i}{3}(:,4,nData.(PatPath){i}{4})),2), 'r');
   plot(xq, mean(squeeze(nData.(PatPath){i}{3}(:,4,~nData.(PatPath){i}{4})),2), 'b');
   
   for j = 1:length(nData.(PatPath){i}{4})
       if nData.(PatPath){i}{4}(j) == true
           c = [1 0 0 0.2];
       else
           c = [0 0 1 0.2];
       end
       plot(xq, nData.(PatPath){i}{3}(:,5,j), 'color', c, 'linestyle', '--')
   end    
end

title(t, PatPath + " Normalized F/E(-/+) ({\circ})");
ylabel(t, 'F/E (-/+) ({\circ})');
xlabel(t, '% Activity');
leg = legend('Collar', 'No Collar', 'Box', 'Off', 'Orientation', 'Horizontal', 'AutoUpdate', 'off');
leg.Layout.Tile = 'south';
% 
% if plt == "Y"
%     saveas(gcf, PatPath + "FE_normalized.jpg");
% end


%% Helper Functions

function [techOrder, trialInfo] = findTechOrder(trialNames)  

% set labels from masterlist
labels = ["MPerson SpineBoard", "Vacuum", "LTP Standard", "Scoop", "LogRoll", ...
    "LTP Flexed Knees", "MPerson Gurney", "MPerson Strap", "2Person lift"];

techNames = cellfun(@(x) strjoin(x(1:end-1), ' '), trialNames);

order = unique(techNames, 'stable');
[~, techOrder] = ismember(order, labels);

% pad with zeroes if not all techniques were run
techOrder(end+1:9) = 0; 

% collar order
trialInfo = [techNames', (cellfun(@(x) x(end), trialNames))'];

end

function plotNorm(nSac, nDist, t, rawSac, rawDist, tech, N, plt, PatPath)

            figure('Position', [0 0 1000 1000])
            for n = 1:length(N)              
                if N(n) == true
                    % collar
                    c = 'r';
                else
                    % no collar
                    c = 'b'; 
                end
                
                subplot(2,2,1)
                hold on
                plot((1:length(rawDist{n}))/100, rawDist{n}, 'color', c)
                subplot(2,2,3)
                hold on
                plot(t, nDist{n}, 'color', c);
                
                subplot(2,2,2)
                hold on
                plot((1:length(rawSac{n}))/100,rawSac{n}, 'color', c)
                subplot(2,2,4)
                hold on
                plot(t, nSac{n}, 'color', c);
            end
            
            subplot(2,2,1)
                title(tech + " Distraction")
                xlabel("Time (s)")
                ylabel("Distraction (mm)")
            subplot(2,2,2)
                title(tech + " SAC")
                xlabel("Time (s)")
                ylabel("SAC (mm^2)")
            subplot(2,2,3)
                title("Normalized " + tech + " Distraction")
                xlabel("% Cycle");
                ylabel("Distraction (mm)");
            subplot(2,2,4)
                title("Normalized " + tech + " SAC")
                legend("Collar", "", "", "No Collar", "", "", 'Location', 'best', ...
                    'Orientation', 'horizontal');
                xlabel("% Cycle");
                ylabel("SAC (mm^2)")                
            if plt == "Y"
                saveas(gcf, PatPath+ "_" + tech+"_normalized.jpg");
            end
end

function [inds] = findTrialInfo(PatName)

index.A = [2:15, 17:28, 30:52];
index.B = 56:109;
index.C = 110:133;
index.D = 134:187;
index.E = 188:241;
index.F = [242:264, 266:280, 282:283];
index.G = 290:313;
index.H = 314:361; 
index.I = 362:415;
index.K = [416:439, 443, 445:472];

PatName = char(PatName);
inds = index.(PatName(1));

end

function [sac, dist, kinematics] = rmspikes(sac, dist, kinematics)
    % totally smoothed:
    smoothDist = medfilt1(dist, 15);
    smoothSac = medfilt1(sac, 15);
    smoothKin = medfilt1(kinematics, 15);
    
    % find spikes:
    spk = find(dist < -1);
    if not(isempty(spk))
        inds = [];
        for n = 1:length(spk)
            inds = [inds spk(n)-5:spk(n)+5];
        end
        inds = unique(inds, 'stable');
        inds(inds<0 | inds>length(dist)) = [];
        
        dist(inds) = smoothDist(inds);
        sac(inds) = smoothSac(inds);
        kinematics(inds) = smoothKin(inds);
    end
end
    