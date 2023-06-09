function [distraction, sacMM, bone, checkpt] = spineProcessing(posePath, boneFiles, beadFiles, render, videoPath, readFromCheckpoint, checkpoint, polTbead)
% Process the vertebral data collected with Polhemus sensors to determine
% 2D SAC.

% Inputs:
%           posePath:           Polhemus sensor output (raw data in .txt format).
%           boneFiles:          paths to relevant bone files. Must be in a cell
%                               array of strings in the order:
%                                   {[C5 STL] [C6 STL] [C5 to Global 4x4 matrix] [C6 to
%                                   Global Mat]}
%           beadFiles:          paths to C5 and C6 beads, in same order as bones
%                               files.
%           render:             "Y" or "N"; whether or not video should be
%                               rendered. Note: this option will render one frame
%                               every 50 frames, or at a frequency of 0.5Hz. This
%                               option slows down the program CONSIDERABlY and uses
%                               a massive amount of storage.
%           videoPath:          path to output rendering to; videos will render as
%                               videoPath + "_SAC" and +"_distraction"
%           readFromCheckpoint: "Y" or "N"; whether or not to start at the
%                               beginning of the file or at a checkpoint.
%           checkpoint:         If above is "Y", must be a structure of the
%                               following format:
%                                   checkpoint.start = last frame of checkpoint
%                                   checkpoint.distraction = array of
%                                   previous distraction vals
%                                   checkpoint.sacMM = above, but sacMM
%           polTbead:           Static polTbead matrix





% pixel conversion from dicom file in mm2
pixConv = 0.0285*0.0285;

%set verts to iterate through stuct field names
verts = {'C5', 'C6'};

% load in mocap data: 
pose = ReadMocap_v2(posePath + ".txt");

%%  Set up figure/mesh

if render == "Y"
    f = figure('Position',[1 0 640 640],'Visible', 'off', 'HandleVisibility', 'on');
    frame = 1;
end
%% load matrices

for n = 1:2
    % load in bead to global and bone to global
    beadTglobal.(verts{n}) = readCalib(beadFiles{n+2}, 'beads', beadFiles{n});
    vertTglobal.(verts{n}) = readCalib(boneFiles{n+2}, 'bone', boneFiles{n});

    % create bead to bone matrix
      boneTbead.(verts{n}) = inv(beadTglobal.(verts{n})) * (vertTglobal.(verts{n}));
end

% plot the coordinate systems as a double check. If you want these
% graphics, uncomment the following lines. 

% stls = {boneFiles{1}; boneFiles{2}; beadFiles{1}; beadFiles{2}};
% mats = {vertTglobal.C5, vertTglobal.C6, beadTglobal.C5, beadTglobal.C6};
%plotCalib(mats, stls);

%% Create Meshes
% from the STL files, create matlab meshes that can be rendered using
% patch. This also creates the vertices matrices that will be used for
% transforms.

[faces,vertices] = readSTL(boneFiles{1});
bone.C5.Faces = faces;
bone.C5.Vertices = vertices;

C5_temp.Faces = faces;
C5verts  = [vertices.'; ones(1,length(vertices.'))];

[faces,vertices] = readSTL(boneFiles{2});
bone.C6.Faces = faces;
bone.C6.Vertices = vertices;

C6verts  = [vertices.'; ones(1,length(vertices.'))];

%% Rotate both meshes to be orthogonal
% sets both bones to be in their own local coordinate systems at their own
% origins.


    C5verts = inv(vertTglobal.C5) * C5verts;
    bone.C5.Vertices = C5verts(1:3, :)';
    
    C6verts = inv(vertTglobal.C6) * C6verts;
    bone.C6.Vertices = C6verts(1:3,:)';
    
    
    % find the most inferior and superior points of each vertebrae.
    [C5Inf, ~] = findMinimums(bone.C5, 0);
    [~, C6Sup] = findMinimums(bone.C6, 0);
%% Set up loop

N = length(pose.C5);
results = zeros(length(pose), 6);


% check if there is a checkpoint
if readFromCheckpoint == "N"
    start = 1;
    sacMM = [];
else
    start = checkpoint.start+1;
    sacMM = checkpoint.sacMM;
    distraction = checkpoint.distraction;
end

try
    for idx = start:N

        % shows progress
        if mod(idx, 10) == 0
            fprintf('\nframe %d/%d', idx, N) 
        end
        
        % do the actual coordinate transforms
        C5beadtoGlobal = pose.C5{idx} * (polTbead.C5);
        C6beadtoGlobal = pose.C6{idx} * (polTbead.C6);

        C5toGlobal = C5beadtoGlobal * boneTbead.C5;
        C6toGlobal = C6beadtoGlobal * boneTbead.C6;

        C5toC6 = inv(C5toGlobal) * C6toGlobal;    

        %% Everything

        % change the actual vertices of the mesh
        C5_temp_verts = inv(C5toC6) * C5verts;    
        C5_temp.Vertices = C5_temp_verts(1:3, :)';

        if render == "Y"
            % Create matrix of image data to create rendering of SAC
            [sacMM{idx}, sac{idx}] = SAC2d(bone.C6, C5_temp, pixConv, 0);
        else
            [sacMM{idx}, ~] = SAC2d(bone.C6, C5_temp, pixConv, 0);
        end
    %% plot
    if render == "Y"
         set(0, 'currentfigure', f);  %# for figures
         colors = {[250 70 22]./256, [0 33 165]./265};
    end
    
        C6toC5{idx} = inv(C5toC6);
        % Calculate result Euler angles and AzElRo. These will not be used,
        % but may be useful at a future date.
        results(idx, 1:3) = (C6toC5{idx}(1:3, 4)).';
        results(idx, 4:6) = getRotations(123, C6toC5{idx});
        
        % calculate bottom to top distraction (in mm)
        distraction = results(idx,3) + C5Inf - C6Sup;

     if render == "Y"
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

         if mod(idx, 50) == 1
            % take the frame for rendering
            animation(frame) = getframe(gcf);
            frameIdxs(frame) = idx;
            
            sacAnimation(frame) = sac(idx);
            
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
            vidOut(sacAnimation, animation, videoPath)
        end
     end
        
        
    end
    
    if render == "Y"
        vidOut(sacAnimation, animation, videoPath)
    end
    
    % if it finished successfully, no checkpoint is needed
    checkpt = [];
    
catch ME
    % try to save checkpoint
    try
        checkpt = saveCheck(length(distraction), distraction, cell2mat(sacMM));
        fprintf("Checkpoint Saved \n");
    catch
        fprintf("\n No Checkpoint Saved");
    end
    
    
    fprintf("Error at frame: %f \n", round(idx));
%     fprintf("\nError Message: %s", ME.message)
    fprintf('Line %d: Error Message:\n%s', ...
        ME.stack(1).line, ME.message);
%     fprintf(1, '%s\n', errorMessage);
%     uiwait(warndlg(errorMessage));
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

%% Save Checkpoint

function check = saveCheck(start, dist, sacMM)
    check.truth = "Y";
    check.distraction = dist;
    check.sacMM = sacMM;
    check.start = start;
end
