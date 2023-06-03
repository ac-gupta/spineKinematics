 function [inferiorCenter, superiorCenter] = findMinimums(mesh, vis)
%     
% check if Y and Z axes are swapped
if mean(mesh.Vertices(:,2)) < mean(mesh.Vertices(:,3))
    temp = mesh.Vertices(:,2);
    mesh.Vertices(:,2) = mesh.Vertices(:,3);
    mesh.Vertices(:,3) = temp;
end

% indices within 5mm of the origin (center of the vertebral body)
infInds2 = find((mesh.Vertices(:,1)).^2 + (mesh.Vertices(:,3)).^2 < 25);
supsInds2 = find((mesh.Vertices(:,1)).^2 + (mesh.Vertices(:,3)).^2 < 25);

inf = min(mesh.Vertices(infInds2,2));
%indices within 1mm of most inferior point
infInds = find(mesh.Vertices(:,2) < inf+2.5 & islocalmin(mesh.Vertices(:,2)));

%indices within 1mm of origin superior point
supInds = find(islocalmin(mesh.Vertices(:,2)) & mesh.Vertices(:,2) > 1.5);

infInds = intersect(infInds, infInds2);
supInds = intersect(supInds, supsInds2);

inferior.Verts = mesh.Vertices(infInds, :);
superior.Verts = mesh.Vertices(supInds, :);
% plane.Faces = reshape(1:length(plane.Vertices), 3,[])';

inferiorCenter = mean(inferior.Verts(:,2));
superiorCenter = mean(superior.Verts(:,2));

if vis == 1
    figure('Position',[1 0 640 640],'Visible', 'on', 'HandleVisibility', 'on');
    grid('off');
    axis('equal');
    ax.Clipping = 'off';

    patch(mesh, 'FaceColor', 'b', ...
                             'EdgeColor', 'none', ...
                             'FaceLighting', 'gouraud', ...
                             'BackFaceLighting', 'reverselit', ...
                              'FaceAlpha', 0.2, ...
                              'AmbientStrength', 0.9); 
    hold on
    plot3(inferior.Verts(:,1), inferior.Verts(:,2), inferior.Verts(:,3), '.r')
    plot3(superior.Verts(:,1), superior.Verts(:,2), superior.Verts(:,3), '.k')

    % Add camera lights
        light('Position',[0 -1 0],'Style','infinite')
        camlight('headlight');
        material('dull');
end