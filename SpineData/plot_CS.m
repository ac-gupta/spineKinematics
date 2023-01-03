%% test coordinate systems

%% set up fig

figure('Position',[1 0 640 640],'Visible', 'on');

     colors = {[56,163,165]./256, [64,71,109]./265, [87, 204, 153]./265, ...
         [172, 128, 160]./265};
    % colors = {'r','b','g','m'};
    
    % Fix the axes scaling, and set a nice view angle
%        axis([-75 75 -50 100 -75 75]);
       axis('off');
       axis('equal');
       ax.Clipping = 'off';
        view([0 +180]); % Coronal View
        %camroll(90); % Coronal View

%% patch bones   

         bead.C5 = readBead(beadFiles{1});
         bead.C6 = readBead(beadFiles{2});

         patch(bone.C5, 'FaceColor', colors{1}, ...
             'EdgeColor', 'none', ...
             'FaceLighting', 'gouraud', ...
             'BackFaceLighting', 'reverselit', ...
              'FaceAlpha', 0.3, ...
              'AmbientStrength', 0.9); 
          
         patch(bone.C6, 'FaceColor', colors{2}, ...
             'EdgeColor', 'none', ...
             'FaceLighting', 'gouraud', ...
             'BackFaceLighting', 'reverselit', ...
              'FaceAlpha', 0.3, ...
              'AmbientStrength', 0.9); 
         
         patch(bead.C5, 'FaceColor', colors{1}, ...
             'EdgeColor', 'none', ...
             'FaceLighting', 'gouraud', ...
             'BackFaceLighting', 'reverselit', ...
              'FaceAlpha', 0.3, ...
              'AmbientStrength', 0.9); 
          
         patch(bead.C6, 'FaceColor', colors{2}, ...
             'EdgeColor', 'none', ...
             'FaceLighting', 'gouraud', ...
             'BackFaceLighting', 'reverselit', ...
              'FaceAlpha', 0.3, ...
              'AmbientStrength', 0.9);          


%% CS Quivers         

         bones = {"C5", "C6"};

         for j = 1:2
             boneTplot = bones{j};
             m = globalTvert.(boneTplot);
             c = {"r", "b", "g"};
             for i = 1:3
                hold on
                quiver3(m(1,4),m(2,4), m(3,4),m(1,i)*20, m(2,i)*20, m(3,i)*20, 'LineWidth', 5, 'Color', c{i})
             end
             m = load("Alpha_"+boneTplot+".txt");
             Yp = m(3,:);
             Z = m(2,:);

             if Yp(1) < 0
                 Yp = -1*Yp;
             end
             if Z(3) > 0
                 Z = -1*Z;
             end

             quiver3(m(1,1), m(1,2), m(1,3), Yp(1)*20, Yp(2)*20, Yp(3)*20, 'LineWidth', 5, 'Color', 'k')
             quiver3(m(1,1), m(1,2), m(1,3), Z(1)*20, Z(2)*20, Z(3)*20, 'LineWidth', 5, 'Color', 'k')
             

             % bead cs
            m = load("Alpha_" + boneTplot + "_beads.txt");
            LI = m(1,:);
            LS = m(2,:);
            RI = m(3,:);
            
            Y = LS - LI;
            Xp = RI - LI;
            
            % Xp x Yp = Z; Yp x Z = X
            Z = cross(Xp, Y);
            X = cross(Y, Z);

            Z = Z./norm(Z);
            Y = Y./norm(Y);
            Xtemp = X./norm(X);
           

            X = Z;
            Z = Y;
            Y = Xtemp;

            quiver3(m(1,1), m(1,2), m(1,3), X(1)*10, X(2)*10, X(3)*10, 'LineWidth', 5, 'Color', c{1})
            quiver3(m(1,1), m(1,2), m(1,3), Y(1)*10, Y(2)*10, Y(3)*10, 'LineWidth', 5, 'Color', c{2})
            quiver3(m(1,1), m(1,2), m(1,3), Z(1)*10, Z(2)*10, Z(3)*10, 'LineWidth', 5, 'Color', c{3})
         end

function patchObj = readBead(file)
    [faces, vertices] = readSTL(file);
    patchObj.Faces = faces;
    patchObj.Vertices = vertices;
end