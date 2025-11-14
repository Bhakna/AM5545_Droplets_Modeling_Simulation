function [D1_, r1_, v1_, D2_, r2_, v2_] = collisionB(D1, r1, v1, D2, r2, v2)
D1_ = D1; D2_ = D2;
m1 = D1^3; m2 = D2^3;

% get transform
R = coordTransform(r2 - r1);

% columnise velocities for math
v1c = v1(:);
v2c = v2(:);

v1s = R * v1c;
v2s = R * v2c;

v1n = v1s(1); v2n = v2s(1);

% correct 1D elastic collision
v1n_new = ((m1 - m2)/(m1 + m2))*v1n + (2*m2/(m1 + m2))*v2n;
v2n_new = ((m2 - m1)/(m1 + m2))*v2n + (2*m1/(m1 + m2))*v1n;

v1s(1) = v1n_new;
v2s(1) = v2n_new;

% back to global and to row format
v1g = (R') * v1s;
v2g = (R') * v2s;

v1_ = v1g(:).';
v2_ = v2g(:).';

r1_ = r1; r2_ = r2;
end
