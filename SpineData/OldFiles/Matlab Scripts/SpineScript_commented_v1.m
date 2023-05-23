%% Add in paths

addpath('C:/Users/acgis/Documents/GitHub/spineKinematics/SpineData/Sample');
addpath('C:/Users/acgis/Documents/GitHub/spineKinematics/SpineData/StockMatlabScripts');
addpath('C:/Users/acgis/Documents/GitHub/spineKinematics/SpineData/CustomMatlabScripts');
addpath('C:/Users/acgis/Documents/GitHub/spineKinematics/SpineData/CTSegmentations/Alpha');
addpath('C:/Users/acgis/Box/Brodke Research CTs 8-11-22')
addpath("C:\Users\acgis\Documents\GitHub\spineKinematics\SpineData\MocapData\CAD_A\Cad_A_14-12-05")
addpath('C:/Users/acgis/Documents/GitHub/spineKinematics/SpineData/StaticTransformationMatrices');

warning('off', 'all')

%args to pass in: boneFiles (stls), polhemusTbeat mat, mocap data

boneFiles = {"Alpha_C5.stl", "Alpha_C6.stl", "Alpha_C5.txt", "Alpha_C6.txt"};
beadFiles = {"Alpha_C5_beads.stl", "Alpha_C6_beads.stl", "Alpha_C5_beads.txt", "Alpha_C6_beads.txt"};
alignmentPath = "AlphaAlignment.mat";
load("polhemusTbeadV2.mat");
mocapPath = "Raw - copy.txt";
videoPath = "test_3.20";

% pixel conversion from dicom file
pixConv = 0.0285*0.0285;

%set verts to iterate through stuct field names
verts = {'C5', 'C6'};

%%  Set up figure/mesh
f = figure('Position',[1 0 640 640],'Visible', 'on');

%% load matrices

% here is where you would load patient-specific beadToVert:

% load in mocap data: % this is obsolete rn
 pose = ReadMocap_v2(mocapPath, [1,2,3], alignmentPath);
 
% these are the relative poses; this is an ugly way of doing it but
% eventually I will write a function like the above one
load('relativeEuler.mat');

% get attribute matrix from the XYZ/ElAzRo
relPose = getAttMat(relPoseEul);

for n = 1:2
    % load in bead to global and bone to global
    beadTglobal.(verts{n}) = readCalib(beadFiles{n+2}, 'beads', beadFiles{n});
    vertTglobal.(verts{n}) = readCalib(boneFiles{n+2}, 'bone', boneFiles{n});

    % create bead to bone matrix
    boneTbead.(verts{n}) = inv(beadTglobal.(verts{n})) * (vertTglobal.(verts{n}));
end

% plot the coordinate systems as a double check
stls = ["Alpha_C5.stl", "Alpha_C6.stl", beadFiles{1:2}];
mats = {vertTglobal.C5, vertTglobal.C6, beadTglobal.C5, beadTglobal.C6};
plotCalib(mats, stls);

% load in alignment data
alignment = load(alignmentPath);
alignMat = getAttMat([repmat(0,4,3), alignment.alignment]);

% relative alignment: alignment of C5 to C6
relAlign = inv(alignMat{1}) * alignMat{2};

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

%% Rotate both meshes to be orthogonal to C5

% Direct Cosine Matrix == C5 to Global matrix
DCM = vertTglobal.C5;

    C5verts = inv(DCM) * C5verts;
    bone.C5.Vertices = C5verts(1:3, :)';
    
    C6verts = inv(DCM) * C6verts;
    bone.C6.Vertices = C6verts(1:3,:)';

    
%% set up loop

% temporarily not using full length of N
N = length(relPose);
results = zeros(length(relPose), 6);


