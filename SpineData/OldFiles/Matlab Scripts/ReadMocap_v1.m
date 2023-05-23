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
        marker.(mark)(:,4:6) = marker.(mark)(:, 4:6) - alignment(j, :);
        
        % change translation order
        X = marker.(mark)(:,1);
        marker.(mark)(:,1) = marker.(mark)(:,2);
        marker.(mark)(:,3) = marker.(mark)(:,3);
        marker.(mark)(:,2) = X;

    end

%     for ind = 1:length(marker.M1)
%         pose.C5{ind} = getMat(marker.M1(ind,1), marker.M1(ind,2), marker.M1(ind,3),...
%             marker.M1(ind,4), marker.M1(ind,5), marker.M1(ind,6));
% 
%         pose.C6{ind} = getMat(marker.M2(ind,1), marker.M2(ind,2), marker.M2(ind,3),...
%             marker.M2(ind,4), marker.M2(ind,5), marker.M2(ind,6));
%     end

%     figure()
%         plot(marker.M1(:,4), 'b.-')
%         hold on
%         plot(marker.M2(:,4), 'b-')
%         
%         plot(marker.M1(:,5), 'r.-')
%         plot(marker.M2(:,5), 'r-')
%         
%         plot(marker.M1(:,6), 'k.-')
%         plot(marker.M2(:,6), 'k-')
        
        
    pose.C5 = getAttMat(marker.M1);

    pose.C6 = getAttMat(marker.M2);



% 
%     function M = getMat(x, y, z, az, el, ro)
%         M = zeros(4,4);
% 
%         M(1,1) = -sind(az)*sind(el)*sind(ro) + cosd(az)*cosd(ro);
%         M(1,2) = -sind(az)*cosd(el);
%         M(1,3) = sind(az)*sind(el)*cosd(ro) + sind(ro)*cosd(az);
% 
%         M(2,1) = sind(az)*cosd(ro) + sind(el)*sind(ro)*cosd(az);
%         M(2,2) = cosd(az)*cosd(el);
%         M(2,3) = sind(az)*sind(ro) - sind(el)*cosd(az)*cosd(ro);
% 
%         M(3,1) = -sind(ro)*cosd(el);
%         M(3,2) = sin(el);
%         M(3,3) = cosd(el)*cosd(ro);
% 
%         M(1:3, 4) = [x;y;z];
%         M(4,4) = 1;
%         
%         
% 
%     end


    % %% plot marker pos
    % close all
    % figure()
    % ax = axes();
    % view(ax, 3);
    % xlim([50,250])
    % ylim([0 , 35])
    % zlim([-260, 80])
    % 
    % markerStyle = {'r*', 'g*', 'b*', 'k*'};
    % for ii = 1:length(marker.time)
    %     plot3(marker.M1.x(ii), marker.M1.y(ii), marker.M1.z(ii), markerStyle{1});
    %     hold on
    %     
    %     for n = 2:4
    %         mark = markers{n};
    %         style = markerStyle{n};
    %         
    %         plot3(marker.(mark).x(ii), marker.(mark).y(ii), marker.(mark).z(ii), style);
    %     end
    %     
    %     pause
    %     set(gca, 'nextplot', 'replacechildren')
    % end
end