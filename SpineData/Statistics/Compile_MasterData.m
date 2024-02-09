%% Compile all raw mocap data

%% Add Paths
homePath = "C:/Users/acgis/Documents/GitHub/SpineKinematics/SpineData/";
% addpath(homePath + "Sample");
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
%% Set Patient Variables and Global Vars
patientCodes = {"Alpha", "Beta", "Charlie", "Delta", "Epsilon","Fred", "Gamma",...
    "Hector", "Iota", "Kappa"}; %#ok<CLARRSTR>

data = NaN(57, 6, 10);
%% Subject Loop
for p = 1:10 %10
    patientCode = char(patientCodes{p});
    disp(patientCode)
    %% Loop through patient directory

    if p ~= 10
        CAD_code = "/CAD_"+patientCode(1);
    else
        CAD_code = "/CAD_"+'J';
    end
        
    dirs = dir(mocapPath+CAD_code);
    trialName = string([]);
    
        for i = 1:numel(dirs)-2
            trialName(i) = string(dirs(i+2).name);
        end
    %% Trial Specific
    %patientPath = '/CAD_E/Cad_E_11-05-07/';
    
        for trial = 1:length(trialName)
            patientPath = CAD_code + "/" + trialName(trial);

            patientPath = char(patientPath);
            
            posePath = mocapPath + patientPath + "/Raw";
            
            opts = detectImportOptions(posePath);
            opts.SelectedVariableNames= [3,4,5,9,10,11];
            raw = readmatrix(posePath, opts);
            
            data(trial,:,p) = [mean(raw(:,4:6)-raw(:,1:3)) std(raw(:,4:6)-raw(:,1:3))];
        end
end
