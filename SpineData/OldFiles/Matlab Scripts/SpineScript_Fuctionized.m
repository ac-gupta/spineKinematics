function [distraction, sacMM, bone] = spineProcessing(alignmentPath, posePath, boneFiles, beadFiles, polhemusFiles)

% Load in constant matrices, etc.

load("polhemusTbeadV2.mat");

% pixel conversion from dicom file
pixConv = 0.0285*0.0285;

%set verts to iterate through stuct field names
verts = {'C5', 'C6'};

% load in mocap data: 
pose = ReadMocap_v2(posePath);
alignMat = readAlignment(alignmentPath);


%%  Set up figure/mesh
f = figure('Position',[1 0 640 640],'Visible', 'off', 'HandleVisibility', 'on');
frame = 1;
%% load matrices

for n = 1:2
    % load in bead to global and bone to global
    beadTglobal.(verts{n}) = readCalib(beadFiles{n+2}, 'beads', beadFiles{n});
    vertTglobal.(verts{n}) = readCalib(boneFiles{n+2}, 'bone', boneFiles{n});

    vertTglobal.(verts{n}) = vertTglobal.(verts{n});
    % create bead to bone matrix
      boneTbead.(verts{n}) = inv(beadTglobal.(verts{n})) * (vertTglobal.(verts{n}));
end

% plot the coordinate systems as a double check
stls = {boneFiles{1}; boneFiles{2}; beadFiles{1}; beadFiles{2}};
mats = {vertTglobal.C5, vertTglobal.C6, beadTglobal.C5, beadTglobal.C6};
plotCalib(mats, stls);

%% Create Meshes

[faces,vertices] = readSTL(boneFiles{1});
bone.C5.Faces = faces;
bone.C5.Vertices = vertices;

C5_temp.Faces = faces;
C5verts  = [vertices.'; ones(1,length(vertices.'))];

[faces,vertices] = readSTL(boneFiles{2});
bone.C6.Faces = faces;
bone.C6.Vertices = vertices;

C6_temp.Faces = faces;

C6verts  = [vertices.'; ones(1,length(vertices.'))];

%% Rotate both meshes to be orthogonal

    C5verts = inv(vertTglobal.C5) * C5verts;
    bone.C5.Vertices = C5verts(1:3, :)';
    
    C6verts = inv(vertTglobal.C6) * C6verts;
    bone.C6.Vertices = C6verts(1:3,:)';
    
%% set up loop

N = length(pose.C5);
results = zeros(length(pose), 6);

 N = 5;
