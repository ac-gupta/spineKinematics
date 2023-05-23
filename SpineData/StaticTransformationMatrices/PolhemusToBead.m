%% Polhemus to Marker script

swTp.C5 = load("SWtoPolhemusC5.txt");
swTb.C5 = load("SWtoBeadC5.txt");

polTbead.C5 = inv(swTp.C5) * swTb.C5;

swTp.C6 = load("SWtoPolhemusC6.txt");
swTb.C6 = load("SWtoBeadC6.txt");

polTbead.C6 = inv(swTp.C6) * swTb.C6;

save('polhemusTbead.mat', 'polTbead');