%% Normalizing Function
% Relies on normFunction.m and
% masterlist.mat(can be generated with trial_master.m).

% clearvars -except distData sacData masterlist
 addpath 'C:\Users\acgis\Documents\GitHub\spineKinematics\SpineData\CustomMatlabScripts'
addpath 'C:\Users\acgis\Documents\GitHub\spineKinematics\SpineData\Statistics'
 
 %% Read in Data
% Read in data
load('masterlist.mat')
dataDir = "C:/Users/acgis/Documents/GitHub/SpineKinematics/SpineData/ProcessedData/Hector/";
sacData = [];
savePlots = "N";


i = 0;
% epsilon: 188:241 
% hector: 314:361
for n = 314:361
    i = 1+i;
    fname = dataDir+masterlist(n, 1);
    sacData{i} = csvread(fname+ "_sacMM.txt");
    distData{i} = rmoutliers(csvread(fname+"_distractionRight.txt"));
    
    % create technique order list
    tmpTechs(i,:) = strsplit(masterlist(n,2), ' ');
    techName{i} = strsplit(tmpTechs(i,2), '_');
end

cadTechOrder = findTechOrder(techName);

lab = ["2person lift","", "mperson strap","", "ltp standard", "","mperson gurney","", "logroll","", "scoop", "","mperson spineboard", "","ltp","", "vacuum"];


figure('name', 'SAC')
n = -5;
    for t = 1:2:16
        n = n + 6;
        subplot(9,2,t)
            hold on
            plot(sacData{n})
            plot(sacData{n+1})
            plot(sacData{n+2})
            title(lab(t));
            
        subplot(9,2,t+1)
        hold on 
            plot(sacData{n+3})
            plot(sacData{n+4})
            plot(sacData{n+5})
        title(lab(t));

    end
    
    subplot(9,2,1);
    title("No Collar")
    subplot(9,2,2);
    title("Collar")
    subplot(9,2,17)
    xlabel("Frame")
    subplot(9,2,18)
    xlabel("Frame")
        sgtitle("SAC")

figure()
n = -5;

    for t = 1:2:16
        n = n + 6;
        subplot(9,2,t)
            hold on
            plot(distData{n})
            plot(distData{n+1})
            plot(distData{n+2})
            title(lab(t));

            subplot(9,2,t+1)
        hold on 
            plot(distData{n+3})
            plot(distData{n+4})
            plot(distData{n+5})
        title(lab(t));
    end
    
    subplot(9,2,1);
    title("No Collar")
    subplot(9,2,2);
    title("Collar")
    subplot(9,2,17)
    xlabel("Frame")
    subplot(9,2,18)
    xlabel("Frame")
    sgtitle("Distraction (mm)")


%% Normalize Everything
technique = ["MPerson SpineBoard", "Vacuum", "LTP Standard", "Scoop", "LogRoll",...
    "LTP", "MPerson Gurney", "MPerson Strap", "2Person lift"];

for case_tech = [1 2 3 4 5 6 7 8 9]
    cad_tech = find(cadTechOrder == case_tech);
    if isempty(cad_tech)
        disp("No Data for " + technique(case_tech));
        continue
    end
    % E_tech = find(technique == tech);


    for n = 1:6
        tmpd.dist{n} = distData{n+(6*(cad_tech-1))}(5:end-5);
        tmpd.sac{n} = sacData{n+(6*(cad_tech-1))}(5:end-5);
    end 

    [dist{case_tech}, sac{case_tech}] = normData(case_tech,tmpd, savePlots);
end

%% Plot Normalized


figure('name', 'SAC')
n = -5;

sp = 1:2:18;
x = linspace(0,100,1001);

for tech = [1 2 3 4 5 6 7 8 9]
     for trial = 1:3
         subplot(9,2,sp(tech));
         hold on
            plot(x,sac{tech}{trial});
     end
     title(technique(tech)+" (NC)");

     for trial = 4:6
         subplot(9,2,sp(tech)+1);
         hold on
            plot(x,sac{tech}{trial});
     end
     title(technique(tech)+" (C)");
end
    
    subplot(9,2,1);
%     title("No Collar")
    subplot(9,2,2);
%     title("Collar")
    subplot(9,2,17)
    xlabel("% Activity Cycle")
    subplot(9,2,18)
    xlabel("% Activity Cycle")
        sgtitle("SAC (mm^2)")

figure()
for tech = [1 2 3 4 5 6 7 8 9]
     for trial = 1:3
         subplot(9,2,sp(tech));
         hold on
            plot(x,dist{tech}{trial});
     end
     title(technique(tech)+" (NC)");

     for trial = 4:6
         subplot(9,2,sp(tech)+1);
         hold on
            plot(x,dist{tech}{trial});
     end
     title(technique(tech)+" (C)");
end


    subplot(9,2,17)
    xlabel("% Activity Cycle")
    subplot(9,2,18)
    xlabel("% Activity Cycle")
    sgtitle("Distraction (mm)")
    
    
%% Helper Functions

function techOrder = findTechOrder(trialNames)  

% set labels from masterlist
labels = ["MPerson SpineBoard", "Vacuum", "LTP Standard", "Scoop", "LogRoll", ...
    "LTP Flexed Knees", "MPerson Gurney", "MPerson Strap", "2Person lift"];

techNames = cellfun(@(x) strjoin(x(1:end-1), ' '), trialNames);
order = unique(techNames, 'stable');
[~, techOrder] = ismember(order, labels);

% pad with zeroes if not all techniques were run
techOrder(end+1:9) = 0; 

end

