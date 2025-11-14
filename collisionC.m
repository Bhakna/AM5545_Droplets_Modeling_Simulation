function [D12, r12, v12] = collisionC(D1, r1, v1, D2, r2, v2)

% Compute post-coalescence properties for two spherical droplets
%
% INPUTS:
%   D1, D2 : diameters of droplets
%   r1, r2 : position vectors
%   v1, v2 : velocity vectors
%
% OUTPUTS:
%   D12 : diameter of merged droplet
%   r12 : center-of-mass position
%   v12 : center-of-mass velocity

%% Masses (proportional to volume)
m1 = D1^3;
m2 = D2^3;
m12 = m1 + m2;

%% New droplet size (volume conservation)
D12 = m12^(1/3);

%% Center of mass position
r12 = (m1*r1 + m2*r2) / m12;

%% Center of mass velocity (momentum conservation)
v12 = (m1*v1 + m2*v2) / m12;

end
