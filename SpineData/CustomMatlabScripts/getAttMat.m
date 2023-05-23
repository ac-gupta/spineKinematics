function M = getAttMat(mocapData)

% create M{N} transformation matrices given the Nx6 array of XYZAER values.
% See the Attitude Matrix section of the Polhemus specifications.

N = height(mocapData);
M = cell(N,1);

for idx = 1:N
    M{idx} = zeros(4,4);
    
    CA = cosd(mocapData(idx, 4));
    CE = cosd(mocapData(idx, 5));
    CR = cosd(mocapData(idx, 6));
    
    SA = sind(mocapData(idx, 4));
    SE = sind(mocapData(idx, 5));
    SR = sind(mocapData(idx, 6));
    
    M{idx}(1:3,1:3) = [CA*CE, CA*SE*SR - SA*CR, CA*SE*CR + SA*SR; ...
                       SA*CE, CA*CR+SA*SE*SR,   SA*SE*CR - CA*SR; ...
                       -SE,   CE*SR,            CE*CR];
                   
    M{idx}(1:3,4) = mocapData(idx, 1:3).';
    M{idx}(4,4) = 1;
    
end