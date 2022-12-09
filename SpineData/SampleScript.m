addpath('C:/Users/acgis/Documents/Research/Banks_Lab/SpineData/Sample');
addpath('C:/Users/acgis/Documents/Research/Banks_Lab/SpineData/MatlabScripts');
addpath('C:/Users/acgis/Documents/Research/Banks_Lab/SpineData/MatlabScripts/iso2mesh-1.9.6');
addpath('C:/Users/acgis/Box/Brodke Research CTs 8-11-22')
addpath("C:\Users\acgis\Documents\Research\Banks_Lab\SpineData\MocapData\CAD_A\Cad_A_14-12-05")

fileDir = ("Sample/LSP_AX_2_Thresh");


warning('off', 'all')

%args to pass in: boneFiles (stls), polhemusTbeat mat, mocap data

boneFiles = {"Alpha_C5.stl", "Alpha_C6.stl", "Alpha_C5.txt", "Alpha_C6.txt"};
beadFiles = {"Alpha_C5_beads.stl", "Alpha_C6_beads.stl", "Alpha_C5_beads.txt", "Alpha_C6_beads.txt"};
alignmentPath = "AlphaAlignment.mat";
load("polhemusTbeadV2.mat");
mocapPath = "Raw - copy.txt";
videoPath = "test_12.2_3";

pixConv = 0.0285*0.0285;


%%  Set up figure/mesh
f = figure('Position',[1 0 640 640],'Visible', 'off');

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
pose = ReadMocap(mocapPath, [2,1,3], alignmentPath);

% load in polhemusToBead which is from the schematic

% create bead to bone matrix
% load in bead to global and bone to global
for n = 1:2
    globalTbead.(verts{n}) = readCalib(beadFiles{n+2}, 'beads', beadFiles{n});
    globalTvert.(verts{n}) = readCalib(boneFiles{n+2}, 'bone', boneFiles{n});

    %beadTbone.(verts{n}) = beadTglobal.(verts{n}) * inv(vertTglobal.(verts{n}));
    beadTbone.(verts{n}) = inv(globalTbead.(verts{n})) * globalTvert.(verts{n});
end


%% set up loop
N = length(pose.C5);
results = zeros(length(pose.C5), 6);
%f = waitbar(0, sprintf('Processing Data: Frame %d/%d',1, N));



%N = 2; %% comment this line out when running Lol
for idx = 1:N

%     waitbar(idx/N, f, sprintf('Frame %d/%d', idx, N));    
    if mod(idx, 10) == 0
        fprintf('\nframe %d/%d', idx, N) 
    end
    globalTpolC5 = pose.C5{idx};
    globalTpolC6 = pose.C6{idx};
    
    % globalTOmarker * markerTObead * beadTObone = globalTObone
    glo.C5{idx} = (globalTpolC5) * (polTbead.C5) * beadTbone.C5;
    glo.C6{idx} = (globalTpolC6) * (polTbead.C6) * beadTbone.C6;
%     
%     glo.C5{idx} = (globalTpolC5) * (beadTbone.C5);
%     glo.C6{idx} = (globalTpolC6) * (beadTbone.C6);
    
    
%     glo.C5{idx} = globalTpolC5;
%     glo.C6{idx} = globalTpolC6;
    
    
    C5toC6{idx} = inv(glo.C5{idx}) * glo.C6{idx};
    
    results(idx, 1:3) = ( - C5toC6{idx}(1:3,1:3).' * C5toC6{idx}(1:3, 4)).';
    results(idx, 4:6) = getRotations(213, C5toC6{idx});
    
%     C5_temp_verts = inv(glo.C5{idx}) * C5verts;
    C5_temp_verts = (glo.C5{idx}) * C5verts;

    C5_temp.Vertices = C5_temp_verts(1:3, :)';
    
%     C6_temp_verts = inv(C5toC6{idx}) * C6verts;
    C6_temp_verts = (C5toC6{idx}) * C6verts;

    C6_temp.Vertices = C6_temp_verts(1:3, :)';
    
    C6_temp_verts = glo.C5{idx} * C6verts;
        C6_temp.Vertices = C6_temp_verts(1:3, :)';


    [sacMM{idx}, sac{idx}] = SAC2d(C6_temp, bone.C5, pixConv);

%% plot

     set(0, 'currentfigure', f);  %# for figures

     colors = {[56,163,165]./256, [64,71,109]./265, [87, 204, 153]./265, ...
         [172, 128, 160]./265};
    % colors = {'r','b','g','m'};
    
    % Fix the axes scaling, and set a nice view angle
%        axis([-75 75 -50 100 -75 75]);
    subplot_tight(2,1,1,0)
       axis('off');
       axis('equal');
       ax.Clipping = 'off';
        view([0 +180]); % Coronal View
        %camroll(90); % Coronal View
   
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

                   % Add camera lights
         light('Position',[0 -1 0],'Style','infinite')
         camlight('headlight');
         material('dull');
         
     subplot_tight(2,1,2,0)
       axis('off');
       axis('equal');
       ax.Clipping = 'off';
        view([0 +90]); % Lateral View
   
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

                   % Add camera lights
         light('Position',[0 -1 0],'Style','infinite')
         camlight('headlight');
         material('dull');
    
     
     animation(idx) = getframe(gcf);
     
     if idx == 1
         hold on
         axis('vis3d')
         axis manual
     end
        
     clf
%      
end
%  close(f)

vid_out = write_avi_animation(videoPath, animation);

close(gcf);


