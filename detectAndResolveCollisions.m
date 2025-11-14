function [D, r, v] = detectAndResolveCollisions(D, r, v, params)

N = size(r,1);

% ------------ BUILD CELL LIST ONCE ------------
cellSize = max(2*mean(D), params.L / 20);
ncell    = max(3, min(floor(params.L / cellSize), 30));
cellSize = params.L / ncell;

[cellParticles, cellID, ncell] = buildCellList(r, params.L, cellSize);

% ------------ COLLISION LOOP ------------
i = 1;
while i <= N

    cID = cellID(i,:);
    neighbors = getNeighborCells(cID, ncell);

    for nb = 1:27
        c = neighbors(nb,:);
        plist = cellParticles{c(1),c(2),c(3)};
        if isempty(plist), continue; end

        for pj = plist
            if pj <= i || pj > N, continue; end

            j = pj;

            % minimum image
            rij = r(j,:) - r(i,:);
            rij = rij - params.L * round(rij ./ params.L);
            if norm(rij) > (D(i)+D(j))/2
                continue;
            end

            % ---- COLLISION FOUND ----
            [We, B] = computeWeB(D(i), D(j), r(i,:), r(j,:), v(i,:), v(j,:), params);
            out = collisionType(We, B, params.nomData);

            switch out
                case 'C'  % coalescence
                    [Dnew,rnew,vnew] = collisionC(D(i),r(i,:),v(i,:), D(j),r(j,:),v(j,:));
                    D(i)=Dnew; r(i,:)=rnew; v(i,:)=vnew;

                    D(j)=[]; r(j,:)=[]; v(j,:)=[];
                    return   % <<< IMMEDIATELY EXIT

                case 'B'
                    [D1,r1,v1, D2,r2,v2] = ...
                        collisionB(D(i),r(i,:),v(i,:), D(j),r(j,:),v(j,:));
                    D(i)=D1; r(i,:)=r1; v(i,:)=v1;
                    D(j)=D2; r(j,:)=r2; v(j,:)=v2;
                    return   % <<< EXIT (system changed)

                case 'S'
                    [D1,r1,v1, D2,r2,v2, D3,r3,v3] = ...
                        collisionS(D(i),r(i,:),v(i,:), D(j),r(j,:),v(j,:), 0.025, 0.75);

                    D(i)=D1; r(i,:)=r1; v(i,:)=v1;
                    D(j)=D2; r(j,:)=r2; v(j,:)=v2;

                    % add new small droplet
                    D(end+1)=D3; r(end+1,:)=r3; v(end+1,:)=v3;
                    return   % <<< EXIT IMMEDIATELY
            end
        end
    end

    i = i + 1;
end

end
