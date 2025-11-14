function neighbors = getNeighborCells(cID, ncell)
% Return list of 27 neighboring cells (including itself), with periodic wrap.

cx = cID(1); cy = cID(2); cz = cID(3);

% 3×3×3 neighbors
neighbors = zeros(27,3);
idx = 0;

for dx = -1:1
    for dy = -1:1
        for dz = -1:1
            nx = mod(cx-1+dx, ncell) + 1;
            ny = mod(cy-1+dy, ncell) + 1;
            nz = mod(cz-1+dz, ncell) + 1;
            idx = idx + 1;
            neighbors(idx,:) = [nx,ny,nz];
        end
    end
end
end
