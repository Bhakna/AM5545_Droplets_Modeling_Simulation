function [D, r, v] = initDroplets(params)
Nreq = params.N;
L = params.L;
D0 = params.D0;

rng('shuffle');

r = zeros(Nreq,3);
D = zeros(Nreq,1);

i = 0;
attempts = 0;
maxAttempts = 5e5;

while i < Nreq && attempts < maxAttempts
    attempts = attempts + 1;
    cand = rand(1,3) * L;
    candD = D0;
    if params.polydisp
        candD = D0 * (1 + 0.1*(rand-0.5)); % ±5%
    end
    if i == 0
        i = 1;
        r(i,:) = cand;
        D(i) = candD;
    else
        dvecs = shortestDistanceVector(r(1:i,:), cand, L);
        dmins = sqrt(sum(dvecs.^2,2));
        if all(dmins >= 0.5*(candD + D(1:i)))
            i = i + 1;
            r(i,:) = cand;
            D(i) = candD;
        end
    end
end

if attempts >= maxAttempts
    warning('initDroplets: max attempts reached; produced %d droplets (requested %d)', i, Nreq);
    N = i;
    r = r(1:N,:);
    D = D(1:N);
else
    N = Nreq;
end

% velocities: zero mean gaussian rows
v = params.v_var * randn(N,3);
v = v - mean(v,1);

end
