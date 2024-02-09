function [normDist, normSac] = normData(tech, tmpd)
% Time-normalize distraction and SAC data for a given technique. 

% Inputs:
%           tech: 1-9 value indicating which technique was used.
%           tmpd: Structure with fields dist and sac, both 6x1 cell arrays
%                 with Nx1 data points. Each cell should hold one trial.
% Outputs:
%           normDist: 6x1 cell array with each cell holding a 1001 x 1
%                     vector of normalized distracion data. 
%           normSac:  6x1 cell array with each cell holding a 1001 x 1
%                     vector of normalized SAC data.
%           figure:   Plots the normalized and original data.



    warning ('off','all');
    t = 0:0.1:100;
    switch tech
        
        %% MPerson Spineboard 
        case 1 
            tech  = "MPerson SpineBoard";
            for n = 1:6
                dist{n} = smooth(tmpd.dist{n}, 80);
                dDist{n} = diff(dist{n});
                [~, minInd(1)] = min(dDist{n});

                [~, minInd(2)] = min(dist{n});
                
                % start at second minimum
                tmpDist{1} = tmpd.dist{n}(1:minInd(1));
                tmpDist{2} = tmpd.dist{n}(minInd(1)+1:minInd(2));
                tmpSac{1} = tmpd.sac{n}(1:minInd(1));
                tmpSac{2} = tmpd.sac{n}(minInd(1)+1:minInd(2));


                tmpDist{3} = interp1(1:numel(tmpDist{1}), tmpDist{1}, linspace(1, numel(tmpDist{1}), 951));
                tmpDist{4} = interp1(1:numel(tmpDist{2}), tmpDist{2}, linspace(1,numel(tmpDist{2}), 50));

                tmpSac{3}= interp1(1:numel(tmpSac{1}), tmpSac{1}, linspace(1, numel(tmpSac{1}), 951));
                tmpSac{4} = interp1(1:numel(tmpSac{2}), tmpSac{2}, linspace(1,numel(tmpSac{2}), 50));

                normDist{n} = [tmpDist{3} tmpDist{4}];
                normSac{n} = [tmpSac{3} tmpSac{4}];
            end

            plotNorm(normSac, normDist, t, tmpd.sac,tmpd.dist, tech, 1:6) 
        %% LTP Standard
        case 3
            
            tech = "LTP Standard";
            
            for n = 1:6
                dist{n} = smooth(tmpd.dist{n}, 80);
                dDist{n} = diff(dist{n});
                [~, maxInd] = max(dDist{n});
                [~, idx] = sort(dDist{n}(25:maxInd));

                mn = mean(dist{n});
                mnIdx = find(dist{n} < mean(dist{n}));
                mnIdx = mnIdx(end);

                % start at second minimum
                tmpDist{1} = tmpd.dist{n}(idx(1):mnIdx);
                tmpDist{2} = tmpd.dist{n}(mnIdx+1:end);
                tmpSac{1} = tmpd.sac{n}(idx(1):mnIdx);
                tmpSac{2} = tmpd.sac{n}(mnIdx+1:end);


                tmpDist{3} = interp1(1:numel(tmpDist{1}), tmpDist{1}, linspace(1, numel(tmpDist{1}), 501));
                tmpDist{4} = interp1(1:numel(tmpDist{2}), tmpDist{2}, linspace(1,numel(tmpDist{2}), 500));

                tmpSac{3}= interp1(1:numel(tmpSac{1}), tmpSac{1}, linspace(1, numel(tmpSac{1}), 501));
                tmpSac{4} = interp1(1:numel(tmpSac{2}), tmpSac{2}, linspace(1,numel(tmpSac{2}), 500));

                normDist{n} = [tmpDist{3} tmpDist{4}];
                normSac{n} = [tmpSac{3} tmpSac{4}];
            end

            plotNorm(normSac, normDist, t, tmpd.sac,tmpd.dist, tech, 1:6)
            
        %% Scoop
        case 4
            % find where the dist hits it's mean, 60% before that and 40%
            % after
            tech = "Scoop";
           for n = 1:6 
                mnIdx = find(tmpd.dist{n} >= mean(tmpd.dist{n}));
                mnIdx = mnIdx(end);

                dt = smooth(diff(smooth(tmpd.dist{n},80)),100);
                dt(1:10) = NaN; 
                dt(end-10:end) =  NaN;

                idx = find(abs(dt) >= 0.00075);
                idx = idx(1);

                % 
                endIdx = (mnIdx - idx)/.6 + idx;

                if endIdx > length(tmpd.dist{n})
                    endIdx = length(tmpd.dist{n});
                end

                tmpDist{1} = tmpd.dist{n}(idx:mnIdx);
                tmpDist{2} = tmpd.dist{n}(mnIdx+1:endIdx);
                tmpSac{1} = tmpd.sac{n}(idx:mnIdx);
                tmpSac{2} = tmpd.sac{n}(mnIdx+1:endIdx);


                tmpDist{3} = interp1(1:numel(tmpDist{1}), tmpDist{1}, linspace(1, numel(tmpDist{1}), 601));
                tmpDist{4} = interp1(1:numel(tmpDist{2}), tmpDist{2}, linspace(1,numel(tmpDist{2}), 400));

                tmpSac{3}= interp1(1:numel(tmpSac{1}), tmpSac{1}, linspace(1, numel(tmpSac{1}), 601));
                tmpSac{4} = interp1(1:numel(tmpSac{2}), tmpSac{2}, linspace(1,numel(tmpSac{2}), 400));
                
                normSac{n} = [tmpSac{3} tmpSac{4}];
                normDist{n} = [tmpDist{3} tmpDist{4}];
           end 
            
            plotNorm(normSac, normDist, t, tmpd.sac, tmpd.dist, tech, 1:6);       
    
        %% Logroll
        case 5
            
            tech = "Log Roll";
            for n = 1:6
                dt = smooth(diff(tmpd.dist{n}),80);
                [~,extrema(1)] = max(dt(25:end/2));
                
                [~, extrema(2)] = min(dt(25:extrema(1)+25));
                [~, extrema(3)] = min(dt(end/2:end));
                [~, extrema(4)] = max(dt(extrema(3)+end/2:end));
                
                extrema(4) = extrema(4) + extrema(3);
                extrema(3:4) = extrema(3:4) + length(dt)/2;
                
                % reshape so that the middle 90% is between 2 and 4
