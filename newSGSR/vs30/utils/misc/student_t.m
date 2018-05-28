function [p, t, Ndf] = student_t(x1, x2);
% STUDENT_T - Student's T statistic, unkown sigma
%   STUDENT_T(X1, X2) returns the confidence for a
%   one-tailed Student'd t-test applied to
%   two samples if data X1 and X2. X1 and X2 are assumed
%   obey Gaussian statistics with the same unknown standard
%   deviation. (See Chatfield Chap 7.3.2)
%
%   STUDENT_T(D) returns the p for paired comparison. 
%   D contains the differences. 
%   (See Chatfield Chap 7.4)
%
%   [p, T, Ndf] = STUDENT_T(...) also returns the value
%   of the T-statistic and the # degrees of freedom.
%
%   Convention: T>0 for mean(X1)>mean(X2)

if nargin<2, % paired comparison
   k = length(x1);
   Ndf = k-1;
   s = std(x1);
   t = mean(x1)/(s/sqrt(k));
else,
   % two indep samples from here
   m1 = mean(x1); m2 = mean(x2);
   n1 = length(x1); n2 = length(x2); 
   Ndf = n1 + n2 - 2; % # degrees of freedom
   % sums of squares
   ss1 = sum((x1-m1).^2);
   ss2 = sum((x2-m2).^2);
   % s is sqrt of unbiased estimate of sigma^2
   s = sqrt((ss1+ss2)/Ndf);
   t = (m1-m2)/(s*sqrt(1/n1+1/n2));
end


%
ps = [0.1 0.05 0.25 0.01 0.05 0.001 0.0005];
Tmat = [...
   1 3.078 6.314 12.706 31.821 63.657  318.310 636.619
   2 1.886 2.920 4.303 6.965 9.925 22.327 31.598
   3 1.638 2.353 3.182 4.541 5.841 10.215 12.941
   4 1.533 2.132 2.776 3.747 4.604  7.173 8.610
   5 1.476 2.015 2.571 3.365 4.032  5.893 6.859
   6 1.440 1.943 2.447 3.143 3.707  5.208 5.959
   7 1.415 1.895 2.365 2.998 3.499  4.785 5.405
   8 1.397 1.860 2.306 2.896 3.355  4.501 5.041
   9 1.383 1.833 2.262 2.821 3.250  4.297 4.781
   10 1.372 1.812 2.228 2.764 3.169 4.144 4.587
   11 1.363 1.796 2.201 2.718 3.106 4.025  4.437
   12 1.356 1.782 2.179 2.681 3.055 3.930 4.318
   13 1.350 1.771 2.160 2.650 3.012 3.852 4.221
   14 1.345 1.761 2.145 2.624 2.977 3.787 4.140
   15 1.341 1.753 2.131 2.602 2.947 3.733 4.073
   16 1.337 1.746 2.120 2.583 2.921 3.686 4.015
   17 1.333 1.740 2.110 2.567 2.898 3.646 3.965
   18 1.330 1.734 2.101 2.552 2.878 3.610 3.922
   19 1.328 1.729 2.093 2.539 2.861 3.579 3.883
   20 1.325 1.725 2.086 2.528 2.845 3.552 3.850
   21 1.323 1.721 2.080 2.518 2.831 3.527 3.819
   22 1.321 1.717 2.074 2.508 2.819 3.505 3.792
   23 1.319 1.714 2.069 2.500 2.807 3.485 3.767
   24 1.318 1.711 2.064 2.492 2.797 3.467 3.745
   25 1.316 1.708 2.060 2.485 2.787 3.450 3.725
   26 1.315 1.706 2.056 2.479 2.779 3.435 3.707
   27 1.314 1.703 2.052 2.473 2.771 3.421 3.690
   28 1.313 1.701 2.048 2.467 2.763 3.408 3.674
   29 1.311 1.699 2.045 2.462 2.756 3.396 3.659
   30 1.310 1.697 2.042 2.457 2.750 3.385 3.646
   40 1.303 1.684 2.021 2.423 2.704 3.307 3.551
   60 1.296 1.671 2.000 2.390 2.660 3.232 3.460
   120 1.289 1.658 1.980 2.358 2.617 3.160 3.373
   inf 1.282 1.645 1.960 2.326 2.576 3.090 3.291 ...
];

imin = max(find(Tmat(:,1)<=Ndf)); Neff = Tmat(imin,1);
ip = max(find(Tmat(imin,2:end)<=t));
p = ps(ip);
   
   
   
