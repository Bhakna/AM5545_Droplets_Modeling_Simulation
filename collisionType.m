function outcome = collisionType(We, B, xmlOrData)
% collisionType Decide 'C','B','S' using We-B nomogram.
%   outcome = collisionType(We, B)                    % uses default file
%   outcome = collisionType(We, B, 'file.xml')       % reads/caches the file
%   outcome = collisionType(We, B, dataStruct)       % uses pre-read struct
%
% Implementation caches last-read file to avoid repeated disk I/O.

persistent cachedFile cachedData

if nargin < 3 || isempty(xmlOrData)
    xmlOrData = 'We_B_cubic_appx.xml';
end

% If a struct was passed, use it directly
if isstruct(xmlOrData)
    data = xmlOrData;
else
    % xmlOrData should be a filename (char or string)
    if ~(ischar(xmlOrData) || isstring(xmlOrData))
        error('collisionType:invalidInput','Third argument must be filename or data struct.');
    end
    xmlFile = char(xmlOrData);

    % If cached and same file, reuse
    if ~isempty(cachedFile) && strcmp(cachedFile, xmlFile) && ~isempty(cachedData)
        data = cachedData;
    else
        % Read once and cache
        data = readstruct(xmlFile);
        cachedFile = xmlFile;
        cachedData = data;
    end
end

% now extract polynomial coefficient vectors (ensure numeric)
p1  = [data.p1(1),  data.p1(2),  data.p1(3),  data.p1(4)];
p2  = [data.p2(1),  data.p2(2),  data.p2(3),  data.p2(4)];
p31 = [data.p31(1), data.p31(2), data.p31(3), data.p31(4)];
p32 = [data.p32(1), data.p32(2), data.p32(3), data.p32(4)];

% basic validation
if ~isnumeric(We) || ~isnumeric(B)
    error('collisionType:BadInputs','We and B must be numeric scalars.');
end
if We < 0
    error('collisionType:BadInputs','Weber number cannot be negative.');
end

% Nomogram logic (same as before)
if We <= 5
    outcome = 'C';
elseif We <= 10
    if B <= polyval(p1, We)
        outcome = 'C';
    else
        outcome = 'B';
    end
elseif We <= 15
    if B <= polyval(p31, We)
        outcome = 'C';
    elseif B <= polyval(p2, We)
        outcome = 'S';
    else
        outcome = 'B';
    end
elseif We <= 50
    if B <= polyval(p32, We)
        outcome = 'S';
    elseif B <= polyval(p31, We)
        outcome = 'C';
    elseif B <= polyval(p2, We)
        outcome = 'S';
    else
        outcome = 'B';
    end
elseif We <= 61.1535
    if B <= polyval(p32, We)
        outcome = 'S';
    elseif B <= polyval(p31, We)
        outcome = 'C';
    elseif B <= 0.8
        outcome = 'S';
    else
        outcome = 'B';
    end
else
    if B <= 0.8
        outcome = 'S';
    else
        outcome = 'B';
    end
end
end
