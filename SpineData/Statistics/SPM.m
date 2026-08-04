%% Epsilon SPM

 addpath 'C:\Users\acgis\Documents\MATLAB\spm8'

% load in distraction, sac, and trial order

% overall order
technique = ["MPerson SpineBoard", "Vacuum", "LTP Standard", "Scoop", "LogRoll",...
    "LTP", "MPerson Gurney", "MPerson Strap", "2Person lift"];


% Epsilon order:
% E = [9 8 3 7 5 4 1 6 2];

Alpha = load('Alpha_Norm_FE.mat');
Beta = load('Beta_Norm_FE.mat');
Epsilon = load('Epsilon_Norm_FE.mat');
Hector = load('Hector_Norm_FE.mat');
Kappa = load('Kappa_Norm_FE.mat');

%% Prepare data for SPM:

% Usable techniques for balanced design
trials = [1 2 3 4 5 7 8];
nTrials = 7;
nSubs = 5;

% collar is 0 0 0 1 1 1 (NC, C)
% Collar = repmat(repmat([0 0 0 1 1 1]', nTrials, 1), nSubs, 1);
Collar = repmat(repmat([1 1 1 0 0 0]', nTrials, 1), nSubs, 1);
Technique = repmat(trials, 6, 1);
Technique = repmat(Technique(:), nSubs, 1);

Subj = repmat(1:nSubs, nTrials*6, 1);
Subj = Subj(:);

% Alpha
for n = trials
    tmpd{n} = cell2mat(Alpha.dist{n}');
    tmps{n} = cell2mat(Alpha.sac{n}');
    tmpf{n} = cell2mat(Alpha.kin{n}');
end

% Add mean of trials 1-5 to create artifical 6th trial for tehcniques 3, 5
tmpd{3}(6,:) = mean(tmpd{3});
tmps{3}(6,:) = mean(tmps{3});

tmpd{5}(6,:) = mean(tmpd{5});
tmps{5}(6,:) = mean(tmps{5});

    
DistMat.Alpha = cell2mat(tmpd');
SacMat.Alpha = cell2mat(tmps');

%     Collar.Alpha = repmat([0 0 0 1 1 1]', 8, 1);
%     Technique.Alpha = repmat(trials', 6, 1);
%     Subj.Alpha = zeros(height(DistMat.Alpha),1);

    tmpd = []; tmps = [];
    
% beta 
for n = trials
    tmpd{n} = cell2mat(Beta.dist{n}');
    tmps{n} = cell2mat(Beta.sac{n}');
    
    DistMat.Beta = cell2mat(tmpd');
    SacMat.Beta = cell2mat(tmps');
end
%     Collar.Beta = repmat([0 0 0 1 1 1]', 9, 1);
%     Technique.Beta = repmat(trials', 6, 1);
%     Subj.Beta = ones(height(DistMat.Beta),1) .*2 ;
    tmpd = []; tmps = [];
    
% epsilon
for n = trials
    tmpd{n} = cell2mat(Epsilon.distMaster{n}');
    tmps{n} = cell2mat(Epsilon.sacMaster{n}');
    
    DistMat.Epsilon = cell2mat(tmpd');
    SacMat.Epsilon = cell2mat(tmps');
end
%     Collar.Epsilon = repmat([0 0 0 1 1 1]', 9, 1);
%     Technique.Epsilon = repmat(trials', 6, 1);
%     Subj.Epsilon = ones(height(DistMat.Epsilon),1) .*2 ;
    tmpd = []; tmps = [];
    
% hector
for n = trials
    tmpd{n} = cell2mat(Hector.dist{n}');
    tmps{n} = cell2mat(Hector.sac{n}');
    
    DistMat.Hector = cell2mat(tmpd');
    SacMat.Hector = cell2mat(tmps');
end
%     Collar.Hector = repmat([0 0 0 1 1 1]', 8, 1);
%     Technique.Hector = repmat(trials', 6, 1);
%     Subj.Hector = ones(height(DistMat.Hector),1);
    tmpd = []; tmps = [];
    
% kappa    
for n = trials
    tmpd{n} = cell2mat(Kappa.dist{n}');
    tmps{n} = cell2mat(Kappa.sac{n}');
    
    DistMat.Kappa = cell2mat(tmpd');
    SacMat.Kappa = cell2mat(tmps');
end
%     Collar.Hector = repmat([0 0 0 1 1 1]', 8, 1);
%     Technique.Hector = repmat(trials', 6, 1);
%     Subj.Hector = ones(height(DistMat.Hector),1);
    tmpd = []; tmps = [];
    
MasterDist = [DistMat.Alpha; DistMat.Beta; DistMat.Epsilon; DistMat.Hector; DistMat.Kappa];
MasterSAC = [SacMat.Alpha; SacMat.Beta; SacMat.Epsilon; SacMat.Hector; SacMat.Kappa];

% C = [Collar.Alpha;Collar.Epsilon;Collar.Hector];
% S = [Subj.Alpha; Subj.Epsilon; Subj.Hector];
% T = [Technique.Alpha;Technique.Epsilon;Technique.Hector];

%% Do SAC SPM
% spm = spm1d.stats.anova2rm(MasterDist, Collar, Technique, Subj);
% spmi{1} = spm.inference(0.05);
% 
% spm = spm1d.stats.anova2rm(MasterSAC, Collar, Technique, Subj);
% spmi{2} = spm.inference(0.05);
% 
spm = spm1d.stats.nonparam.anova2rm(MasterDist, Collar, Technique, Subj);
spmi{1} = spm.inference(0.05, 'iterations',1000);

spm = spm1d.stats.nonparam.anova2rm(MasterSAC,Collar, Technique, Subj);
spmi{2} = spm.inference(0.05, 'iterations',1000);

%% Scalar ANOVA
% %% Anova
% [~, ~, stats] = anovan(DistMean, {Technique, Collar}, 'model', 'interaction', 'varnames', {'Technique', 'Collar'});
% figure('Name', 'Dist')
% [results, ~, ~, gnames] = multcompare(stats);
% 
% [~, ~, stats] = anovan(SacMean, {Technique, Collar}, 'model', 'interaction', 'varnames', {'Technique', 'Collar'});
% figure('Name', 'Sac')
% [results, ~, ~, gnames] = multcompare(stats);
%% 
% %% Conduct Posthoc Testing
% % Posthocs to determine the intervention group mean significances were done
% % with two tailed t-tests and a Bonferroni correction (so alpha = 0.05/3). 
% 
% for i = 1:48
%     
%     % name the rows of the cell matrix to make it easier to look at
%     phResults{1,1,i} = "EvenUp v. Boot";
%     phResults{2,1,i} = "EvenUp v. Control";
%     phResults{3,1,i} = "Boot v. Control";
% 
%     % concatenate the data for both speeds based on intervention
%     evenUp{i} = ([data(1:6:end,:,(i+1)); data(2:6:end,:,(i+1))]);
%     boot{i} = ([data(3:6:end,:,(i+1)); data(4:6:end,:,(i+1))]);
%     control{i} = ([data(5:6:end,:,(i+1)); data(6:6:end,:,(i+1))]);
%     
%     % bonferroni correction
%     alpha = 0.05/3; 
%     
%     % perform the posthoc testing
%     [phResults{1,2,i}, phResults{1,3,i}] = posthoc(evenUp{i}, boot{i}, alpha);
%     [phResults{2,2,i}, phResults{2,3,i}] = posthoc(evenUp{i}, control{i}, alpha);
%     [phResults{3,2,i}, phResults{3,3,i}] = posthoc(boot{i}, control{i}, alpha); 
%    
% end

%% Plotting

    figure()
    sgtitle("SAC SPM")

    % number of plots
    n = 5;

    subplot(n,1,[1 2])
    hold on
    for t = 0:8
        plot(0:0.1:100, mean(MasterSAC(1+(t*6):6+(t*6),:)));
    end
%     
%     legend( technique(E), 'location', 'southoutside', 'orientation', 'horizontal','box', 'off');
%     legend("", "Control Slow", "", "Control Normal","", "Control Fast","", "Harness Slow", "","Harness Normal","", "Harness Fast", 'location', 'best');
    xlabel({""; ""});
    xtickformat('percentage');
    ylabel("SAC (mm^2)");


    subplot(n,1,3)
    spmii = spmi{2}(1);
    spmii.plot();
    title(spmii.effect + ": Collar");

    subplot(n,1,4)
    spmii = spmi{2}(2);
    spmii.plot();
    title(spmii.effect + ": Techniqe");

    if n == 5
        subplot(n,1,n)
        spmii = spmi{2}(3);
        spmii.plot();
        title(spmii.effect);
    end
    %% 
    figure()
    sgtitle("Distraction SPM")

    % number of plots
    n = 5;

    subplot(n,1,[1 2])
    hold on
    for t = 0:8
        plot(0:0.1:100, mean(MasterDist(1+(t*6):6+(t*6),:)));
    end
%     
%     legend( technique(E), 'location', 'southoutside', 'orientation', 'horizontal','box', 'off');
%     legend("", "Control Slow", "", "Control Normal","", "Control Fast","", "Harness Slow", "","Harness Normal","", "Harness Fast", 'location', 'best');
    xlabel({"";""});
    xtickformat('percentage');
    ylabel("Distraction (mm)");


    subplot(n,1,3)
    spmii = spmi{1}(1);
    spmii.plot();
    title(spmii.effect + ": Collar");

    subplot(n,1,4)
    spmii = spmi{1}(2);
    spmii.plot();
    title(spmii.effect + ": Techniqe");

    if n == 5
        subplot(n,1,n)
        spmii = spmi{1}(3);
        spmii.plot();
        title(spmii.effect);
    end
%% Collar vs. no collar:
figure()
sgtitle("Collar Condition")

logInd = logical(repmat([1 1 1 0 0 0], 1, 9)');

    % number of plots
    n = 6;

    subplot(n,1,[1 2])
    hold on
    plot(0:0.1:100, mean(MasterDist(logInd, :)));
    plot(0:0.1:100, mean(MasterDist(~logInd, :)));
%     
    legend("No Collar", "Collar");
%     legend("", "Control Slow", "", "Control Normal","", "Control Fast","", "Harness Slow", "","Harness Normal","", "Harness Fast", 'location', 'best');
    xlabel({"";""});
    xtickformat('percentage');
    ylabel("Distraction (mm)");

    subplot(n,1,3)
    spmii = spmi{1}(1);
    spmii.plot();
    title(spmii.effect + ": Collar (Distraction)");
    
    subplot(n,1,[4 5])
    hold on
    plot(0:0.1:100, mean(MasterSAC(logInd, :)));
    plot(0:0.1:100, mean(MasterSAC(~logInd, :)));
%     
    legend("No Collar", "Collar");
%     legend("", "Control Slow", "", "Control Normal","", "Control Fast","", "Harness Slow", "","Harness Normal","", "Harness Fast", 'location', 'best');
    xlabel({"";""});
    xtickformat('percentage');
    ylabel("SAC (mm^2)");

    subplot(n,1,6)
    spmii = spmi{2}(1);
    spmii.plot();
    title(spmii.effect + ": Collar (SAC)");

%% posthocs
for i = 1:nTrials
    techDist{i} = MasterDist(1+(i*6):6+(i*6),:);
    techSac{i} = MasterSAC(1+(i*6):6+(i*6),:);
end
labels = technique(nchoosek(trials,2)); % labels
posthocCombs = nchoosek(1:nTrials, 2);
    
    % bonferroni correction
    alpha = 0.05/nTrials; 
    
for i = 1:length(posthocCombs)
    phResults.dist{i,1} = join(labels(i,:), ' vs ');
    [phResults.dist{i,2}, phResults.dist{i,3}] = posthoc(techDist{posthocCombs(i,1)}, techDist{posthocCombs(i,2)},alpha);
    
    phResults.sac{i,1} = join(labels(i,:), ' vs ');
    [phResults.sac{i,2}, phResults.sac{i,3}] = posthoc(techSac{posthocCombs(i,1)}, techSac{posthocCombs(i,2)},alpha);
end

%% fast plot

for i = 1:length(phResults.dist)
        figure('Name', phResults.dist{i,1});
        t = tiledlayout(2,1);
        
        nexttile([1 1])
        phResults.dist{i,2}.plot;
        title(phResults.dist{i,1});
        
        nexttile([1 1])
        plot(mean(techDist{posthocCombs(i,1)}))
        hold on
        plot(mean(techDist{posthocCombs(i,2)}));
        xlim([0 1001]);
        
        ylabel('Distraction (mm)')
        legend(labels(i,1), labels(i,2));
        
        saveas(gcf, phResults.dist{i,1} + " distraction.jpg")
end


for i = 1:length(phResults.sac)
        figure('Name', phResults.sac{i,1});
        t = tiledlayout(2,1);
        
        nexttile([1 1])
        phResults.sac{i,2}.plot;
        title(phResults.sac{i,1});
        
        nexttile([1 1])
        plot(mean(techSac{posthocCombs(i,1)}))
        hold on
        plot(mean(techSac{posthocCombs(i,2)}));
        xlim([0 1001]);
        
        ylabel('SAC (mm^2)')
        legend(labels(i,1), labels(i,2));
        
        saveas(gcf, phResults.sac{i,1} + " SAC.jpg")
end
%% Posthocs: from cam boot

for i = 1:length(phResults)
    
    figure('Position', [0, 0,900, 1100] )
    t = tiledlayout(5,2);
    
    % plot the means/Stdev of the intervention (so includes both speeds)
    nexttile([2,1])
        spm1d.plot.plot_meanSD(evenUp{i}, 'color', 'r');
        hold on;
        spm1d.plot.plot_meanSD(boot{i}, 'color', 'b');
        spm1d.plot.plot_meanSD(control{i}, 'color', 'k');
        title('Intervention (Mean and SD)')
        legend('Even Up',"", 'Boot', "", 'Control', "", 'location', 'best');
    
    % plot all 6 study conditions (i.e., combos of intervention/speed)     
    nexttile([2 1])
        hold on
        plot(mean(data(1:6:end,:,i+1)), 'r', 'LineWidth', 1)
        plot(mean(data(2:6:end,:,i+1)), '--r', 'LineWidth', 1)
        plot(mean(data(3:6:end,:,i+1)), 'b', 'LineWidth', 1)
        plot(mean(data(4:6:end,:,i+1)), '--b', 'LineWidth', 1)
        plot(mean(data(5:6:end,:,i+1)), 'k', 'LineWidth', 1)
        plot(mean(data(6:6:end,:,i+1)), '--k', 'LineWidth', 1)
        xlim([0 100]);
        
        title('All Groups')
        legend("Evenup Slow", "Evenup Fast", "Boot Slow", "Boot Fast", "Control Slow", "Control Fast", ...
            'location', 'best');

    nexttile([1 1]) % post hoc
        phResults{1,2,i}.plot;
        title('PostHoc: Boot v. Even Up');
        
    nexttile([1 1]) % SPM main effect (Intervention)
        spmii = spmi{i}(1);
        spmii.plot();
        title("SPM: "+spmii.effect + ": Intervention");

        
    nexttile([1 1]) % post hoc
        phResults{2,2,i}.plot;
        title('PostHoc: Control v. Even Up')
        
    nexttile([1 1]) % SPM Main Effect (Speed)
        spmii = spmi{i}(2);
        spmii.plot();
        title("SPM: "+ spmii.effect + ": Speed");
        
   nexttile([1 1]) % post hoc
        phResults{3,2,i}.plot;
        title('PostHoc: Control v. Boot')
        
    nexttile([1 1]) % SPM Interaction Effect
        spmii = spmi{i}(3);
        spmii.plot();
        title("SPM: " + spmii.effect + ": Interaction");
    
    % title the entire plot    
    title(t, name(i));
        
    % save figures
    saveas(gcf, name(i)+".jpg");
    
end

%% Posthoc function

function [spmiPost, sigRange] = posthoc(YA, YB, alpha)
% inputs: YA, YB: arrays of observations of two groups
%         alpha: alpha value to test
% outputs: spmiPost: posthoc spmi type object
%          sigRange: range (in % gait cycle) between which groups   
%                    differ in a statistically significant way

    % run the ttest posthoc testing
    spmPost = spm1d.stats.ttest_paired(YA, YB);
    spmiPost = spmPost.inference(alpha, 'two_tailed', true);
    
    % check if null hypothesis can be rejected
    sigVec = abs(spmiPost.z) > abs(spmiPost.zstar);

    % if it can be, find where there is significance
    if not(sum(sigVec) == 0)
        sigRange(:,1) = strfind([0 sigVec], [0 1]);
        sigRange(:,2) = strfind([sigVec 0], [1 0]);
    else
        sigRange = [];
    end

end