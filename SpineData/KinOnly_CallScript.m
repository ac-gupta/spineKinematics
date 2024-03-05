%% Call Script

%% Add Paths
homePath = "C:/Users/acgis/Documents/GitHub/SpineKinematics/SpineData/";
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

rend  ="Y";
% frames = 1;
frames= 0;

%% Patient Specific

% patients = ["Alpha", "Beta", "Charlie", "Delta", "Epsilon",  "Fred",...
% "Gamma", "Hector", "Iota", "Kappa"];
% 
% trials = ["Cad_A_14-12-05", "Cad_B_11-10-50","Cad_D_13-44-42","Cad_E_11-05-07",...
% "Cad_F_16-44-38", "Cad_G_10-39-57","Cad_H_11-16-03","Cad_I_12-11-17",...
% "Cad_J_11-22-08"];

% patients = [ "Alpha", "Beta", "Epsilon", "Hector"];
% 

% beta:xlim([100 230]);ylim([-95 25]);zlim([-250 -120]);
% epsilon: xlim([-50 250]); ylim([0150 150]); zlim([-300 0]); 
% hector: xlim([-40 260]); ylim([-175 125]); zlim([-125 175]);
% xyz limits
Limits = [-50 250 -150 150 -375 -75; ...%ALPHA
          50 280 -145 75 -300 -70; ... %BETA    
          0 0 0 0 0 0; ...              %CHARLIE
          0 0 0 0 0 0; ...              %DELTA
          -50 250 -150 150 -300 0; ...  %EPSILON
          0 0 0 0 0 0; ...              %FRED
          0 0 0 0 0 0; ...              %GAMMA
          -40 260 -175 125 -125 175; ...%HECTOR
          0 0 0 0 0 0; ...              %IOTA
          0 150 -70 80 -250 -100; ...   %Kappa
          -25 170 -100 100 -275 -75];...% kappa/hector bones

          
      
trials = [ "Cad_A_14-12-05","Cad_B_11-10-50","Cad_E_11-05-07",...
"Cad_H_11-16-03"];



patientCode = 'Charlie';
trial = char(trials(1));
lims = Limits(5,:);
pat = 2;
STLCode = 'Alpha';
suffix = "_AlphaBones2Hz";



%  %% No Loop
    patientCode = char(patientCode);
    trialName = char(trial); 
    
% %% 
if STLCode(1) == 'K'
    CAD_code = "/Cad_J";
else
    CAD_code = "/CAD_"+patientCode(1);
end

% set output dir
outDir =  homePath + 'ProcessedData/' + patientCode;

    if ~exist(outDir, 'dir')
        mkdir(outDir)
    end
addpath(outDir)
% Find STL files
addpath(CADPath)
dirs = dir(mocapPath+CAD_code);

STLdir = [char(CADPath) '/' STLCode];
boneFiles = {[STLdir 'STL/'  STLCode '_C5.stl'], [STLdir 'STL/' STLCode '_C6.stl'], ...
    [STLdir '/' STLCode '_C5.txt'], [STLdir '/' STLCode '_C6.txt']};

beadFiles = {[STLdir 'STL/'  STLCode '_C5_beads.stl'], [STLdir 'STL/' STLCode '_C6_beads.stl'], ...
    [STLdir '/' STLCode '_C5_beads.txt'], [STLdir '/' STLCode '_C6_beads.txt']};    


boneFiles = string(boneFiles);
beadFiles = string(beadFiles);
% % 
% % %% Loop through patient directory
% 
% No Loop Code

% Trial Specific
%patientPath = '/CAD_E/Cad_E_11-05-07/';

patientPath = CAD_code + "/" + trialName;

patientPath = char(patientPath);

%% set output path
% e.g., ../GitHub/spineKinematics/SpineData/ProcessedData/Epsilon

% name of output render (will output videos Cad_B_11-10-50_render.mp4 and _sac.mp4)
outputPath = strsplit(patientPath, '/');
outputPath = outDir + "/" +  string(outputPath{3}) + suffix;
%% Choose files

posePath = mocapPath + patientPath + "/Raw";

check.truth = "N";

[dist, C6toC5, results, C5Inf, C6Sup] = spineProcessing_KinOnly(...
    posePath, boneFiles, beadFiles, rend, outputPath, check.truth, check, polTbead, frames, lims);


 %% Loop Code
% % % if string(patientCode) == "Kappa"
% % %     CAD_code = "/Cad_J";
% % % else
% % %     CAD_code = "/CAD_"+patientCode(1);
% % % end
% % % % % set output dir
% % % outDir =  homePath + 'ProcessedData/' + patientCode;
% % %  
% % %  dirs = dir(mocapPath+CAD_code);
% % %  
% % %     if ~exist(outDir, 'dir')
% % %         mkdir(outDir)
% % %     end
% % % addpath(outDir)
% % % % Find STL files
% % % addpath(CADPath)
% % % 
% % % STLdir = [char(CADPath) '/' patientCode];
% % % boneFiles = {[STLdir 'STL/'  patientCode '_C5_dec.stl'], [STLdir 'STL/' patientCode '_C6_dec.stl'], ...
% % %     [STLdir '/' patientCode '_C5.txt'], [STLdir '/' patientCode '_C6.txt']};
% % % 
% % % beadFiles = {[STLdir 'STL/'  patientCode '_C5_beads.stl'], [STLdir 'STL/' patientCode '_C6_beads.stl'], ...
% % %     [STLdir '/' patientCode '_C5_beads.txt'], [STLdir '/' patientCode '_C6_beads.txt']};    
% % % 
% % % 
% % % boneFiles = string(boneFiles);
% % % beadFiles = string(beadFiles);

%     for i = 1:numel(dirs)-2
%         trialName(i) = string(dirs(i+2).name);
%     end
    
% % Trial Specific
% %patientPath = '/CAD_E/Cad_E_11-05-07/';
% try
%     for trial = 1:length(trialName)
% 
%         patientPath = CAD_code + "/" + trialName(trial);
% 
%         patientPath = char(patientPath);
% 
%         %% set output path
%         % e.g., ../GitHub/spineKinematics/SpineData/ProcessedData/Epsilon
% 
%         % name of output render (will output videos Cad_B_11-10-50_render.mp4 and _sac.mp4)
%         outputPath = strsplit(patientPath, '/');
%         outputPath = outDir + "/" +  string(outputPath{3}) + "_2HzHectorBones";
%         %% Choose files
% 
%         posePath = mocapPath + patientPath + "/Raw";
% 
%         check.truth = "N";
%         
%         [dist, C6toC5, results, C5Inf, C6Sup] = spineProcessing_KinOnly(...
%             posePath, boneFiles, beadFiles, rend, outputPath, check.truth, check, polTbead, frames, lims);
%     end
% 
% catch ME
%     fprintf("Error at patient: %s", trialName(trial));
%     fprintf('Line %d: Error Message:\n%s', ...
%     ME.stack(1).line, ME.message);
% end    
% % end
%    