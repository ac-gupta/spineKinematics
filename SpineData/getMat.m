function M = getMat(mocapData, seq)

% create M{N} transformation matrices given the Nx6 array of
% xyz az, el, ro values and [3,1,2] sequence

N = length(mocapData);
M = cell(N,1);

for idx =  1:N
    M{idx} = zeros(4,4);
    
    M{idx}(1:3, 1:3) = rot(seq(1),mocapData(idx,4))*rot(seq(2),mocapData(idx,5))*rot(seq(3),mocapData(idx,6));
    M{idx}(1:3,4) = mocapData(idx, 1:3).';
    M{idx}(4,4) = 1;
end

end

function R = rot(axis, angle)

% function R = rot(axis, angle)
%
% The sine-cosine version of rot().
% Calculate the 3x3 rotation matrix or the 4x4 homogeneous transformation
% matrix. The type of the returned matrix is controled by 'centerORsize'
% parameter.
%
% axis:         (The direction of) the axis of rotation.
%               1=x, 2=y, 3=z. Or the axis of rotation represented by a
%               3-vector (does not need to be normalized to length of 1).
%               See parameter 'centerORsize' for more info.
%
% sine, cosine: Rotation angle's sine and cosine.
%
% centerORsize: Optional. Center of rotation (i.e., a point on the axis of
%               rotation), or the size of the returned matrix.
%               # If a ceter of rotation is provided, the returned matrix
%                 will be a 4x4 transformation matrix.
%               # If omitted, or the specified value is a scalar, center of
%                 rotation is assumed to be at [0,0,0]. The scalar is
%                 interpreted as the desired size of the returned matrix,
%                 and can be the value of 3, 4, 9(i.e. 3*3), or 16.
%                 If omitted, the returned matrix is a 3x3 rotation matrix. 
%

% Author:     Shang Mu, 2008-2009.
% Revision:   v2. 2009-06-11


centerORsize = 3;

c = cosd(angle);
s = sind(angle);
v = 1-c;
if length(axis)==1
    m = zeros(3,1);
    m(axis) = 1;
else
    m = axis(1:3);
    m = m / norm(m);
end

% rotation part of the matrix
if length(centerORsize)==1 && (centerORsize==3 || centerORsize==9)
    R = [...
        m(1)*m(1)*v+c       m(1)*m(2)*v-m(3)*s  m(1)*m(3)*v+m(2)*s
        m(1)*m(2)*v+m(3)*s  m(2)*m(2)*v+c       m(2)*m(3)*v-m(1)*s
        m(1)*m(3)*v-m(2)*s  m(2)*m(3)*v+m(1)*s  m(3)*m(3)*v+c
        ];
    return;
else
    if length(centerORsize)==1 && centerORsize~=4 && centerORsize~=16
        error('rot()/rotsc(): Invalid centerORsize parameter.');
    end
    R = [...
        m(1)*m(1)*v+c       m(1)*m(2)*v-m(3)*s  m(1)*m(3)*v+m(2)*s  0
        m(1)*m(2)*v+m(3)*s  m(2)*m(2)*v+c       m(2)*m(3)*v-m(1)*s  0
        m(1)*m(3)*v-m(2)*s  m(2)*m(3)*v+m(1)*s  m(3)*m(3)*v+c       0
        0                   0                   0                   1
        ];
end

% add the translational part

%     t = origin;
%     R(1:3,4) = t;
%     tmp = eye(4);
%     tmp(1:3,4) = -t;
%     R = R*tmp;
%     %{
%    The preceding 4 lines is equivalent to
%     R = [...
%         1 0 0 t(1)
%         0 1 0 t(2)
%         0 0 1 t(3)
%         0 0 0 1
%         ] * ...
%         R * ...
%         [ ...
%         1 0 0 -t(1)
%         0 1 0 -t(2)
%         0 0 1 -t(3)
%         0 0 0 1
%         ];
%     %}
% % end

% Note: writing a separate specialized version for x/y/z rotation just for
% performance is pointless, because the only costly operation in this
% general approach is the norm() operation and Matlab's own overhead for
% each function call. (tested on Matlab 7.1).
end
