function rotations = getRotations(sequence, matrix, rangerot2)
% Calculate the corresponding Euler angles from a 3x3 rotation matrix using
% the specified sequence.

% Note that this program follow the convention in the field of robotics:
% We use column vectors (not row vectors) to denote vectors/points in 3D
% Euclidean space. E.g.
% V_global = R * V_local
% where R is a 3x3 rotation matrix, and V_* are 3x1 column vectors.
% And in this convention, for example, an R_z (rotation about z axis) is
% [c -s 0; s c 0; 0 0 1] and NOT [c s 0; -s c 0; 0 0 1],(c=cosine, s=sine).
% 
% We also acknowledge that Euler angle rotations are always about the axes
% of the local coordinate system, never the global coordinate system. (If
% you would rather recognize the existence of Euler angles with "global
% coordinate system based rotations" and further confuse people in the
% world: simply reverse the order: an x(3degrees)-y(4deg)-z(5deg)
% "global-base-rotation" is simply a z(5)-y(4)-x(3)
% "local-based-rotation".) Following the equation and convention above, an
% x-y-z(1-2-3) Euler angle sequence would mean
% V_global = R * V_local
%          = R_x * R_y * R_z * V_local
%
%
% sequence:  The rotation sequence used for output. e.g. 312.
% matrix:    The 3x3 rotation matrix (the so-called Direction Cosine Matrix,
%            DCM). Or any matrix with the first 3 rows and columns being
%            the rotation matrix, so you can just input the 4x4 homogeneous  
%            transformation matrix here.
% rangerot2: Optional. The range of the 2nd rotation in output. It should
%            be a value of 0(default) or 1. For symmetric Euler sequences:
%            if rangerot2==0, the 2nd rotation is in the range [0,pi]; if
%            rangerot2==1, the range is [-pi,0]. For asymmetric Euler
%            sequences: if rangerot2==0, the 2nd rotation is in the range
%            [-pi/2,pi/2]; if rangerot2==1, the range is [pi/2, pi*3/2].

%{
            //For asymmetric Euler sequences, the output of the second rotation
            // is in the range [-pi/2,pi/2], the other two rotations are in the
            // range [-pi, pi]. When the second rotation is -pi/2
            // or pi/2, singularity occurs.

            //For symmetric Euler sequences, the output of the second rotation
            // is in the range [0,pi], the other two rotations are in the
            // range [-pi, pi]. When the second rotation is 0
            // or pi, singularity occurs.
%}

% Author:     Shang Mu, 2005-2010.
% Revision:   v8, 2010-05-23. 2010-07-08 (fix spelling in comments only).


% code explanation:
% Numbers means the position of the rotation in the whole sequence.
% c: cosine    s: sine    rot: rotation
% Examples:
%  c1: cosine of the 1st rotation.
%  s2: sine of the 2nd rotation.


if ~exist('rangerot2', 'var') || isempty(rangerot2)
%if nargin < 3 || isempty(rangerot2)
    rangerot2 = 0;
else
    if ~isequal(rangerot2, 0) && ~isequal(rangerot2, 1)
        error('Invalid value for parameter rangerot2');
    end
end;

