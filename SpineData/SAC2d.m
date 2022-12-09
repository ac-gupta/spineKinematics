%% 2D SAC

%% take out when function-ized

function [sacMM, sac] = SAC2d(bone1, bone2, pixConv)

%% 2D SAC Calculations
% Plots the 2D representation of the vertebrae, finds the SAC for each
% vertebrae, and uses boolean logic to find the overlap.

% Inputs:
    % bone1, bone2: [F,V] objects for each of the two vertebrae. This must
    % be in the format for patch() (i.e., read in using readSTL).
    
    % pixConv = mm^2/pixel area conversion factor.
    
% outputs:
    % sacMM: SAC area in mm^2
    % sac: Boolean representation of SAC area.

    mesh = {bone1 bone2};

    for n = 1:2
        f1 = figure('visible', 'off');
        %s = patch(mesh{n});

        %set(gca, 'color', 'none')
        axis off

        F = getframe(gca);
        RGB = frame2im(F);

        BW{n} = RGB(:,:,1);
        BW{n}(BW{n}~=0 & BW{n}~=255) = 255;
        BW{n} = imresize(BW{n}, [1024, 1024]);

        BW{n} = imcomplement(BW{n});
        %figure('visible', 'off')

        filled = imfill(BW{n});

        bin{n} = filled ~= BW{n};
        %imshow(bin{n})
        close(f1)
    end

    sac = bin{1} & bin{2};
    %figure('Name', 'SAC', 'visible', 'off')
    %imshow(sac)
    sacPix = bwarea(sac);
    sacMM = sacPix * pixConv;
    
end
