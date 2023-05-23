results(1:3) = (-  a(1:3,1:3).' * a(1:3, 4)).';
results(4:6) = getRotations(123, a)
