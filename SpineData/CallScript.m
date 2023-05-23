%% Call Script

%% Add Paths

addpath('C:/Users/acgis/Documents/GitHub/spineKinematics/SpineData/Sample');
addpath('C:/Users/acgis/Documents/GitHub/spineKinematics/SpineData/StockMatlabScripts');
addpath('C:/Users/acgis/Documents/GitHub/spineKinematics/SpineData/CustomMatlabScripts');
addpath('C:/Users/acgis/Documents/GitHub/spineKinematics/SpineData/StaticTransformationMatrices');

mocapPath = 'C:\Users\acgis\Documents\GitHub\spineKinematics\SpineData\MocapData';
CADPath = 'C:/Users/acgis/Documents/GitHub/spineKinematics/SpineData/CTSegmentations';

warning('off', 'all')
%% Patient Specific

patientCode = 'Alpha';
patientPath = '\CAD_A\Cad_A_14-15-09\';

% name of output render (will output videos _render.mp4 and _sac.mp4)
videoPath = string([patientPath 'output']);
%% Choose files

alignmentPath = [mocapPath patientPath 'Alignment.txt'];
posePath = [mocapPath patientPath 'Raw.txt'];

% Turn XLS into TXT
copyfile([mocapPath patientPath 'Alignment.xls'], alignmentPath);
copyfile([mocapPath patientPath 'Raw.xls'], posePath);

% Find STL files
addpath(CADPath)

STLdir = [CADPath '\' patientCode];
boneFiles = {[STLdir 'STL\'  patientCode '_C5.stl'], [STLdir 'STL\' patientCode '_C6.stl'], ...
    [STLdir '\' patientCode '_C5.txt'], [STLdir '\' patientCode '_C6.txt']};

beadFiles = {[STLdir 'STL\'  patientCode '_C5_beads.stl'], [STLdir 'STL\' patientCode '_C6_beads.stl'], ...
    [STLdir '\' patientCode '_C5_beads.txt'], [STLdir '\' patientCode '_C6_beads.txt']};    

polhemusFiles = {[CADPath 'C5_PolhemusShelf.stl'], [CADPath 'C6_Pair.stl']};

boneFiles = string(boneFiles);
beadFiles = string(beadFiles);
polhemusFiles = string(polhemusFiles);

%once I know outputs wanted, this will be a function not a run statement
run('C:\Users\acgis\Documents\GitHub\spineKinematics\SpineData\SpineScript_Fuctionized.m')