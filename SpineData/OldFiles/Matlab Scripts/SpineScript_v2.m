addpath('C:/Users/acgis/Documents/GitHub/spineKinematics/SpineData/Sample');
addpath('C:/Users/acgis/Documents/GitHub/spineKinematics/SpineData/StockMatlabScripts');
addpath('C:/Users/acgis/Documents/GitHub/spineKinematics/SpineData/CustomMatlabScripts');
addpath(genpath('C:/Users/acgis/Documents/GitHub/spineKinematics/SpineData/CTSegmentations'));
%addpath('C:/Users/acgis/Box/Brodke Research CTs 8-11-22')
addpath("C:\Users\acgis\Documents\GitHub\spineKinematics\SpineData\MocapData\CAD_B\Cad_B_11-10-50")
addpath('C:/Users/acgis/Documents/GitHub/spineKinematics/SpineData/StaticTransformationMatrices');


warning('off', 'all')

%args to pass in: boneFiles (stls), polhemusTbeat mat, mocap data

boneFiles = {"Alpha_C5.stl", "Alpha_C6.stl", "Alpha_C5.txt", "Alpha_C6.txt"};
beadFiles = {"Alpha_C5_beads.stl", "Alpha_C6_beads.stl", "Alpha_C5_beads.txt", "Alpha_C6_beads.txt"};
alignmentPath = "Alpha_Alignment.txt";

load("polhemusTbeadV2.mat");
mocapPath = "Raw - copy.txt";
videoPath = "Alpha_test_2.27";

% 
% boneFiles = {"Beta_C5.stl", "Beta_C6.stl", "Beta_C5.txt", "Beta_C6.txt"};
% beadFiles = {"Beta_C5_beads.stl", "Beta_C6_beads.stl", "Beta_C5_beads.txt", "Beta_C6_beads.txt"};
% alignmentPath = "Beta_Alignment.txt";
% 
% load("polhemusTbeadV2.mat");
% mocapPath = "Beta_Raw - copy.txt";
% videoPath = "Beta_test_2.27";

polhemusFiles = {"C5_Pair.stl", "C6_Pair.stl"};
pixConv = 0.0285*0.0285;


%%  Set up meshes

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

verts = {'C5', 'C6'};
%% load matrices

% here is where you would load patient-specific beadToVert:

% load in mocap data:
pose = ReadMocap(mocapPath, [1,2,3], alignmentPath);


% create bead to bone matrix

% load in bead to global and bone to global, which are from the 3matic
% software
for n = 1:2
    globalTbead.(verts{n}) = readCalib(beadFiles{n+2}, 'beads', beadFiles{n});
    globalTvert.(verts{n}) = readCalib(boneFiles{n+2}, 'bone', boneFiles{n});

    beadTbone.(verts{n}) = (globalTbead.(verts{n})) * inv(globalTvert.(verts{n}));
end

% plot the coordinate systems as a double check
stls = [boneFiles{1:2}, beadFiles{1:2}];
mats = {globalTvert.C5, globalTvert.C6, globalTbead.C5, globalTbead.C6};
plotCalib(mats, stls);


%% set up loop
% create the figure
f = figure('Position',[1 0 640 640],'Visible', 'on');

N = length(pose.C5);
results = zeros(length(pose.C5), 6);

%f = waitbar(0, sprintf('Processing Data: Frame %d/%d',1, N));

% temp fix:
% polTbead.C5(1:3, 1:3) = eye(3);
% polTbead.C6(1:3, 1:3) = eye(3);


N = 1; %% comment this line out when running for real
for idx = 1:N

    % progress bar
    if mod(idx, 10) == 0
        fprintf('\nframe %d/%d', idx, N) 
    end
    globalTpolC5 = pose.C5{idx};
    globalTpolC6 = pose.C6{idx};
    
    % globalTOmarker * markerTObead * beadTObone = globalTObone    
    
    glo.C5{idx} = globalTpolC5 * (polTbead.C5) * beadTbone.C5;
    glo.C6{idx} = globalTpolC6 * (polTbead.C6) * beadTbone.C6;   
    
    C5toC6{idx} = inv(glo.C5{idx}) * glo.C6{idx};
    
    results(idx, 1:3) = ( - C5toC6{idx}(1:3,1:3).' * C5toC6{idx}(1:3, 4)).';
    results(idx, 4:6) = getRotations(123, C5toC6{idx});

    C6_temp_verts = (C5toC6{idx}) * C6verts;
    C6_temp.Vertices = C6_temp_verts(1:3, :)';
    


   % [sacMM{idx}, sac{idx}] = SAC2d(C6_temp, bone.C5, pixConv);

%% plot

     colors = {[56,163,165]./256, [64,71,109]./265, [87, 204, 153]./265, ...
         [172, 128, 160]./265};
    % colors = {'r','b','g','m'};
    
    % Fix the axes scaling, and set a nice view angle
 %   subplot_tight(2,1,1,0)

       axis('off');
       axis('equal');
       ax.Clipping = 'off';
%         view([]); % Coronal View
%         camroll(camRots(1)); % Coronal View
   
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
         
%     subplot_tight(2,1,2,0)
% %            axis([-75 75 -50 100 -75 75]);
% 
%        axis('off');
%        axis('equal');
%        ax.Clipping = 'off';
%         view([0 180]); % Lateral View
%         %camroll(-90)
%          patch(bone.C5, 'FaceColor', colors{1}, ...
%              'EdgeColor', 'none', ...
%              'FaceLighting', 'gouraud', ...
%              'BackFaceLighting', 'reverselit', ...
%               'FaceAlpha', 0.8, ...
%               'AmbientStrength', 0.9); 
% 
%          patch(C6_temp, 'FaceColor', colors{2}, ...
%              'EdgeColor', 'none', ...
%              'FaceLighting', 'gouraud', ...
%              'BackFaceLighting', 'reverselit',...
%               'FaceAlpha', 0.8, ...
%               'AmbientStrength', 0.9); 
% 
%            %        Add camera lights
%          light('Position',[0 -1 0],'Style','infinite')
%          camlight('headlight');
%          material('dull');
%     
     
     animation(idx) = getframe(gcf);
     
     if idx == 1
         hold on
         axis('vis3d')
         axis manual
     end
     
     if mod(idx, 50) == 0
         frames = animation(1:10^ceil(log10(idx))/50:end).cdata;
         vid_out = write_avi_animation(videoPath, frames);
     end
        
     %clf
%      
end
  %close(f)

vid_out = write_avi_animation(videoPath, animation);

%close(gcf);


