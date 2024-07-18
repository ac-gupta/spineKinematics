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
    
    % check that the roll on M2 hasn't caused wrapping issues
    % visualize for now
%     figure()
%     plot(marker.M2(:,6)); hold on;
%   
if range(marker.M2(:,6)) > 180
    marker.M2((marker.M2(:,6)<-170),6) = marker.M2((marker.M2(:,6)<-170),6) + 360;
end
%     plot(marker.M2(:,6)); 
    
    %% filter data
    
    fs = 100; % Hz; original sample freq
    ds = 20; % Hz; downsampled freq
    Ny = ds/2; % Nyquist freq for lowpass filter
    
    for j = 1:2
        mark = markers{j};
        marker.(mark) = lowpass(marker.(mark), Ny, fs);
        marker.(mark) = marker.(mark)(1:fs/ds:end,:);
    end
    
    marker.time = marker.time(1:fs/ds:end,:);
    marker.frame=  marker.frame(1:fs/ds:end,:);
%      
    %%    
    pose.C5 = getAttMat(marker.M1);
    pose.C6 = getAttMat(marker.M2);
 
end