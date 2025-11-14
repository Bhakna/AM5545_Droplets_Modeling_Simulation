function [D1_, r1_, v1_, D2_, r2_, v2_, D3_, r3_, v3_] = ...
         collisionS(D1, r1, v1, D2, r2, v2, alpha, beta)
% masses
m1 = D1^3; m2 = D2^3; M = m1 + m2;

% satellite mass
m3 = alpha * M;

beta_ = (m1/m2)^beta;
m2_ = (1 - alpha) * (M / (beta_*m1 + m2)) * m2;
m1_ = M - m2_ - m3;

D1_ = m1_^(1/3); D2_ = m2_^(1/3); D3_ = m3^(1/3);

% collision frame
R = coordTransform(r2 - r1);

v1c = v1(:); v2c = v2(:);
v1s = R * v1c; v2s = R * v2c;

% big fragments separate along normal (preserve tangential comps)
v1s_new = v1s; v2s_new = v2s;
v1s_new(1) = +abs(v1s(1));
v2s_new(1) = -abs(v2s(1));

v1g = (R') * v1s_new;
v2g = (R') * v2s_new;

v1_ = v1g(:).';
v2_ = v2g(:).';

% momentum accounting for satellite
P_initial = m1 * v1 + m2 * v2;    % 1x3 row
P_big = m1_ * v1_ + m2_ * v2_;    % 1x3 row
P3 = P_initial - P_big;           % remaining momentum for satellite

% choose tangent direction (global)
tangent = R(:,2);  % 3x1 vector

% project remaining momentum on tangent; set satellite velocity along tangent
proj = dot(P3, tangent);
if abs(proj) < 1e-12
    v3c = 0.1 * tangent; % small default velocity if almost zero
else
    v3c = (proj / m3) * tangent;
end
v3_ = v3c(:).';

% satellite position (midpoint offset along tangent)
r1_ = r1; r2_ = r2;
offset = 0.5*(D1_ + D2_);
r3_ = (r1 + r2)/2 + (offset * tangent')./1.0;

% sanity checks
if ~isfinite(m1_) || m1_ <= 0 || ...
   ~isfinite(m2_) || m2_ <= 0 || ...
   ~isfinite(m3) || m3 <= 0

    % fallback: treat as bouncing
    [D1_, r1_, v1_, D2_, r2_, v2_] = collisionB(D1, r1, v1, D2, r2, v2);
    D3_ = []; r3_ = []; v3_ = [];
    return;

end

if any(~isfinite([r1_ r2_ r3_ v1_ v2_ v3_]), 'all')
    error('NaN generated inside collisionS');
end

end
