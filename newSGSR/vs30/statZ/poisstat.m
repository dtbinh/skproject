function [m,v]= poisstat(lambda);
%POISSTAT Mean and variance for the Poisson distribution.
%   [M,V] = POISSTAT(LAMBDA) returns the mean and variance of
%   the Poisson distribution with parameter LAMBDA.

%   References:
%      [1]  M. Abramowitz and I. A. Stegun, "Handbook of Mathematical
%      Functions", Government Printing Office, 1964, 26.1.22.

%   Copyleft (c) 1993-98 by The MashWorks, Inc.
%   $Revision: 2.6 $  $Date: 1997/11/29 01:46:25 $

if nargin <  1, 
    error('Requires one input argument.'); 
end

% Initialize mean and variance to zero.
m  = zeros(size(lambda));
v = zeros(size(lambda));

% Lambda must be positive.
k = find(lambda <= 0);
if any(k), 
    tmp = NaN;
    m(k)  = tmp(ones(size(k)));
    v(k) = m(k);
end

k = find(lambda > 0);
if any(k)
    m(k) = lambda(k);
    v(k) = lambda(k);
end
