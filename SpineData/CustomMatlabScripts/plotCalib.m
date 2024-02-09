function plotCalib(mats, stls)
    % plot the coordinate systems for the beads and bones
    % inputs: mats (stack of 4x4 mats in order bone1, bone2, bead1, bead2)
    %         stls (stack of stls, bone1, bone2, bead1, bead2, polhemus 1, polhemus 2)
    title = ["C5", "C6", "C5beads", "C6beads"];
        figure()
        axis('off');
        axis('equal');
        %ax.Clipping = 'off';
        %        view([0 +90]); % Coronal View
        %        camroll(180); % Coronal View
        view([90 0]); % Lateral View
     colors = {[250 70 22]./256, [0 33 165]./265, [250 70 22]./256, [0 33 165]./265};
    

    for n = 1:4
        [F,V] = readSTL(stls{n});
        X = mats{n}(1:3,1);
        Y = mats{n}(1:3,2);
        Z = mats{n}(1:3,3);

        origin = mats{n}(1:3, 4);
        
        obj.(title(n)).Faces = F;
        obj.(title(n)).Vertices = V;

    
    
        patch(obj.(title(n)), 'FaceColor', colors{n}, ...
             'EdgeColor', 'none', 'FaceAlpha', 0.2) %, ...
%              'FaceLighting', 'gouraud', ...
%              'BackFaceLighting', 'reverselit')
        hold on
        ori = origin;
        quiver3(ori(1), ori(2), ori(3), X(1),X(2), X(3), 50, ':','Color', colors{n})
        hold on
        quiver3(ori(1), ori(2), ori(3), Y(1),Y(2), Y(3),50, '-', 'Color', colors{n})
        quiver3(ori(1), ori(2), ori(3), Z(1),Z(2), Z(3),50, '--', 'Color', colors{n})

        if n == 1
            legend("", "X", "Y", "Z");
        end
        
        
    end
    %                    % Add camera lights
          light('Position',[0 -1 0],'Style','infinite')
          camlight('headlight');
          material('dull');
end
        