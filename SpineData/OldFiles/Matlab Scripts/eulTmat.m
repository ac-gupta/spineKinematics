
%relative F1
jts = [-23.3344 3.425732 -43.2182 -1.47042 -0.00837 -0.4903];

% %M1
% jts = [54.9876595	7.8824663	-253.28022	1.3196645	34.3542099	15.815774];

% %M2
% jts = [76.8926287	4.9285311	-209.2860413	-8.0869875	39.292263	-175.9172058];

    CA = cosd(jts(4));
    CE = cosd(jts(5));
    CR = cosd(jts(6));
    
    SA = sind(jts(4));
    SE = sind(jts(5));
    SR = sind(jts(6));
    
    M(1:3,1:3) = [CA*CE, CA*SE*SR - SA*CR, CA*SE*CR + SA*SR; ...
                  SA*CE, CA*CR+SA*SE*SR,   SA*SE*CR - CA*SR; ...
                  -SE,   CE*SR,            CE*CR];
                   
    M(1:3,4) = jts(idx, 1:3).';
    M(4,4) = 1

    