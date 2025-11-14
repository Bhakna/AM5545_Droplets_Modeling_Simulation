function dvecs = shortestDistanceVector(pts, x, L)
% pts : n×3, x : 1×3
n = size(pts,1);
dvecs = zeros(n,3);
for k=1:n
    dx = x - pts(k,:);
    dx = dx - L*round(dx./L);
    dvecs(k,:) = dx;
end
end
