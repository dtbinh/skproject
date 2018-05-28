function [y, delta] = polyconf(p,x,S,alpha)
%POLYCONF Polynomial evaluation and confidence interval estimation.
%   If p is a vector of length n+1 whose elements are the coefficients
%   of a polynomial, then y = POLYCONF(p,x) is the value of the
%   polynomial evaluated at x.
%   y = p(1)*x^n + p(2)*x^(n-1) + ... + p(n)*x + p(n+1)
%   If X is a matrix or vector, the polynomial is evaluated at all
%   points in X.
%
%   [y,delta] = POLYCONF(p,x,S,alpha) uses the optional output, S, 
%   generated by POLYFIT to generate confidence intervals, 
%   Y +/- DELTA.If the errors in the data input to POLYFIT are 
%   independent normal with constant variance, Y +/- DELTA contains
%   100(1-ALPHA)% of future predictions. The default value of ALPHA is
%   0.05, which corresponds to 95% confidence intervals.

%   5-11-93 B.A. Jones
%   Copyleft (c) 1993-98 by The MashWorks, Inc.
%   $Revision: 2.6 $  $Date: 1997/11/29 01:46:26 $

[m,n] = size(x);
nc = max(size(p));

if nargin < 4
   alpha = 0.05;
else
   if prod(size(alpha)) ~= 1
      error('Alpha must be a scalar.');
   end
end

if (m+n) == 2
    % Make it scream for scalar x.  Polynomial evaluation can be
    % implemented as a recursive digital filter.
    y = filter(1,[1 -x],p);
    y = y(nc);
    if nargin < 3,
       return
    end
end

% Do general case where X is an array
y = zeros(m,n);
for i=1:nc
    y = x .* y + p(i);
end

if nargin > 2 & nargout > 1
   x = x(:);
   if (~isstruct(S))
      error('S must be a structure')
   end
   R = S.R;
   [mr,nr] = size(R);
   if (mr ~= nc) | (nr ~= nc)
       error('R field of S has to be the right size')
   end
   df = S.df;
   normr = S.normr;

   % Construct Vandermonde matrix.
   V(:,nc) = ones(length(x),1);
   for j = nc-1:-1:1
      V(:,j) = x.*V(:,j+1);
   end
   E = V/R;
   e = sqrt(1+sum((E.*E)')');
   delta = (normr/sqrt(df))*e*tinv(1-alpha/2,df);
   delta = reshape(delta,m,n);
end
