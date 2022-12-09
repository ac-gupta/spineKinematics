[faces, verts] = readSTL(boneFiles{1});
load("SWtoC5.txt")

C5.Faces = bone.;
C5.Vertices = vertices;

C5_temp.Faces  =faces;
C5vertsGLOBAL = [vertices.'; ones(1,length(vertices.'))];

C5vertsLocal = inv(SWtoC5) * C5vertsGLOBAL;

C5_temp.Vertices = C5vertsLocal(1:3, :)';

figure()


  % Fix the axes scaling, and set a nice view angle
%        axis([-75 75 -50 100 -75 75]);
       axis('off');
       %ax.Clipping = 'off';
%        view([0 +90]); % Coronal View
%        camroll(180); % Coronal View

       view([90 0]); % Lateral View

     
     colors = {[56,163,165]./256, [64,71,109]./265, [87, 204, 153]./265, ...
         [172, 128, 160]./265};
     
     patch(C5_temp, 'FaceColor', colors{1});