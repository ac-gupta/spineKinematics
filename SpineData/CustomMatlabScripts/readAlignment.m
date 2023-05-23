function alignMat = readAlignment(filename)    
    
    fid = fopen(filename);
    C = textscan(fid, [repmat('%f', 1, 6)], 'HeaderLines', 12);
    
    alignMat = [C{4}(1:3) C{5}(1:3) C{6}(1:3)];
end