M = matrix;
switch sequence
    case 123
        s2 = M(1,3);    % y rot
        if (rangerot2==0)
            rot2 = asin(s2);
        else
            rot2 = pi-asin(s2);
        end
        if s2==1 || s2==-1   % singularity
            rot1 = 0;    %// we make the first rotation zero.
            rot3 = atan2( M(2,1), M(2,2) );
        else
            if (rangerot2==0)
                rot1 = atan2( -M(2,3), M(3,3) );    % x rot
                rot3 = atan2( -M(1,2), M(1,1) );    % z rot
            else
                rot1 = atan2( M(2,3), -M(3,3) );    % x rot
                rot3 = atan2( M(1,2), -M(1,1) );    % z rot
            end
        end
    case 231
        s2 = M(2,1);    % z rot
        if (rangerot2==0)
            rot2 = asin(s2);
        else
            rot2 = pi-asin(s2);
        end
        if s2==1 || s2==-1   % singularity
            rot1 = 0;    %// we make the first rotation zero.
            rot3 = atan2( M(3,2), M(3,3) );
        else
            if (rangerot2==0)
                rot1 = atan2( -M(3,1), M(1,1) );    % y rot
                rot3 = atan2( -M(2,3), M(2,2) );    % x rot
            else
                rot1 = atan2( M(3,1), -M(1,1) );    % y rot
                rot3 = atan2( M(2,3), -M(2,2) );    % x rot
            end
        end
    case 312
        s2 = M(3,2);  % x rot
        if (rangerot2==0)
            rot2 = asin(s2);
        else
            rot2 = pi-asin(s2);
        end
        if s2==1 || s2==-1   % singularity
            rot1 = 0;    %// we make the first rotation zero.
            rot3 = atan2( M(1,3), M(1,1) );
        else
            if (rangerot2==0)
                rot1 = atan2( -M(1,2), M(2,2) );    % z rot
                rot3 = atan2( -M(3,1), M(3,3) );    % y rot
            else
                rot1 = atan2( M(1,2), -M(2,2) );    % z rot
                rot3 = atan2( M(3,1), -M(3,3) );    % y rot
            end
        end
    case 213
        s2 = -M(2,3);  % x rot
        if (rangerot2==0)
            rot2 = asin(s2);
        else
            rot2 = pi-asin(s2);
        end
        if s2==1 || s2==-1   % singularity
            rot1 = 0;    %// we make the first rotation zero.
            rot3 = atan2( -M(1,2), M(1,1) );
        else
            if (rangerot2==0)
                rot1 = atan2( M(1,3), M(3,3) );    % y rot
                rot3 = atan2( M(2,1), M(2,2) );    % z rot
            else
                rot1 = atan2( -M(1,3), -M(3,3) );    % y rot
                rot3 = atan2( -M(2,1), -M(2,2) );    % z rot
            end
        end
    case 232
        c2 = M(2,2);    % z rot
        if (rangerot2==0)
            rot2 = acos(c2);
        else
            rot2 = -acos(c2);
        end
        if c2==1 || c2==-1   % singularity
            rot1 = 0;    %// we make the first rotation zero.
            rot3 = atan2( -M(3,1), M(3,3) );
        else
            if (rangerot2==0)
                rot1 = atan2( M(3,2), -M(1,2) );
                rot3 = atan2( M(2,3), M(2,1) );
            else
                rot1 = atan2( -M(3,2), M(1,2) );
                rot3 = atan2( -M(2,3), -M(2,1) );
            end
        end
    case 313
        c2 = M(3,3);    % x rot
        if (rangerot2==0)
            rot2 = acos(c2);
        else
            rot2 = -acos(c2);
        end
        if c2==1 || c2==-1   % singularity
            rot1 = 0;    %// we make the first rotation zero.
            rot3 = atan2( -M(1,2), M(1,1) );
        else
            if (rangerot2==0)
                rot1 = atan2( M(1,3), -M(2,3) );
                rot3 = atan2( M(3,1), M(3,2) );
            else
                rot1 = atan2( -M(1,3), M(2,3) );
                rot3 = atan2( -M(3,1), -M(3,2) );
            end
        end
    case 212
        c2 = M(2,2);    % x rot
        if (rangerot2==0)
            rot2 = acos(c2);
        else
            rot2 = -acos(c2);
        end
        if c2==1 || c2==-1   % singularity
            rot1 = 0;    %// we make the first rotation zero.
            rot3 = atan2( M(1,3), M(1,1) );
        else
            if (rangerot2==0)
                rot1 = atan2( M(1,2), M(3,2));
                rot3 = atan2( M(2,1), -M(2,3) );
            else
                rot1 = atan2( -M(1,2), -M(3,2));
                rot3 = atan2( -M(2,1), M(2,3) );
            end
        end
    otherwise
        disp('getRotations(): sequence not supported yet');
        rotations = NaN;
        return;
end;
rotations = rad2deg([rot1, rot2, rot3]);

%%%%%%%%%
% Sidenote:
% 
% There are many ways to simplify this program:
% 
% Preliminary (for methods 1 and 2):
% The 12 different Euler angle sequences can be divided into 4 groups:
% (123, 231, 312), (321, 213, 132) , (121, 232, 313), (323, 212, 131).
% (The first two groups can be further combined to a single one using
% method 3 below. Similarly the last two groups can be united by method 4.) 
% 
% Simplification method 1:
% Basic idea: if I have two different coordinate systems on the same rigid
% body, an x-rotation seen from one coordinate system can be a y-rotation
% in the other coordinate system.
% The tool is a rotation matrix:
%   rot120 = [
%      0     0     1
%      1     0     0
%      0     1     0
%   ];  (a shift of axis indices, or a 120 degree rotation about [1 1 1]).
% For any sequence, the three Euler angles can be easily calculated using
% the same program for any other sequence in the same group (as defined in
% the "preliminary" section). For example (assuming M is 3x3):
% getRotations(123, M) == getRotations(312, rot120.'*M*rot120)
%                      == getRotations(231, rot120*M*rot120.');
% getRotations(232, M) == getRotations(121, rot120.'*M*rot120)
%                      == getRotations(313, rot120*M*rot120.').
% 
% Simplification method 2:
% There are rules we can follow. For example, s2 or c2 (sine or cosine of
% the 2nd rotation) is always at the (1st rot)(3rd rot) element in the
% rotation matrix. The four groups we saw above are the only variations we
% need to take care of.
% 
% Simplification method 3:
% An A-B-C order Euler angle rotations of a body EE with respect to some
% fixed body FF, can be seen as a C-B-A order rotations of the body FF with 
% respect to the body EE (but with the negative angles). For example
% (assuming M is 3x3):
% getRotations(123, M) == -getRotations(321, M.')(end:-1:1);
% getRotations(312, M) == -getRotations(213, M.')(end:-1:1).
% 
% Simplification method 4:
% Similar to method 1, a relabel of axes utilizing 90 degree rotations is
% extremely useful for the symmetrical sequences. A 90 degree rotation
% about either of the two axes in a symmetrical sequence would result in a
% new valid sequence. For example:
% getRotations(212, M) == getRotations(232, roty(90).'*M*roty(90))
%                      == getRotations(313, rotx(-90).'*M*rotx(-90)).
% This essentially unites all the symmetric sequences.
% This method could also be used on the asymmetric sequences, but care
% must be taken to negate the sign of individual angles.
% 

