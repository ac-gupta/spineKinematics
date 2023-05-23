%% 2D SAC

%% take out when function-ized

function [sacMM, sac] = SAC2d(bone1, bone2, pixConv, plot)

%% 2D SAC Calculations
% Plots the 2D representation of the vertebrae, finds the SAC for each
% vertebrae, and uses boolean logic to find the overlap.

% Inputs:
    % bone1, bone2: [F,V] objects for each of the two vertebrae. This must
    % be in the format for patch() (i.e., read in using readSTL).
    
    % pixConv = mm^2/pixel area conversion factor.
    
    %plot = 0 or 1, representing if figures should be visible or not
    
% outputs:
    % sacMM: SAC area in mm^2
    % sac: Boolean representation of SAC area.

    mesh = {bone1 bone2};

        f1 = figure('visible', 'off');
        s = patch(bone1);
        s2 = patch(bone2);

        set(gca, 'color', 'none')
        axis off

        F = getframe(gca);
        RGB = frame2im(F);

        BW = RGB(:,:,1);
        BW(BW~=0 & BW~=255) = 255;
        BW = imresize(BW, [1024, 1024]);

        BW = imcomplement(BW);
        f2 = figure('visible', 'off')

        filled = imfill(BW);

        bin = filled ~= BW;
        imshow(bin)
        %close(f1)
    

    sac = bin{1} & bin{2};
    f3 = figure('Name', 'SAC', 'visible', 'off');
    imshow(sac)
    sacPix = bwarea(sac);
    sacMM = sacPix * pixConv;
    
end
