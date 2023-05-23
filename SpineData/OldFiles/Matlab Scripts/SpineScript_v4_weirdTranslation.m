addpath('C:/Users/acgis/Documents/GitHub/spineKinematics/SpineData/Sample');
addpath('C:/Users/acgis/Documents/GitHub/spineKinematics/SpineData/StockMatlabScripts');
addpath('C:/Users/acgis/Documents/GitHub/spineKinematics/SpineData/CustomMatlabScripts');
addpath('C:/Users/acgis/Documents/GitHub/spineKinematics/SpineData/CTSegmentations/Alpha');
addpath('C:/Users/acgis/Box/Brodke Research CTs 8-11-22')
addpath("C:\Users\acgis\Documents\GitHub\spineKinematics\SpineData\MocapData\CAD_A\Cad_A_14-12-05")
addpath('C:/Users/acgis/Documents/GitHub/spineKinematics/SpineData/StaticTransformationMatrices');

fileDir = ("Sample/LSP_AX_2_Thresh");


warning('off', 'all')

%args to pass in: boneFiles (stls), polhemusTbeat mat, mocap data

boneFiles = {"Alpha_C5.stl", "Alpha_C6.stl", "Alpha_C5.txt", "Alpha_C6.txt"};
beadFiles = {"Alpha_C5_beads.stl", "Alpha_C6_beads.stl", "Alpha_C5_beads.txt", "Alpha_C6_beads.txt"};
alignmentPath = "AlphaAlignment.mat";
load("polhemusTbeadV2.mat");
mocapPath = "Raw - copy.txt";
videoPath = "test_3.13";

pixConv = 0.0285*0.0285;

verts = {'C5', 'C6'};

%%  Set up figure/mesh
f = figure('Position',[1 0 640 640],'Visible', 'on');

%% load matrices

% here is where you would load patient-specific beadToVert:

% load in mocap data:
 pose = ReadMocap_v2(mocapPath, [1,2,3], alignmentPath);
load('relativeEuler.mat');
relPose = getAttMat(relPoseEul);
% load in polhemusToBead which is from the schematic

% create bead to bone matrix
% load in bead to global and bone to global
for n = 1:2
    beadTglobal.(verts{n}) = readCalib(beadFiles{n+2}, 'beads', beadFiles{n});
    vertTglobal.(verts{n}) = readCalib(boneFiles{n+2}, 'bone', boneFiles{n});

    %beadTbone.(verts{n}) = beadTglobal.(verts{n}) * inv(vertTglobal.(verts{n}));
%     beadTbone.(verts{n}) = inv(globalTbead.(verts{n})) * (globalTvert.(verts{n}));
    %beadTbone.(verts{n}) = inv(globalTvert.(verts{n}))* globalTbead.(verts{n});
    boneTbead.(verts{n}) = inv(beadTglobal.(verts{n})) * (vertTglobal.(verts{n}));
end

% plot the coordinate systems as a double check
stls = ["Alpha_C5.stl", "Alpha_C6.stl", beadFiles{1:2}];
mats = {vertTglobal.C5, vertTglobal.C6, beadTglobal.C5, beadTglobal.C6};
plotCalib(mats, stls);

% load in alignment data
alignment = load(alignmentPath);
alignMat = getAttMat([repmat(0,4,3), alignment.alignment]);
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

DCM = vertTglobal.C5;

    C5verts = inv(DCM) * C5verts;
    bone.C5.Vertices = C5verts(1:3, :)';
    
    C6verts = inv(DCM) * C6verts;
    bone.C6.Vertices = C6verts(1:3,:)';

    
%% set up loop

N = length(relPose);
results = zeros(length(relPose), 6);
%f = waitbar(0, sprintf('Processing Data: Frame %d/%d',1, N));
% polTbead.C5(1:3, 1:3) = eye(3);
% polTbead.C6(1:3, 1:3) = eye(3);


N =1; %% comment this line out when running Lol
for idx = 1:N

%     waitbar(idx/N, f, sprintf('Frame %d/%d', idx, N));    
    if mod(idx, 10) == 0
        fprintf('\nframe %d/%d', idx, N) 
    end
     globalTpolC5 = pose.C5{idx};

     
    %               pol6 wrt pol 5     bead 6 wrt pol 6    bone 6 wrt bead 6
    C6toPol5{idx} =  relPose{idx}  *    polTbead.C6   *    (boneTbead.C6);
%     C6toGlob{idx} =  C6toPol5{idx}; %* globalTpolC5;
     
     C5toC6{idx} = C6toPol5{idx};
     
    
    C6_temp_verts = C5toC6{idx} * C6verts;
    C6_temp.Vertices = C6_temp_verts(1:3, :)';
    C6_temp.Vertices(:,3) = C6_temp.Vertices(:,3) + 23.3344;
    
%     [sacMM{idx}, sac{idx}] = SAC2d(C6_temp, bone.C5, pixConv);

%% plot

     set(0, 'currentfigure', f);  %# for figures

     colors = {[56,163,165]./256, [64,71,109]./265, [87, 204, 153]./265, ...
         [172, 128, 160]./265};
    
    % Fix the axes scaling, and set a nice view angle
    
    results(idx, 1:3) = (C5toC6{idx}(1:3, 4)).';
    results(idx, 4:6) = getRotations(123, C5toC6{idx});
    
   %axis([-75 75 -50 100 -75 75]);
   axis('off')
     subplot_tight(2,1,1,[])
            %axis([-75 75 -50 100 -75 75]);

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

         patch(bone.C6, 'FaceColor', colors{2}, ...
             'EdgeColor', 'none', ...
             'FaceLighting', 'gouraud', ...
             'BackFaceLighting', 'reverselit',...
              'FaceAlpha', 0.8, ...
              'AmbientStrength', 0.9); 

         %          Add camera lights
         light('Position',[0 -1 0],'Style','infinite')
         camlight('headlight');
         material('dull');
         
%     subplot_tight(2,2,3,[])
%         axis('off')
           %axis([-75 75 -50 100 -75 75]);
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
        
     %clf
%      
end
  %close(f)

vid_out = write_avi_animation(videoPath, animation);

%close(gcf);