N = 1; %% comment this line out when running Lol
for idx = 1:N

    % shows progress
    if mod(idx, 10) == 0
        fprintf('\nframe %d/%d', idx, N) 
    end
     
    %               pol6 wrt pol 5     bead 6 wrt pol 6    bone 6 wrt bead 6
    C6toPol5{idx} = (relPose{idx})  *    polTbead.C6   *    (boneTbead.C6);

    
    % this is never actually used, I'm sure it needs to be but I can't
    % figure out how
    %                                 bead 5 wrt pol 5      bone 6 wrt bead 6 
    C5toPol5 = inv(alignMat{1}) * (polTbead.C5)     *   (boneTbead.C5);

    C5toC6{idx} =  C6toPol5{idx};
     
    
    % change the actual vertices of the mesh
    C6_temp_verts = C5toC6{idx} * C6verts;
    C6_temp.Vertices = C6_temp_verts(1:3, :)';
    
        % add the translations that make everything look right-ish
%         C6_temp.Vertices(:,1) = C6_temp.Vertices(:,1)+4.7258;
%         C6_temp.Vertices(:,2) = C6_temp.Vertices(:,2) - 0;
%         C6_temp.Vertices(:,3) = C6_temp.Vertices(:,3)+31.4637;

    % 2D SAC Calculations
    if idx == 1 || idx == N
        % Show figures for the first and last iteration
        [sacMM{idx}, sac{idx}] = SAC2d(bone.C5, C6_temp, pixConv, 1);
    else
        [sacMM{idx}, sac{idx}] = SAC2d(bone.C5, C6_temp, pixConv, 0);
    end

%% plot

     set(0, 'currentfigure', f);  %# for figures

     colors = {[56,163,165]./256, [64,71,109]./265};
     
    % Calculate result Euler angles and AzElRo
    results(idx, 1:3) = (C5toC6{idx}(1:3, 4)).';
    results(idx, 4:6) = getRotations(123, C5toC6{idx});
    
   % Fix the axes scaling, and set a nice view angle
   axis('off')
     subplot_tight(2,1,1,[])
       axis('off');
       grid('off');
       axis('equal');
       ax.Clipping = 'off';
        view([90 0]); % Frontal View
   
         patch(bone.C5, 'FaceColor', colors{1}, ...
             'EdgeColor', 'none', ...
             'FaceLighting', 'gouraud', ...
             'BackFaceLighting', 'reverselit', ...
              'FaceAlpha', 0.8, ...
              'AmbientStrength', 0.9); 

         patch(C6_temp, 'FaceColor', colors{2}, ...
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

             patch(bone.C5, 'FaceColor', colors{1}, ...
                 'EdgeColor', 'none', ...
                 'FaceLighting', 'gouraud', ...
                 'BackFaceLighting', 'reverselit', ...
                  'FaceAlpha', 0.8, ...
                  'AmbientStrength', 0.9); 

             patch(C6_temp, 'FaceColor', colors{2}, ...
                 'EdgeColor', 'none', ...
                 'FaceLighting', 'gouraud', ...
                 'BackFaceLighting', 'reverselit',...
                  'FaceAlpha', 0.8, ...
                  'AmbientStrength', 0.9); 

                       % Add camera lights
             light('Position',[0 -1 0],'Style','infinite')
             camlight('headlight');
             material('dull');
             
        subplot_tight(2,2,4,[])
           axis('off');
           axis('equal');
           ax.Clipping = 'off';
            view([0 0]); % Lateral View

             patch(bone.C5, 'FaceColor', colors{1}, ...
                 'EdgeColor', 'none', ...
                 'FaceLighting', 'gouraud', ...
                 'BackFaceLighting', 'reverselit', ...
                  'FaceAlpha', 0.8, ...
                  'AmbientStrength', 0.9); 

             patch(C6_temp, 'FaceColor', colors{2}, ...
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
     
     animation(idx) = getframe(gcf);
     
     if idx == 1
         hold on
         axis('vis3d')
         axis manual
     end
       
     if idx ~= N
         % don't clear the screen at the last iteration
         clf
     end
%      
end
  %close(f)

vid_out = write_avi_animation(videoPath, animation);

%close(gcf);


