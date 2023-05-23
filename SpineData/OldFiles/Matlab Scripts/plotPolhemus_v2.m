addpath('C:/Users/acgis/Documents/GitHub/spineKinematics/SpineData/Sample');
addpath('C:/Users/acgis/Documents/GitHub/spineKinematics/SpineData/StockMatlabScripts');
addpath('C:/Users/acgis/Documents/GitHub/spineKinematics/SpineData/CustomMatlabScripts');
addpath(genpath('C:/Users/acgis/Documents/GitHub/spineKinematics/SpineData/CTSegmentations'));
%addpath('C:/Users/acgis/Box/Brodke Research CTs 8-11-22')
addpath("C:\Users\acgis\Documents\GitHub\spineKinematics\SpineData\MocapData\CAD_A\Cad_A_14-12-05")
addpath('C:/Users/acgis/Documents/GitHub/spineKinematics/SpineData/StaticTransformationMatrices');


warning('off', 'all')

%args to pass in: boneFiles (stls), polhemusTbeat mat, mocap data

alignmentPath = "Alpha_Alignment.txt";

load("polhemusTbeadV2.mat");
mocapPath = "Raw - copy.txt";
videoPath = "Alpha_test_2.27";

polhemusFiles = {"C5_PolhemusShelf.stl", "C6_Pair.stl"};


%%  Set up meshes

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

verts = {'C5', 'C6'};
%% load matrices

% load in mocap data:
pose = ReadMocap(mocapPath, [1,2,3], alignmentPath);

%% set up loop
% create the figure
f = figure('Position',[1 0 640 640],'Visible', 'on');

N = length(pose.C5);
% results = zeros(length(pose.C5), 6);

N = 1; %% comment this line out when running for real
for idx = 1:N

    % progress bar
    if mod(idx, 10) == 0
        fprintf('\nframe %d/%d', idx, N) 
    end
    globalTpolC5 = pose.C5{idx};
    globalTpolC6 = pose.C6{idx};
    
    
    C5toC6{idx} = inv(globalTpolC5) * globalTpolC6;


    polC6temp_verts = (C5toC6{idx}) * polC6verts;
    polC6_temp.Vertices = polC6temp_verts(1:3, :)';
    

%% plot

     colors = {[250 70 22]./256, [0 33 165]./265};

       axis('off');
       axis('equal');
       grid('on');
       ax.Clipping = 'off';
       view([-37.5, 180])
   
         patch(polhemus.C5, 'FaceColor', colors{1}, ...
             'EdgeColor', 'none', ...
             'FaceLighting', 'gouraud', ...
             'BackFaceLighting', 'reverselit', ...
              'FaceAlpha', 0.8, ...
              'AmbientStrength', 0.9); 
          
        patch(polC6_temp, 'FaceColor', colors{2}, ...
             'EdgeColor', 'none', ...
             'FaceLighting', 'gouraud', ...
             'BackFaceLighting', 'reverselit', ...
              'FaceAlpha', 0.8, ...
              'AmbientStrength', 0.9); 
          grid('on')
          axis('on')
        % Plot axes  
        X = [1 0 0];
        Y = [0 1 0];
        Z = [0 0 1];
        ori = [0 0 0];
        
        hold on
        quiver3(ori(1), ori(2), ori(3), Z(1),Z(2), Z(3), 50, 'Color', colors{1})
        hold on
        quiver3(ori(1), ori(2), ori(3), X(1),X(2), X(3), 50, 'Color', colors{1})
        quiver3(ori(1), ori(2), ori(3), Y(1),Y(2), Y(3), 50, 'Color', colors{1})
         
        X = C5toC6{idx}(1:3,1);
        Y = C5toC6{idx}(1:3,2);
        Z = C5toC6{idx}(1:3,3);

        ori = C5toC6{idx}(1:3, 4);
        hold on
        quiver3(ori(1), ori(2), ori(3), Z(1),Z(2), Z(3), 50, 'Color', colors{2})
        hold on
        quiver3(ori(1), ori(2), ori(3), X(1),X(2), X(3), 50, 'Color', colors{2})
        quiver3(ori(1), ori(2), ori(3), Y(1),Y(2), Y(3), 50, 'Color', colors{2})

                  % Add camera lights
         light('Position',[0 -1 0],'Style','infinite')
         camlight('headlight');
         material('dull');
 
%     
     
     animation(idx) = getframe(gcf);
     
     if idx == 1
         hold on
         axis('vis3d')
         axis manual
     end
     
     if mod(idx, 1) == 0
         frames = animation.cdata;
         vid_out = write_avi_animation(videoPath, frames);
     end
        
     %clf
%      
end
  %close(f)

vid_out = write_avi_animation(videoPath, animation);

%close(gcf);


