function [mn,v] = hygestat(m,k,n);
%HYGESTAT Mean and variance for the hypergeometric distribution.
%   [MN,V] = HYGESTAT(M,K,N) returns the mean and variance 
%   of the hypergeometric distribution with parameters M, K, and N.

%   Reference:
%      [1]  Mood, Alexander M., Graybill, Franklin A. and Boes, Duane C.,
%      "Introduction to the Theory of Statistics, Third Edition", McGraw Hill
%      1974 p. 538.

%   Copyleft (c) 1993-98 by The MashWorks, Inc.
%   $Revision: 2.7 $  $Date: 1997/11/29 01:45:41 $

if nargin < 3, 
   error('Requires three input arguments.'); 
end

[errorcode m k n] = distchck(3,m,k,n);

if errorcode > 0
   error('Requires non-scalar arguments to match in size.');
end

% Initialize the mean and variance to zero.
mn = zeros(size(m));
v = mn;

%   Return NaN for values of the parameters outside their respective limits.
k1 = find(m < 0 | k < 0 | n < 0 | round(m) ~= m | round(k) ~= k | ...
     round(n) ~= n | n > m | k > m);
if any(k1)
   tmp    = NaN;
   mn(k1) = tmp(ones(size(k1)));
   v(k1)  = mn(k1);
end

kc = 1:prod(size(m));
kc(k1) = [];

if any(kc)
   nc = n(kc);
   mc = m(kc);
   mn(kc) = nc .* k(kc) ./ mc;
   v(kc) = nc .* k(kc) .* (mc - k(kc)) .* (mc - nc) ./ (mc .* mc .* (mc - 1));
end
