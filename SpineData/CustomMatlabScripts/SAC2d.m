%% 2D SAC

%% take out when function-ized

function [sacMM, C] = SAC2d(bone1, bone2, pixConv, vis)

%% 2D SAC Calculations
% Plots the 2D representation of the vertebrae, finds the SAC for each
% vertebrae, and uses boolean logic to find the overlap.

% Inputs:
    % bone1, bone2: [F,V] objects for each of the two vertebrae. This must
    % be in the format for patch() (i.e., read in using readSTL).
    
    %DCM: Cell matrix containing the Direct Cosine Matrix (3x3 rotation,
    %plus the [0 0 0] translation vector) to zero the STLs.
    
    % pixConv = mm^2/pixel area conversion factor.
    
    %plot visibility - 'off' or 'on'
    
% outputs:
    % sacMM: SAC area in mm^2
    % sac: Boolean representation of SAC area.

    mesh = {bone1 bone2};
    % set the Z-coordinates to 0 to fix perspective
    mesh{1}.Vertices(:,3) = 0;
    mesh{2}.Vertices(:,3) = 0;
    
    for n = 1:2
        f1 = figure('visible', vis, 'Position', [400, 400, 500, 500]);
        
        subplot_tight(1,1,1,[0,0]);
%         axis('on')
         grid('on')
        xlim([-40, 40]);
        ylim([-40, 40]);
        axis square
        s = patch(mesh{n});

        set(gca, 'color', 'none')

        F = getframe(gca);
        RGB = frame2im(F);

        BW{n} = RGB(:,:,1);
        BW{n}(BW{n}~=0 & BW{n}~=255) = 255;
        BW{n} = imresize(BW{n}, [1024, 1024]);

        BW{n} = imcomplement(BW{n});
        %figure('visible', 'on')

        filled = imfill(BW{n}, 26);

        bin{n} = filled ~= BW{n};
        f2 = figure('visible', vis);
        imshow(bin{n})
        %close(f1)
        
        close([f1 f2])
    end

    sac = bin{1} & bin{2};
    % change colors
    map = {[0 0 0; [56,163,165]./256], [0 0 0; [64, 71, 109]./256]};
    
    map = [0 0 0; 56,163,165; 64, 71, 109; 60, 117, 137]; 
    
    colors = [250 70 22; 0 33 165]./255; 

    colors = permute(colors,[1 3 2]);
    C  = bin{1}.*colors(1,1,:) + bin{2}.*colors(2,1,:);
    
    f3 = figure('Name', 'SAC', 'visible', vis);
    imshow(C)
    sacPix = bwarea(sac);
    
    % pixConv = mm^2/pix^2
    pixConv = (80*80)/(1024*1024);
    sacMM = sacPix * pixConv;
    close(f3);
end