%                 extrema = extrema - extrema(2);

                % portion 1: 5%
                tmpDist{1} = tmpd.dist{n}(extrema(2):extrema(1));
                tmpDist{2} = tmpd.dist{n}(extrema(1):extrema(3));
                tmpDist{3} = tmpd.dist{n}(extrema(3):extrema(4));

                tmpSac{1} = tmpd.sac{n}(extrema(2):extrema(1));
                tmpSac{2} = tmpd.sac{n}(extrema(1):extrema(3));
                tmpSac{3} = tmpd.sac{n}(extrema(3):extrema(4));  
                
                % set the percents for normalization to be 10% 80% 10%;
                f = [100 801 100];
                for p = 1:3
                    tmpDist{p} = interp1(1:numel(tmpDist{p}), tmpDist{p}, linspace(1, numel(tmpDist{p}), f(p)));
                    tmpSac{p}= interp1(1:numel(tmpSac{p}), tmpSac{p}, linspace(1, numel(tmpSac{p}), f(p)));
                end             
                
                normSac{n} = [tmpSac{1} tmpSac{2} tmpSac{3}];
                normDist{n} = [tmpDist{1} tmpDist{2} tmpDist{3}];
            end
            
            plotNorm(normSac, normDist, t, tmpd.sac,tmpd.dist, tech, 1:6)

        %% LTP
        case 6
            
            tech = "LTP";
                                    
            for n = 1:6
                dist{n} = smooth(tmpd.dist{n}, 80);
                dDist{n} = diff(dist{n});
                [~, maxInd] = max(dDist{n});
                [~, idx] = sort(dDist{n}(25:maxInd));

                mn = mean(dist{n});
                mnIdx = find(dist{n} < mean(dist{n}));
                mnIdx = mnIdx(end);

                % start at second minimum
                tmpDist{1} = tmpd.dist{n}(idx(1):mnIdx);
                tmpDist{2} = tmpd.dist{n}(mnIdx+1:end);
                tmpSac{1} = tmpd.sac{n}(idx(1):mnIdx);
                tmpSac{2} = tmpd.sac{n}(mnIdx+1:end);


                tmpDist{3} = interp1(1:numel(tmpDist{1}), tmpDist{1}, linspace(1, numel(tmpDist{1}), 501));
                tmpDist{4} = interp1(1:numel(tmpDist{2}), tmpDist{2}, linspace(1,numel(tmpDist{2}), 500));

                tmpSac{3}= interp1(1:numel(tmpSac{1}), tmpSac{1}, linspace(1, numel(tmpSac{1}), 501));
                tmpSac{4} = interp1(1:numel(tmpSac{2}), tmpSac{2}, linspace(1,numel(tmpSac{2}), 500));

                normDist{n} = [tmpDist{3} tmpDist{4}];
                normSac{n} = [tmpSac{3} tmpSac{4}];
            end

            plotNorm(normSac, normDist, t, tmpd.sac,tmpd.dist, tech, 1:6)  
        %% MPerson Gurney
        case 7
            tech  = "MPerson Gurney";
            for n = 1:6
                sac =smooth(tmpd.sac{n});
                
                % Match up the bottom peak
                [~, mnIdx] = min(sac(end*.66:end*.95));
                mnIdx = mnIdx + round(length(sac)*.66);
                
                % find middle of the downfall
                fallIdx = find(tmpd.dist{n} <= range(tmpd.dist{n})/2 + min(tmpd.dist{n}));
                fallIdx = fallIdx(1);
                %
                startIdx = find(sac <= mean(tmpd.sac{n}(1:length(tmpd.sac{n})*.10)));
                idx = startIdx(1);
                
                % find ending idx
                endIdx = find(abs(smooth(diff(smooth(tmpd.dist{n}(fallIdx:end),80)),80)) <= 0.005);
                endIdx = endIdx(end)+fallIdx;
                
                % split so min peak is at 90%
                tmpDist{1} = tmpd.dist{n}(idx(1):fallIdx);
                tmpDist{2} = tmpd.dist{n}(mnIdx+1:endIdx);
                tmpSac{1} = tmpd.sac{n}(idx(1):fallIdx);
                tmpSac{2} = tmpd.sac{n}(mnIdx+1:endIdx);


                tmpDist{3} = interp1(1:numel(tmpDist{1}), tmpDist{1}, linspace(1, numel(tmpDist{1}), 801));
                tmpDist{4} = interp1(1:numel(tmpDist{2}), tmpDist{2}, linspace(1,numel(tmpDist{2}), 200));

                tmpSac{3}= interp1(1:numel(tmpSac{1}), tmpSac{1}, linspace(1, numel(tmpSac{1}), 801));
                tmpSac{4} = interp1(1:numel(tmpSac{2}), tmpSac{2}, linspace(1,numel(tmpSac{2}), 200));

                normDist{n} = [tmpDist{3} tmpDist{4}];
                normSac{n} = [tmpSac{3} tmpSac{4}];
            end
            
            plotNorm(normSac, normDist, t, tmpd.sac,tmpd.dist, tech, 1:6)

        %% MPerson Strap 
        case 8
            tech = "MPerson Strap";
            for n = 1:6
                dist{n} = smooth(tmpd.dist{n}, 80);
                dDist{n} = diff(dist{n});

            [~, i] = min(dDist{n}(25:end/2));

                tmpDist = tmpd.dist{n}(i:end);
                tmpSac = tmpd.sac{n}(i:end);
                normDist{n} = interp1(1:numel(tmpDist), tmpDist, linspace(1, numel(tmpDist), 1001));
                normSac{n} = interp1(1:numel(tmpSac),tmpSac, linspace(1,numel(tmpSac), 1001));
            end
            
            plotNorm(normSac, normDist, t, tmpd.sac, tmpd.dist, tech, 1:6)

        %% 2 Person Lift   
        case 9
            tech = "2Person Lift";
            
            for n = 1:6
                dT = smooth(diff(smooth(tmpd.sac{n},80)),100);
                inds = find(abs(dT) >=  mean(dT + .25));
                tmpSac = tmpd.sac{n}(inds(1):inds(end));
                tmpDist = tmpd.dist{n}(inds(1):inds(end));
                
                normDist{n} = interp1(1:numel(tmpDist), tmpDist, linspace(1,numel(tmpDist), 1001));
                normSac{n} = interp1(1:numel(tmpSac), tmpSac, linspace(1,numel(tmpSac), 1001));
            end 
                plotNorm(normSac, normDist, t, tmpd.sac, tmpd.dist, tech, 1:6)

    end 
        
end

%% Helper Functions

% Plot

function plotNorm(nSac, nDist, t, rawSac, rawDist, tech, N)

            figure('Position', [0 0 1000 1000])
            for n = N              
                if n < 4
                    c = "r";
                else
                    c = "b";
                end
                
                subplot(2,2,1)
                hold on
                plot((1:length(rawDist{n}))/100, rawDist{n}, c)
                subplot(2,2,3)
                hold on
                plot(t, nDist{n}, c);
                
                subplot(2,2,2)
                hold on
                plot((1:length(rawSac{n}))/100,rawSac{n}, c)
                subplot(2,2,4)
                hold on
                plot(t, nSac{n}, c);
            end
            
            subplot(2,2,1)
                title(tech + " Dist")
                xlabel("Time (s)")
            subplot(2,2,2)
                title(tech + " SAC")
                xlabel("Time (s)")
            subplot(2,2,3)
                title("Normalized " + tech + " Dist")
                xlabel("% Cycle");
            subplot(2,2,4)
                title("Normalized " + tech + " SAC")
                legend("Collar", "", "", "No Collar", "", "", 'Location', 'best', ...
                    'Orientation', 'horizontal');
                
%             saveas(gcf, tech+"_normalized.jpg");
end


