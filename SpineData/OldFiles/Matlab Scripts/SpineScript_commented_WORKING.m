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
videoPath = "test_4.17";

polhemusFiles = {"C5_PolhemusShelf.stl", "C6_Pair.stl"};

% pixel conversion from dicom file
pixConv = 0.0285*0.0285;

%set verts to iterate through stuct field names
verts = {'C5', 'C6'};

plotExtra = 1;

%%  Set up figure/mesh
f = figure('Position',[1 0 640 640],'Visible', 'off');

%% load matrices

% here is where you would load patient-specific beadToVert:

% load in mocap data: % this is obsolete rn
 pose = ReadMocap_v2(mocapPath);
 
% these are the relative poses; this is an ugly way of doing it but
% eventually I will write a function like the above one
%  load('relativeEuler.mat');

% get attribute matrix from the XYZ/ElAzRo
% relPose = getAttMat(relPoseEul);

for n = 1:2
    % load in bead to global and bone to global
    beadTglobal.(verts{n}) = readCalib(beadFiles{n+2}, 'beads', beadFiles{n});
    vertTglobal.(verts{n}) = readCalib(boneFiles{n+2}, 'bone', boneFiles{n});

    vertTglobal.(verts{n}) = vertTglobal.(verts{n});
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
% relAlign = alignMat{2} * inv(alignMat{1});
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

if plotExtra == 1
    [faces, vertices] = readSTL(beadFiles{1});
    bead.C5.Faces = faces;
    bead.C5.Vertices = vertices;
    
    beadTemp.C5.Faces = faces;
    C5beadsVerts = [vertices.'; ones(1,length(vertices.'))];
    
    [faces, vertices] = readSTL(beadFiles{2});
    bead.C6.Faces = faces;
    bead.C6.Vertices = vertices;
    
    beadTemp.C6.Faces = faces;
    C6beadsVerts = [vertices.'; ones(1,length(vertices.'))];
    
    [faces, vertices] = readSTL(polhemusFiles{1});
    polhemus.C5.Faces = faces;
    polhemus.C5.Vertices = vertices;

    polC5_temp.Faces = faces;
    polC5verts = [vertices.'; ones(1,length(vertices.'))];

    [faces, vertices] = readSTL(polhemusFiles{1});
    polhemus.C6.Faces = faces;
    polhemus.C6.Vertices = vertices;

    polC6_temp.Faces = faces;
    polC6verts = [vertices.'; ones(1,length(vertices.'))];
end

%% Rotate both meshes to be orthogonal to C5

% Direct Cosine Matrix == C5 to Global matrix
DCM = vertTglobal.C5;

     C5verts = inv(vertTglobal.C5) * C5verts;
    bone.C5.Vertices = C5verts(1:3, :)';
    
     C6verts = inv(vertTglobal.C6) * C6verts;
    bone.C6.Vertices = C6verts(1:3,:)';
    
    if plotExtra == 1
        % put both beads at origin
         C5beadsVerts = inv(beadTglobal.C5) * C5beadsVerts;
         C6beadsVerts = inv(beadTglobal.C6) * C6beadsVerts;
        
        beadTemp.C5.Vertices = C5beadsVerts(1:3, :)';
        beadTemp.C6.Vertices = C6beadsVerts(1:3, :)';
%         
%          polC5verts=  inv(DCM) * polC5verts;
%          polC6verts = inv(DCM) * polC6verts;
%         
        polC6_temp.Vertices = polC6verts(1:3, :)';
        polC5_temp.Vertices = polC5verts(1:3,:)';
        
    end

    
%% set up loop

N = length(pose);
results = zeros(length(pose), 6);

N = 10
for idx = 1:N

    % shows progress
    if mod(idx, 10) == 0
        fprintf('\nframe %d/%d', idx, N) 
    end
     
    %               pol6 wrt pol 5     bead 6 wrt pol 6    bone 6 wrt bead 6
%      C6toPol5{idx} = (relPose{idx})  *    polTbead.C6   *    inv(boneTbead.C6);
%      beadsC6toPol5{idx} = (relPose{idx}) * polTbead.C6;
%      polC6toPol5{idx} = (relPose{idx});


    C5PoltoGlobal = pose.C5{idx};
    C6PoltoGlobal = pose.C6{idx};

    C5beadtoGlobal = C5PoltoGlobal * (polTbead.C5);
    C6beadtoGlobal = C6PoltoGlobal * (polTbead.C6);
    
    C5toGlobal = C5beadtoGlobal * boneTbead.C5;
    C6toGlobal = C6beadtoGlobal * boneTbead.C6;
    
    % this is never actually used, I'm sure it needs to be but I can't
    % figure out how
    %                           bead 5 wrt pol 5      bone 6 invwrt bead 6 
    C5toPol5 =inv(alignMat{1}) * (polTbead.C5)     *   (boneTbead.C5);
    C5toPol5 = boneTbead.C5 * inv(polTbead.C5);

%     C5toC6{idx} = inv(C6toPol5{1}) * inv(C5toPol5);
    
    %% Everything
    
%     bone5Tbead5 = inv(boneTbead.C5);
%     bone6Tbead6 = inv(boneTbead.C6);
%     
%     bone5Tpol5 = bone5Tbead5 * inv(polTbead.C5);
%     bone6Tpol6 = bone6Tbead6 * inv(polTbead.C6);
%     
%     pol6Tbone6 = (polTbead.C6) * inv(bone6Tbead6);
%     
%     bone5Tpol6 = (bone5Tpol5)  * inv(relAlign) * (relPose{idx}); 
%     bone5Tbone6 = (bone5Tpol6) * (pol6Tbone6) ;
%     
%     bone5Tbead6 = inv(bone5Tbone6) * bone6Tbead6;
%     
%       
      
    % change the actual vertices of the mesh
    C6_temp_verts = C6toGlobal * C6verts;    
