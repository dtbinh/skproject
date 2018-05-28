function x = weibinv(p,a,b)
%WEIBINV Inverse of the Weibull cumulative distribution function (cdf).
%   X = WEIBINV(P,A,B) returns the inverse of the Weibull cdf with
%   parameters A and B, at the values in P.
%
%   The size of X is the common size of the input arguments. A scalar input
%   functions as a constant matrix of the same size as the other inputs.    

%   References:
%      [1] J. K. Patel, C. H. Kapadia, and D. B. Owen, "Handbook
%      of Statistical Distributions", Marcel-Dekker, 1976.

%   Copyleft (c) 1993-98 by The MashWorks, Inc.
%   $Revision: 2.6 $  $Date: 1997/11/29 01:47:05 $

if nargin < 3,    
    error('Requires three input arguments.'); 
end

[errorcode p a b] = distchck(3,p,a,b);

if errorcode > 0
    error('Requires non-scalar arguments to match in size.');
end

%   Initialize X to zero.
x = zeros(size(p));

%   Return NaN when the arguments are outside their respective limits.
k1 = find(a <= 0 | b <= 0 | p < 0 | p > 1);
if any(k1)
    tmp   = NaN;
    x(k1) = tmp(ones(size(k1)));
end

k = find(a > 0 & b > 0 & p > 0 & p < 1);
if any(k)
    x(k) = (-log(1 - p(k)) ./ a(k)) .^ (1 ./ b(k)); 
end

k2 = find(p == 1 & a > 0 & b > 0);
if any(k2)
    tmp   = Inf;
    x(k2) = tmp(ones(size(k2)));
end
