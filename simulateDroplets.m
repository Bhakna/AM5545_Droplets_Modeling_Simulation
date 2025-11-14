% simulateDroplets.m
clear variables; close all; clc;

% ----------------------- Simulation parameters ------------------------
params.N           = 1000;        % initial number of droplets
params.L           = 1.0;        % cubic domain side length
params.D0          = 0.02;       % initial diameter (monodisperse)
params.polydisp    = false;      % small random variation if true
params.sigma       = 0.072;      % surface tension
params.rho         = 1000;       % density
params.v_var       = 0.05;        % velocity stddev
params.dt          = 1e-3;       % time step
params.t_end       = 300.0;       % total simulation time
params.plotEvery   = 5;          % plot every n timesteps
params.XMLfile     = 'We_B_cubic_appx.xml';  % nomogram file
params.nomData = readstruct(params.XMLfile);
params.markerScale = 2000*10;       % visualization scaling factor

% ----------------------- Initialize droplets -------------------------
[D, r, v] = initDroplets(params);

% ----------------------- Visualization setup -------------------------
fig = figure('Color','w','Position',[200 200 900 700]);
ax = axes('Parent',fig);
axis(ax, [0 params.L 0 params.L 0 params.L]);
xlabel('x'); ylabel('y'); zlabel('z'); view(45,30);
hold(ax,'on');
grid on;

% initial plot
h = scatter3(ax, r(:,1), r(:,2), r(:,3), (D.^2) * params.markerScale, 'blue', 'filled');
title(ax, sprintf('t = %.4f, N = %d', 0, size(r,1)));

% ----------------------- Main time loop -------------------------------

% ---- Initializing timestamps ----
t = 0;
step = 0;

% ---- Logging variables ----
logTimes     = [];     % simulation times
logN         = [];     % number of droplets over time
logHistTimes = 0:25:params.t_end;
nextHistID   = 1;       % index of next snapshot time
histData     = cell(length(logHistTimes),1);   % store droplet size distributions

while t < params.t_end

    step = step + 1;

    % update positions (row-wise)
    r = r + v * params.dt;
    r = applyPeriodic(r, params.L);

    % check for error in periodicity
    if any(~isfinite(r),'all')
        error('Position array r contains non-finite values (NaN or Inf).');
    end
    if any(abs(r) > 1e6, 'all')
        error('Positions exploded numerically. Check velocity magnitudes.');
    end

    % detect and resolve collisions (may change D,r,v sizes)
    % out = collisionType(We, B, params.nomData);
    [D, r, v] = detectAndResolveCollisions(D, r, v, params);

    % ---- Log N(t) ----
    logTimes(end+1) = t;
    logN(end+1)     = length(D);

    % ---- Log histogram snapshots ----
    if nextHistID <= length(logHistTimes) && t >= logHistTimes(nextHistID)
        histData{nextHistID} = D;    % store diameters at this time
        nextHistID = nextHistID + 1;
    end
    
    t = t + params.dt;
    
    % visualize periodically
    % --- VISUAL UPDATE ---
    if size(get(h,'XData'),2) ~= size(r,1)
        % number of particles changed → remake scatter
        delete(h);
        markerScale = params.markerScale;
        h = scatter3(ax, r(:,1), r(:,2), r(:,3), ...
            max((D.^2)*markerScale, 1), 'blue', 'filled');
    else
        % safe update
        markerScale = params.markerScale;
        sizeData = (D.^2) * markerScale;

        % remove invalid entries
        sizeData(~isfinite(sizeData) | sizeData<=0) = 1;

        set(h, 'XData', r(:,1), ...
            'YData', r(:,2), ...
            'ZData', r(:,3), ...
            'SizeData', sizeData);
    end

    if mod(step, params.plotEvery) == 0 || t >= params.t_end
        if isvalid(fig)
            title(ax, sprintf('t = %.4f, N = %d', t, size(r,1)));
            drawnow;
        end
    end
    
    % safety cutoff
    if size(r,1) > 2 * params.N
        warning('Number of droplets grew very large; stopping to avoid memory blow-up.');
        break;
    end

    % tolerance cutoff
    if size(r,1) <= 1
        warning('Only one drop remains. No further modelling required.');
        break;
    end

end

% ---- While loop results ----
fprintf('Simulation finished at t=%.4f with N=%d\n', t, size(r,1));

% ---- Figure : N(t) vs t ----
figure;
plot(logTimes, logN, 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Number of droplets N(t)');
title('Population Dynamics of Droplets');
grid on;

% ---- Figure : PDFs at timestamps ----

figure;
hold on; grid on;

colors = lines(length(histData));

% ------------------------------------------------------------
% Compute global x-limits from ALL histData
% ------------------------------------------------------------
allD = [];   % concatenate all droplet diameters from snapshots
for k = 1:length(histData)
    if ~isempty(histData{k})
        allD = [allD; histData{k}(:)];
    end
end

if isempty(allD)
    error('histData appears empty; no KDE curves to plot.');
end

xmin = min(allD);
xmax = max(allD);

% Add small padding for aesthetics
xpad = 0.05 * (xmax - xmin);
xmin = xmin - xpad;
xmax = xmax + xpad;

% ------------------------------------------------------------
% KDE curves plotted with consistent axis limits
% ------------------------------------------------------------
for k = 1:length(histData)
    if isempty(histData{k}), continue; end

    [f, xi] = ksdensity(histData{k});   % kernel density estimate
    
    % Keep curves within global axis bounds
    mask = xi >= xmin & xi <= xmax;
    
    plot(xi(mask), f(mask), ...
        'LineWidth', 2, ...
        'Color', colors(k,:));
end

xlabel('Droplet Diameter D');
ylabel('Density');
title('Droplet Size Distribution Over Time (KDE Curves)');
legend( arrayfun(@(t) sprintf('t = %.2f s', t), logHistTimes, ...
                  'UniformOutput', false), ...
        'Location', 'bestoutside');  % places legend outside axes (cleaner)

xlim([xmin xmax]);

hold off;


