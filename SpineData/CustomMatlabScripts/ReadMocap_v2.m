%% parameters
function pose = ReadMocap_v2(filename)

    fid = fopen(filename);
    C = textscan(fid, [repmat('%f', 1, 51)], 'HeaderLines', 12);

    markers = {'M1', 'M2', 'M3', 'M4'};

    marker.time = C{1};
    marker.frame = C{2};
 
    ii = 3;
    for j = 1:4
            mark = markers{j};
        for n = 1:6
            marker.(mark)(:,n) = C{ii};
            ii = ii+1;
        end

    end
        
    pose.C5 = getAttMat(marker.M1);
    pose.C6 = getAttMat(marker.M2);
 
end