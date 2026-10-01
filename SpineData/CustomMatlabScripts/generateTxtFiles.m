%% Build Coordinate System Files from Slicer Outputs

%% Define input/output
dir = "C:\Users\acgis\OneDrive - UW-Madison\spineData\SegmentationResults";
addpath(dir);
% C5
endplateFile_C5 = fullfile(dir, 'C5_EndplateCenters.fcsv');
pedicleFile_C5  = fullfile(dir, 'C5_Pedicles.fcsv');
outputFile_C5   = fullfile(dir, 'C5_CoordinateSystem.txt');

% C6
endplateFile_C6 = fullfile(dir, 'C6_EndplateCenters.fcsv');
pedicleFile_C6  = fullfile(dir, 'C6_Pedicles.fcsv');
outputFile_C6   = fullfile(dir, 'C6_CoordinateSystem.txt');

% C5 beads
beadFile_C5   = fullfile(dir, 'C5_Beads_Centroids.csv');
outputFile_C5_beads = fullfile(dir, 'C5_BeadCoordinateSystem.txt');

% C6 beads
beadFile_C6   = fullfile(dir, 'C6_Beads_Centroids.csv');
outputFile_C6_beads = fullfile(dir, 'C6_BeadCoordinateSystem.txt');

%% Generate Vertebrae Coordinate systems

% generate the matrices according to VertFormat.txt
C5_coordSystem = makeVertebraeCS(endplateFile_C5, pedicleFile_C5);
C6_coordSystem = makeVertebraeCS(endplateFile_C6, pedicleFile_C6);

% write to file
writematrix(C5_coordSystem, outputFile_C5, ...
        'Delimiter', ',');
writematrix(C6_coordSystem, outputFile_C6, ...
        'Delimiter', ',');
    
%% Generate bead coordinate systems

% generate the matrices according to VertFormat.txt
C5_beads_mat = makeBeadCS(beadFile_C5);
C6_beads_mat = makeBeadCS(beadFile_C6);

% save outputs
writematrix(C5_beads_mat, outputFile_C5_beads, ...
        'Delimiter', ',');
   
writematrix(C6_beads_mat, outputFile_C6_beads, 'Delimiter', ','); 
%% Helper FUnctions

function coordSyst = makeVertebraeCS(endplateFile, pedicleFile)

    % Read Slicer FCSV files
    endplates = readmatrix(endplateFile, 'FileType', 'text', ...
        'CommentStyle', '#');
    pedicles = readmatrix(pedicleFile, 'FileType', 'text', ...
        'CommentStyle', '#');

    % X/Y/Z coordinates are columns 2:4
    endplatePts = endplates(:, 2:4);
    pediclePts  = pedicles(:, 2:4);

    % Origin
    % Midpoint between superior and inferior endplate centers
    origin = mean(endplatePts, 1);


    % Z-axis
    % Vector from inferior -> superior
    zAxis = endplatePts(1,:) - endplatePts(2,:);

    % Ensure it points superiorly (+Z)
    if zAxis(3) < 0
        zAxis = -zAxis;
    end

    % Normalize
    zAxis = zAxis / norm(zAxis);


    % Y-axis
    % Vector between pedicles
    yAxis = pediclePts(2,:) - pediclePts(1,:);

    % Ensure it points left (+X in Slicer's LPS coordinates)
    if yAxis(1) < 0
        yAxis = -yAxis;
    end

    % Normalize
    yAxis = yAxis / norm(yAxis);

    % Rows = origin, Z-axis, Y-axis
    coordSyst = [origin; zAxis; yAxis];
end

function outputMat = makeBeadCS(beadFile)
% files in RAS 

    beads = readmatrix(beadFile);
    beads = beads(:, 2:4);
      
    % find the two leftmost beads (i.e., lowest X)
    [~, sortInd] = sortrows(beads, 1);
    
    % create a binary matrix where left(i) is zero of the corresponding row
    % in beads is on the right and left(i) is one where it's on the left
    left = [0 0 0 0]; left(sortInd(1:2)) = 1;
    
    % do the same thing for inferior/superior
    [~, sortInd] = sortrows(beads, 3);
    inferior = [0 0 0 0]; inferior(sortInd(1:2)) = 1;

    leftInferior = beads(left == 1 & inferior == 1, :);
    rightInferior = beads(left == 0 & inferior == 1,:);
    rightSuperior = beads(left == 0 & inferior == 0,:);
    
    outputMat = [rightInferior; rightSuperior; leftInferior];
    
    % change RAS mat to LPS to align with mesh
    outputMat = outputMat .* [-1 -1 1];
end