function [We, B] = computeWeB(D1, D2, r1, r2, v1, v2, params)
Urel = v1 - v2;
Urel_mag = norm(Urel);
D_eq = 0.5*(D1 + D2);
We = params.rho * (Urel_mag^2) * D_eq / max(params.sigma, 1e-12);

% shortest center vector under periodic BC
rij = r2 - r1;
rij = rij - params.L * round(rij ./ params.L);

if Urel_mag < 1e-12
    % fallback: use perpendicular distance to arbitrary direction
    b = norm(rij - (dot(rij, [1 0 0]) * [1 0 0]));
else
    vhat = Urel / Urel_mag;
    bvec = rij - (dot(rij, vhat) * vhat);
    b = norm(bvec);
end

B = 2*b / (D1 + D2);
B = max(0, min(1.5, B));
end
