% Add SPM Library
addpath 'C:\Users\acgis\Documents\MATLAB\spm8'

%% SPM 

% Reshape the data to a JxQ array
subs = 1;
data.Dist = zeros(1*9*6, 1001);

rowInd = 0;
for s = 1:subs
    for tc = 1:9
        for tr = 1:6
            rowInd = rowInd+1;
            try 
                data.Dist(rowInd,:) = dist{tc}{tr};
                data.Sac(rowInd,:) = sac{tc}{tr};
            catch
            end
        end
    end
end
%% Conduct the SPM

Technique = repmat(1:9, subs*6, 1);
Technique = (Technique(:));
Collar = repmat([0 0 0 1 1 1],1,9*subs)';

% 2 way repeated measures anova using 3 intervention levels and 2 speed
    spmDist = spm1d.stats.anova2(data.Dist,Technique,Collar);
    spmiDist  = spmDist.inference(0.05);
    
    spmSac = spm1d.stats.anova2(data.Sac,Technique,Collar);
    spmiSac  = spmSac.inference(0.05);

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
lab = ["2person lift","", "mperson strap","", "ltp standard", "","mperson gurney","", "logroll","", "scoop", "","mperson spineboard", "","ltp","", "vacuum"];

   
    figure('Position', [0, 0,900, 1100] )
    t = tiledlayout(5,2);
    
    % plot the means/Stdev of the intervention (so includes both speeds)
    nexttile([2,1])
    for n  = 1:6:height(data.Dist)-1
        spm1d.plot.plot_meanSD(data.Dist(n:n+5,:));
        hold on;
    end
        title('Intervention (Mean and SD)')
        legend(lab, 'location', 'best');
    
    % plot all 6 study conditions (i.e., combos of intervention/speed)     
    nexttile([2 1])
        hold on
        plot(mean(data.Dist(1:6,:)), 'r', 'LineWidth', 1)
        plot(mean(data.Dist(7:12,:)), '--r', 'LineWidth', 1)
        plot(mean(data.Dist(13:18,:)), 'b', 'LineWidth', 1)
        plot(mean(data.Dist(19:24,:)), '--b', 'LineWidth', 1)
        plot(mean(data.Dist(25:30,:)), 'k', 'LineWidth', 1)
        plot(mean(data.Dist(31:36,:)), '--k', 'LineWidth', 1)
        xlim([0 100]);
        
        title('All Groups')
        legend(lab(1:2:end), ...
            'location', 'best');

    nexttile([1 1]) % post hoc
%         phResults{1,2}.plot;
%         title('PostHoc: Boot v. Even Up');
        
    nexttile([1 1]) % SPM main effect (Intervention)
        spmii = spmiDist(1);
        spmii.plot();
        title("SPM: "+spmii.effect + ": Intervention");

        
    nexttile([1 1]) % post hoc
%         phResults{2,2}.plot;
%         title('PostHoc: Control v. Even Up')
%         
    nexttile([1 1]) % SPM Main Effect (Speed)
        spmii = spmiDist(2);
        spmii.plot();
        title("SPM: "+ spmii.effect + ": Collar");
        
   nexttile([1 1]) % post hoc
%         phResults{3,2,i}.plot;
%         title('PostHoc: Control v. Boot')
        
    nexttile([1 1]) % SPM Interaction Effect
        spmii = spmiDist(3);
        spmii.plot();
        title("SPM: " + spmii.effect + ": Interaction");
    
%     % title the entire plot    
%     title(t, name(i));
        
%     % save figures
%     saveas(gcf, name(i)+".jpg");
    

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