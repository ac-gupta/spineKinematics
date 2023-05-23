function R = rot(axis, angle, centerORsize)
% function R = rot(axis, angle, centerORsize)
%
% Calculate the 3x3 rotation matrix or the 4x4 homogeneous transformation
% matrix. The type of the returned matrix is controled by 'centerORsize'
% parameter.
%
%
% axis:         (The direction of) the axis of rotation.
%               1=x, 2=y, 3=z. Or the axis of rotation represented by a
%               3-vector (does not need to be normalized to length of 1).
%               See parameter 'centerORsize' for more info.
%
% angle:        in degrees.
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
%
% Examples:
%       30deg rotation about the y axis:
%           R = rot(2, 30, 3);    R = rot([0; 1; 0], 30, 3);
%           T = rot(2, 30, 4*4);
%       30deg rotation about axis x=z=1:
%           T = rot(2, 30, [1; 0; 1]);
%

% Author:     Shang Mu, 2008-2009.
% Revision:   v2. 2009-06-11

if nargin<3
    centerORsize = 3;
end;

sine = sind(angle);
cosine = cosd(angle);
R = rotsc(axis, sine, cosine, centerORsize);
