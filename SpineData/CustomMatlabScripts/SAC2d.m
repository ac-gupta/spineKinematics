%% 2D SAC

%% take out when function-ized

function [sacMM, C] = SAC2d(bone1, bone2, pixConv, vis)

%% 2D SAC Calculations
% Uses a vertical ray tracing approach: assuming we have the watertight
% meshes and a gridded set on the C6 XY plane, we can pass a "ray" through
% each point on the grid and check if it intersects the vertebrae.

% where the rays don't intersect the vertebrae and are inside the vertebrae
% outer border, we can consider a "hole". Then we find the overlap between
% the two "holes" 

% Inputs:
    % bone1, bone2: [F,V] objects for each of the two vertebrae. This must
    % be in the format for patch() (i.e., read in using readSTL).
    
    %DCM: Cell matrix containing the Direct Cosine Matrix (3x3 rotation,
    %plus the [0 0 0] translation vector) to zero the STLs.
    
    % pixConv = mm^2/pixel area conversion factor.
    
    %plot visibility - 'off' or 'on'
    
% outputs:
    % sacMM: SAC area in mm^2
    % sac: Boolean representation of SAC area.

mesh = {bone1 bone2};

%% Identify openings in vertebrae (vertebrael foramen and transverse foramen)
% i.e., we are trying to find the largest opening in each mesh

for n = 1:2
    % we only care about the XY projection
    Vxy = unique(mesh{n}.Vertices(:,1:2), 'rows');
    
    %  create the alpha shape
%     tic
    shp = alphaShape(Vxy, 'holeThreshold', 10);
%     tAlpha = toc;
    
    % get the outline around the shape
%     tic
    [bf, P] = boundaryFacets(shp);
%     tBoundary = toc;
    
    % convert into a graph
%     tic
    G = graph(bf(:,1), bf(:,2));
%     G{n}.Nodes.X = P(:,1);
%     G{n}.Nodes.Y = P(:,2);
    loops = cyclebasis(G);
%     tCycle = toc;
    
    % calculate the area of each of the loops
%     tic
    areas = [];
    for k = 1:length(loops)
        nodeIdx = loops{k};
        x = P(nodeIdx,1);
        y = P(nodeIdx,2);
        areas(k) = polyarea(x,y);
    end    
%     tPoly = toc;
    
    % find the vertebrael formaen (2nd largest)
    [~, sortInd] = sort(areas);
    foramenInd = sortInd(end-1);
    polyshapes{n} = polyshape(P(loops{foramenInd},1), P(loops{foramenInd},2));

end

% fprintf('alpha:     %.3f s\n', tAlpha);
% fprintf('boundary:  %.3f s\n', tBoundary);
% fprintf('cycle:     %.3f s\n', tCycle);
% fprintf('polyshape: %.3f s\n', tPoly);

%% Find the overlap area

overlap = intersect(polyshapes{1}, polyshapes{2});
sacMM = area(overlap);

if vis
    colors = {[250 70 22]./256, [0 33 165]./265};

    C = figure('visible', 'off');
    for n = 1:2
    plot(polyshapes{n}, 'FaceColor', colors{n}, 'FaceAlpha', 0.7);
    hold on
    end
    plot(overlap);
    axis equal
    xlim([-20 40]);
    axis off
else
    C = [];
end


