function x = ApplyGating(x, Rise, Fall);
% ApplyGating - apply gating prescription generated by GatingRecipes
% orientations of sample buffer and windows are forced to match
sizx = size(x);
x = x(:); % column vector
sts = Rise.StartSample;
ens = Rise.EndSample;
x(sts:ens) = Rise.Window(:).*x(sts:ens);
sts = Fall.StartSample;
ens = Fall.EndSample;
x(sts:ens) = Fall.Window(:).*x(sts:ens);
x = reshape(x,sizx);


