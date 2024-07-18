%% Normalizing Function
% written specifically for Epsilon data. Relies on normFunction.m and
% masterlist.mat(can be generated with trial_master.m).

% clearvars -except distData sacData masterlist
 addpath 'C:\Users\acgis\Documents\GitHub\spineKinematics\SpineData\CustomMatlabScripts'
addpath 'C:\Users\acgis\Documents\GitHub\spineKinematics\SpineData\Statistics'
 
 %% Read in Data
% Read in data
load('masterlist.mat')
dataDir = "C:/Users/acgis/Documents/GitHub/SpineKinematics/SpineData/ProcessedData/Epsilon/";
sacData = [];
savePlots = "N";


i = 0;
for n = 188:241
    i = 1+i;
    fname = dataDir+masterlist(n, 1);
    sacData{i} = csvread(fname+ "_sacMM.txt");
    distData{i} = (csvread(fname+"_distractionRight.txt"));
end

lab = ["2person lift","", "mperson strap","", "ltp standard", "","mperson gurney","", "logroll","", "scoop", "","mperson spineboard", "","ltp","", "vacuum"];


figure('name', 'SAC')
n = -5;
    for t = 1:2:18
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

    for t = 1:2:18
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

% t = find(technique == tech);

E = [9 8 3 7 5 4 1 6 2];

% E order: 2person lift, mperson strap, ltp standard, mperson gurney,
% logroll, scoop, mperson spineboard, ltp, vacuum,

% Done: (3) LTP Standard, (4) Scoop, (5) Log roll, (6) LTP, (7) MPerson Gurney, 
%       (8) MPerson Strap, (9) 2Person Lift
% Do Next: (1) MPerson Spinderboard, (2) Vacuum

% tech = "MPerson Strap";
% case_tech = find(technique == tech);

for case_tech = [1 2 3 4 5 6 7 8 9]
    E_tech = find(E == case_tech);


    % E_tech = find(technique == tech);


    for n = 1:6
        tmpd.dist{n} = distData{n+(6*(E_tech-1))}(5:end-5);
        tmpd.sac{n} = sacData{n+(6*(E_tech-1))}(5:end-5);
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