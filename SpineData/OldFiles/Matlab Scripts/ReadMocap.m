%% parameters
function pose = ReadMocap(filename, seq, alignmentPath)

    fid = fopen(filename);
    C = textscan(fid, [repmat('%f', 1, 51)], 'HeaderLines', 12);

    markers = {'M1', 'M2', 'M3', 'M4'};
%     variable = {'x','y','z', 'az', 'el', 'ro'};

    marker.time = C{1};
    marker.frame = C{2};

    alignment = load(alignmentPath);
    
    ii = 3;
    for j = 1:4
            mark = markers{j};
        for n = 1:6
            marker.(mark)(:,n) = C{ii};
            ii = ii+1;
        end
        
        % change translation order
%         X = marker.(mark)(:,2);
%         marker.(mark)(:,1) = marker.(mark)(:,1);
%         marker.(mark)(:,2) = marker.(mark)(:,3);
%         marker.(mark)(:,3) = X;
%         
%         X = alignment(:,2);
%         alignment(:,1) = alignment(:,1);
%         alignment(:,2) = alignment(:,3);
%         alignment(:,3) = X;


    end
    
    alignMat = getAttMat([repmat(0,4,3), alignment(:,1), alignment(:,2), alignment(:,3)]);
        
        
    pose.C5 = getAttMat(marker.M1);
    pose.C6 = getAttMat(marker.M2);
        for n = 1:length(pose.C5)
%             pose.C5{n} = (pose.C5{n}) * inv(alignMat{1});
%             pose.C6{n} = (pose.C6{n}) * inv(alignMat{2});
%             

        end
 
end