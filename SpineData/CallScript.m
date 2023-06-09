%% Call Script

%% Add Paths
homePath = "C:/Users/acgis/Documents/GitHub/SpineKinematics/SpineData/";
addpath(homePath + "Sample");
addpath(homePath + "StockMatlabScripts");
addpath(homePath + "CustomMatlabScripts");
addpath(homePath + "StaticTransformationMatrices");
mocapPath = homePath + 'MocapData';
CADPath = homePath + 'CTSegmentations';

addpath(mocapPath)

% load pol2bead matrices (static)
polTbead = load("polhemusTBeadV2.mat");
    polTbead = polTbead.polTbead;

warning('off', 'all')
%% Patient Specific

patientCode = 'Epsilon';

% set output dir
outDir =  homePath + 'ProcessedData/' + patientCode;

    if ~exist(outDir, 'dir')
        mkdir(outDir)
    end
addpath(outDir)
% Find STL files
addpath(CADPath)

STLdir = [char(CADPath) '/' patientCode];
boneFiles = {[STLdir 'STL/'  patientCode '_C5.stl'], [STLdir 'STL/' patientCode '_C6.stl'], ...
    [STLdir '/' patientCode '_C5.txt'], [STLdir '/' patientCode '_C6.txt']};

beadFiles = {[STLdir 'STL/'  patientCode '_C5_beads.stl'], [STLdir 'STL/' patientCode '_C6_beads.stl'], ...
    [STLdir '/' patientCode '_C5_beads.txt'], [STLdir '/' patientCode '_C6_beads.txt']};    


boneFiles = string(boneFiles);
beadFiles = string(beadFiles);

%% Loop through patient directory

CAD_code = "/CAD_"+patientCode(1);
dirs = dir(mocapPath+CAD_code);

    for i = 1:numel(dirs)-2
        trialName(i) = string(dirs(i+2).name);
    end
%% Trial Specific
%patientPath = '/CAD_E/Cad_E_11-05-07/';

try
    for trial = 7:length(trialName)
        patientPath = CAD_code + "/" + trialName(trial);

        patientPath = char(patientPath);

        %% set output path
        % e.g., ../GitHub/spineKinematics/SpineData/ProcessedData/Epsilon

        % name of output render (will output videos Cad_B_11-10-50_render.mp4 and _sac.mp4)
        outputPath = strsplit(patientPath, '/');
        outputPath = outDir + "/" + string(outputPath{3});
        %% Choose files

        posePath = mocapPath + patientPath + "/Raw";

        % Turn XLS into TXT
        if isfile(posePath+".txt")
            continue
        else
            copyfile(posePath+".xls", posePath+".txt");
        end

        if trial == 7
            check.start = 1062;
            check.distraction = importdata('Cad_E_11-23-13_distraction_check1062.txt');
            check.sacMM = num2cell(importdata('Cad_E_11-23-13_sacMM_check1062.txt'));
            
            check.truth = "Y";
        else
            check.truth = "N";
        end
        
        [distraction, sacMM, ~, check] = spineProcessing(...
            posePath, boneFiles, beadFiles, outputPath, "N", check.truth, check, polTbead);
        
        if check ~= []
            savemat(outputPath+"_checkpoint", check);
        end

        writematrix(distraction, outputPath+"_distraction.txt");
        writematrix(cell2mat(sacMM), outputPath+"_sacMM");
    
    end

catch ME
    fprintf("Error at patient: %s", trialName(trial));
    fprintf('Line %d: Error Message:\n%s', ...
    ME.stack(1).line, ME.message);
end

    