%     C6_temp_verts = C6verts;
    C6_temp.Vertices = C6_temp_verts(1:3, :)';
    
    C5_temp_verts = C5toGlobal * C5verts;    
%     C6_temp_verts = C6verts;
    C5_temp.Vertices = C5_temp_verts(1:3, :)';
   
%     
%     if plotExtra == 1
        C5beads_temp = C5beadtoGlobal * C5beadsVerts;
        C6beads_temp = C6beadtoGlobal * C6beadsVerts;
%         
        C5pol_temp = C5PoltoGlobal * polC5verts;
        C6pol_temp = C6PoltoGlobal * polC6verts;
%         
        beadTemp.C5.Vertices = C5beads_temp(1:3, :)';
        beadTemp.C6.Vertices = C6beads_temp(1:3, :)';
%         
        polC5_temp.Vertices = C5pol_temp(1:3, :)';
        polC6_temp.Vertices = C6pol_temp(1:3, :)';
% 
%     end
        
        % add the translations that make everything look right-ish
%         C6_temp.Vertices(:,1) = C6_temp.Vertices(:,1) - 14;
%         C6_temp.Vertices(:,2) = C6_temp.Vertices(:,2) -19;
%         C6_temp.Vertices(:,3) = C6_temp.Vertices(:,3)+53;

    % 2D SAC Calculations
%     if idx == 1 || idx == N
%         % Show figures for the first and last iteration
%         [sacMM{idx}, sac{idx}] = SAC2d(C5_temp, C6_temp, pixConv, 1);
%     else
%         [sacMM{idx}, sac{idx}] = SAC2d(C5_temp, C6_temp, pixConv, 0);
%     end

%% plot

     set(0, 'currentfigure', f);  %# for figures

     colors = {[250 70 22]./256, [0 33 165]./265};
     
    % Calculate result Euler angles and AzElRo
%     results(idx, 1:3) = (C5toC6{idx}(1:3, 4)).';
%     results(idx, 4:6) = getRotations(123, C5toC6{idx});
    
   % Fix the axes scaling, and set a nice view angle
   axis('off')
     subplot_tight(2,1,1,[])
       axis('off');
       grid('off');
       axis('equal');
       ax.Clipping = 'off';
        view([90 0]); % Frontal View
   
         patch(C5_temp, 'FaceColor', colors{1}, ...
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
%           
          patch(beadTemp.C5, 'FaceColor', colors{1}, ...
             'EdgeColor', 'none', ...
             'FaceLighting', 'gouraud', ...
             'BackFaceLighting', 'reverselit',...
              'FaceAlpha', 0.8, ...
              'AmbientStrength', 0.9); 
          
         patch(beadTemp.C6, 'FaceColor', colors{2}, ...
             'EdgeColor', 'none', ...
             'FaceLighting', 'gouraud', ...
             'BackFaceLighting', 'reverselit',...
              'FaceAlpha', 0.8, ...
              'AmbientStrength', 0.9); 
%           
         patch(polC5_temp, 'FaceColor', colors{1}, ...
             'EdgeColor', 'none', ...
             'FaceLighting', 'gouraud', ...
             'BackFaceLighting', 'reverselit',...
              'FaceAlpha', 0.8, ...
              'AmbientStrength', 0.9); 
          
         patch(polC6_temp, 'FaceColor', colors{2}, ...
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

             patch(C5_temp, 'FaceColor', colors{1}, ...
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
              
             patch(beadTemp.C5, 'FaceColor', colors{1}, ...
                 'EdgeColor', 'none', ...
                 'FaceLighting', 'gouraud', ...
                 'BackFaceLighting', 'reverselit',...
                  'FaceAlpha', 0.8, ...
                  'AmbientStrength', 0.9); 
          
             patch(beadTemp.C6, 'FaceColor', colors{2}, ...
                 'EdgeColor', 'none', ...
                 'FaceLighting', 'gouraud', ...
                 'BackFaceLighting', 'reverselit',...
                  'FaceAlpha', 0.8, ...
                  'AmbientStrength', 0.9); 
              
           patch(polC5_temp, 'FaceColor', colors{1}, ...
             'EdgeColor', 'none', ...
             'FaceLighting', 'gouraud', ...
             'BackFaceLighting', 'reverselit',...
              'FaceAlpha', 0.8, ...
              'AmbientStrength', 0.9); 
          
         patch(polC6_temp, 'FaceColor', colors{2}, ...
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

             patch(C5_temp, 'FaceColor', colors{1}, ...
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

             patch(beadTemp.C5, 'FaceColor', colors{1}, ...
                 'EdgeColor', 'none', ...
                 'FaceLighting', 'gouraud', ...
                 'BackFaceLighting', 'reverselit',...
                  'FaceAlpha', 0.8, ...
                  'AmbientStrength', 0.9); 
          
             patch(beadTemp.C6, 'FaceColor', colors{2}, ...
                 'EdgeColor', 'none', ...
                 'FaceLighting', 'gouraud', ...
                 'BackFaceLighting', 'reverselit',...
                  'FaceAlpha', 0.8, ...
                  'AmbientStrength', 0.9); 

             patch(polC5_temp, 'FaceColor', colors{1}, ...
             'EdgeColor', 'none', ...
             'FaceLighting', 'gouraud', ...
             'BackFaceLighting', 'reverselit',...
              'FaceAlpha', 0.8, ...
              'AmbientStrength', 0.9); 
          
              patch(polC6_temp, 'FaceColor', colors{2}, ...
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


