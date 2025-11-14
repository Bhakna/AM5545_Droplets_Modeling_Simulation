function r_out = applyPeriodic(r, L)
% applyPeriodic: wrap positions into [0, L] under periodic BCs
% r : N×3
r_out = mod(r, L); % robust for negative/positive values
end
