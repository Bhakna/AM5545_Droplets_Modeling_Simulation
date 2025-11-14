function [cellParticles, cellID, ncell] = buildCellList(r, L, cellSize)
% Build cell list for cubic domain with full safety

N = size(r,1);

% ----- SAFETY FOR cellSize -----
if ~isfinite(cellSize) || cellSize <= 0
    cellSize = L/50;             % fallback
end
cellSize = max(cellSize, L/50);  % lower bound
cellSize = min(cellSize, L/2);   % upper bound

% ----- COMPUTE NCELL -----
ncell = floor(L / cellSize);

% safety clamps
if ~isscalar(ncell) || ~isfinite(ncell)
    ncell = 10;
end
ncell = max(3, min(ncell, 100));

% recompute consistent cellSize
cellSize = L / ncell;

% ----- ALLOCATE -----
cellParticles = cell(ncell, ncell, ncell);
cellID        = zeros(N,3);

% ----- ASSIGN PARTICLES -----
for i = 1:N
    cx = floor(r(i,1) / cellSize) + 1;
    cy = floor(r(i,2) / cellSize) + 1;
    cz = floor(r(i,3) / cellSize) + 1;

    % periodic wrap
    cx = mod(cx-1, ncell) + 1;
    cy = mod(cy-1, ncell) + 1;
    cz = mod(cz-1, ncell) + 1;

    cellID(i,:) = [cx, cy, cz];
    cellParticles{cx,cy,cz}(end+1) = i;
end

end
