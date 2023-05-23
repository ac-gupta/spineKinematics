function [imgArr] = readDicom(dicomDir)

files = ls(dicomDir);

for n = 3:length(files)
    file = files(n,:);
    
    t = Tiff(file);
    
    imgArr(:,:,n-2) = read(t);
end