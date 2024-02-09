homePath = "C:/Users/acgis/Documents/GitHub/SpineKinematics/SpineData/";
addpath(homePath + "MocapData");


mocapPath = homePath + "MocapData";
dirs = dir(mocapPath);

masterlist = ["Trial" "Protocol" "Trial" "Technique" "Collar"];

    for i = 1:10
       patient(i) = string(dirs(i+2).name);
      
       TrialDirs = dir(mocapPath + "/" + patient(i));
       for idx = 1:numel(TrialDirs)-2
           trials(idx) = string(TrialDirs(idx+2).name);
       
       
           posePath = mocapPath + "/" + patient(i) + "/" + trials(idx) + "/Raw";

%           if isfile(posePath+".txt")
%                continue
%           else
%                 copyfile(posePath+".xls", posePath+".txt");
%           end

           fid = fopen(posePath + ".txt");
           for line = 1:6
               protocol = fgets(fid);
           end
           
           protocol = char(protocol);
           protocol = protocol(10:end-6);
           
           
           details = strsplit(protocol, "_");
           technique = details{1}(5:end);
           if length(details) == 3
               technique = string(technique) + " " + string(details{2});
           end
           
           trial = string(details{1}(1:3));
           
           if details{end} == 'C'
                collar = "Y";
           else
                collar = "N";
           end
           

           masterlist(end+1,:) = [trials(idx) protocol trial technique collar];
           
       end
    end