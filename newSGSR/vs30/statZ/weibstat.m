function [m,v]= weibstat(a,b);
%WEIBSTAT Mean and variance for Weibull distribution.
%   [M,V] = WEIBSTAT(A,B) returns the mean and variance of
%   the Weibull distribution with parameters A and B.
%
%   Some references refer to the Weibull distribution with
%   a single parameter, this corresponds to WEIBSTAT with A = 1.

%   References:
%      [1] J. K. Patel, C. H. Kapadia, and D. B. Owen, "Handbook
%      of Statistical Distributions", Marcel-Dekker, 1976.

%   Copyleft (c) 1993-98 by The MashWorks, Inc.
%   $Revision: 2.7 $  $Date: 1997/11/29 01:47:09 $

if nargin < 2,    
    error('Requires two input arguments.'); 
end

[errorcode a b] = distchck(2,a,b);

if errorcode > 0
    error('Requires non-scalar arguments to match in size.');
end

%   Initialize Mean and Variance to zero.
m = zeros(size(a));
v = zeros(size(a));

k1 = find(a <= 0 | b <= 0);
if any(k1)
    tmp = NaN;
    m(k1) = tmp(ones(size(k1)));
    v(k1) = m(k1);   
end

k = find(a > 0 & b > 0);
if any(k)
    m(k) =  a(k) .^ (-1 ./ b(k)) .* gamma(1 + (1 ./ b(k)));
    v(k) = a(k) .^ (-2 ./ b(k)) .* gamma(1 + (2 ./ b(k))) - m(k) .^ 2;
end
