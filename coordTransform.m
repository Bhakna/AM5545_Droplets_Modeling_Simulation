function R = coordTransform(r12)
if norm(r12) < 1e-12
    error("coordTransform: r12 is too small to normalize.");
end
e1 = r12(:) / norm(r12);
if abs(e1(3)) < 0.9
    helper = [0;0;1];
else
    helper = [1;0;0];
end
e2 = cross(e1, helper); e2 = e2 / norm(e2);
e3 = cross(e1, e2);
R = [e1 e2 e3];
end