try
    for idx = 1:N

        % shows progress
        if mod(idx, 10) == 0
            fprintf('\nframe %d/%d', idx, N) 
        end

        C5PoltoGlobal = pose.C5{idx};
        C6PoltoGlobal = pose.C6{idx};

        C5beadtoGlobal = C5PoltoGlobal * (polTbead.C5);
        C6beadtoGlobal = C6PoltoGlobal * (polTbead.C6);

        C5toGlobal = C5beadtoGlobal * boneTbead.C5;
        C6toGlobal = C6beadtoGlobal * boneTbead.C6;

        C5toC6 = inv(C5toGlobal) * C6toGlobal;    

        %% Everything

        % change the actual vertices of the mesh
        C5_temp_verts = inv(C5toC6) * C5verts;    
        C5_temp.Vertices = C5_temp_verts(1:3, :)';

        % 2D SAC Calculations
        if mod(idx, 10) == 1
            if idx == 1 || idx == N
                % Show figures for the first and last iteration
                [sacMM{frame}, sac{frame}] = SAC2d(bone.C6, C5_temp, pixConv, 1);
            else
                [sacMM{frame}, sac{frame}] = SAC2d(bone.C6, C5_temp, pixConv, 0);
            end
            [sacMM{frame}, sac{frame}] = SAC2d(bone.C6, C5_temp, pixConv, 0);
        end

    %% plot

         set(0, 'currentfigure', f);  %# for figures

         colors = {[250 70 22]./256, [0 33 165]./265};

        C6toC5{idx} = inv(C5toC6);
        % Calculate result Euler angles and AzElRo
        results(idx, 1:3) = (C6toC5{idx}(1:3, 4)).';
        results(idx, 4:6) = getRotations(123, C6toC5{idx});
        
        [C5Inf, C5Sup] = findMinimums(bone.C5, 1);
        [C6Inf, C6Sup] = findMinimums(bone.C6, 1);
        
        distraction = results(:,3) + C5Inf - C6Sup;

       % Fix the axes scaling, and set a nice view angle
       axis('off')
         subplot_tight(2,1,1,[])
           axis('off');
           grid('off');
           axis('equal');
           ax.Clipping = 'off';
            view([90 0]); % Frontal View

             patch(bone.C6, 'FaceColor', colors{2}, ...
                 'EdgeColor', 'none', ...
                 'FaceLighting', 'gouraud', ...
                 'BackFaceLighting', 'reverselit', ...
                  'FaceAlpha', 0.8, ...
                  'AmbientStrength', 0.9); 

             patch(C5_temp, 'FaceColor', colors{1}, ...
                 'EdgeColor', 'none', ...
                 'FaceLighting', 'gouraud', ...
                 'BackFaceLighting', 'reverselit',...
                  'FaceAlpha', 0.8, ...
                  'AmbientStrength', 0.9); 

             %          Add camera lights
             light('Position',[0 -1 0],'Style','infinite')
             camlight('headlight');
             material('dull');


            subplot_tight(2,2,3,[])
               axis('off');
               axis('equal');
               ax.Clipping = 'off';
                view([90 +90]); % Coronal View

                 patch(bone.C6, 'FaceColor', colors{2}, ...
                     'EdgeColor', 'none', ...
                     'FaceLighting', 'gouraud', ...
                     'BackFaceLighting', 'reverselit', ...
                      'FaceAlpha', 0.8, ...
                      'AmbientStrength', 0.9); 

                 patch(C5_temp, 'FaceColor', colors{1}, ...
                     'EdgeColor', 'none', ...
                     'FaceLighting', 'gouraud', ...
                     'BackFaceLighting', 'reverselit',...
                      'FaceAlpha', 0.8, ...
                      'AmbientStrength', 0.9); 

                           % Add camera lights
                 light('Position',[0 -1 0],'Style','infinite')
                 camlight('headlight');
                 material('dull');
    %              
             subplot_tight(2,2,4,[])
               axis('off');
               axis('equal');
               ax.Clipping = 'off';
                view([0 0]); % Lateral View

                 patch(bone.C6, 'FaceColor', colors{2}, ...
                     'EdgeColor', 'none', ...
                     'FaceLighting', 'gouraud', ...
                     'BackFaceLighting', 'reverselit', ...
                      'FaceAlpha', 0.8, ...
                      'AmbientStrength', 0.9); 

                 patch(C5_temp, 'FaceColor', colors{1}, ...
                     'EdgeColor', 'none', ...
                     'FaceLighting', 'gouraud', ...
                     'BackFaceLighting', 'reverselit',...
                      'FaceAlpha', 0.8, ...
                      'AmbientStrength', 0.9);

                           % Add camera lights
                 light('Position',[0 -1 0],'Style','infinite')
                 camlight('headlight');
                 material('dull');
    % %         

         if mod(idx, 10) == 1
            animation(frame) = getframe(gcf);
            frameIdxs(frame) = idx;
            frame = frame+1;
         end

         if idx == 1
             hold on
             axis('vis3d')
             axis manual
         end

         if idx ~= N
             % don't clear the screen at the last iteration
             clf
         end
    %   save the videos every 400 frames as a safeguard   
        if mod(idx, 400) == 0
            vidOut(sac, animation, videoPath)
        end
        
    end
    
    vidOut(sac, animation, videoPath)
    
catch ME
    fprintf("Error at frame: %f", idx);
    fprintf("\nError Message: %s", ME.message)
end

  %close(f)
  
end

%% Write Videos


function vidOut(sac_temp, animation, videoPath)
    % restructure SAC images
    sac_temp{2,end} = []; % add blank double arrays to become colormap field
    sacStruc = cell2struct(sac_temp, {'cdata', 'colormap'}, 1);

    renderPath = videoPath + "_render";
    sacPath = videoPath + "_SAC";

    vid_out = write_avi_animation(renderPath, animation);
    vid_out = write_avi_animation(sacPath, sacStruc);
end
    %close(gcf);


