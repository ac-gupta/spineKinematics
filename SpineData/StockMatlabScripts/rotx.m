function R = rotx(angle, centerORsize)
% Calculate 3x3 rotation matrix or 4x4 homogeneous transformation matrix of
% a rotation about x axis(or an axis parallel to the x axis). See rot()
% function for more information.

% Author:     Shang Mu, 2008-2009.
% Revision:   v1. 2009-06-11


if nargin<2
    centerORsize = 3;
end;
R = rot(1, angle, centerORsize);
