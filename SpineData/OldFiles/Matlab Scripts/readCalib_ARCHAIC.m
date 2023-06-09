function mat = readCalib(filename, type, stl)

    %read calibration file for coordinate system.
    % inputs:
        %   filename: file to read
        %   type:     'beads' or 'bone'

    data = load(filename);
    
    % we have Y, Z: Y' x Z  = X, X x Y' = Z
    switch type
        case 'bone'
            Yp = data(3,:);
            Z = data(2,:);

            if Yp(1) > 0
                Yp = -1*Yp;
            end
            if Z(3) < 0
                Z = -1*Z;
            end
            
            X = cross(Yp, Z);
            Z = cross(X, Yp);
            Y = Yp;
            
        case 'beads'
            LI = data(1,:);
            LS = data(2,:);
            RI = data(3,:);
            
            Y = LS - LI;
            Xp = RI - LI;
            
            % Xp x Yp = Z; Yp x Z = X
            Z = cross(Xp, Y);
            Xtemp = cross(Y, Z);

           % make CS align with Vertebrae system
            X = Z;
            Z = Y;
            Y = Xtemp;


 
    end
    
    origin = data(1,:);
    
    mat = [[(X/norm(X))';0] [(Y/norm(Y))';0] [(Z/norm(Z))';0]];
    mat(:,4) = [origin'; 1];

    
%     [F,V] = readSTL(stl);
%     bone.Faces = F;
%     bone.Vertices = V;

%     
%     figure()
%         axis('off');
%         %ax.Clipping = 'off';
%         %        view([0 +90]); % Coronal View
%         %        camroll(180); % Coronal View
%         view([90 0]); % Lateral View
%         colors = {[56,163,165]./256, [64,71,109]./265, [87, 204, 153]./265, ...
%         [172, 128, 160]./265};
%     
%         patch(bone, 'FaceColor', colors{1}, ...
%              'EdgeColor', 'none') %, ...
% %              'FaceLighting', 'gouraud', ...
% %              'BackFaceLighting', 'reverselit')
%         hold on
%         ori = origin;
%         quiver3(ori(1), ori(2), ori(3), Z(1),Z(2), Z(3), 50, 'Color', colors{1})
%         hold on
%         quiver3(ori(1), ori(2), ori(3), X(1),X(2), X(3), 50, 'Color', colors{1})
%         quiver3(ori(1), ori(2), ori(3), Y(1),Y(2), Y(3), 50, 'Color', colors{1})
%         
%         
%              %         % Add camera lights
% %          light('Position',[0 -1 0],'Style','infinite')
% %          camlight('headlight');
% %          material('dull');
    