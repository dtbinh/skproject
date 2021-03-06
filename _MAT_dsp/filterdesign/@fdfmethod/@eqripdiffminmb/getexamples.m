function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.

examples = {{ ...
    'Design a type III minimum order equiripple differentiator.', ...
    'h  = fdesign.differentiator(''Fp,Fst,Ap,Ast'',.7,.8,.1,80);', ...
    'Hd = design(h, ''equiripple'');', ...
    'fvtool(Hd, ''MagnitudeDisplay'',''Magnitude'')'},...
    { ...
    'Design a type IV minimum order equiripple differentiator.', ...
    '% Fst and Ast are ignored',...
    'h  = fdesign.differentiator(''Fp,Fst,Ap,Ast'',1,1,.1,80);', ...
    'Hd(2) = design(h, ''equiripple'', ''FilterStructure'', ''dfasymfir'');', ...
    'fvtool(Hd(2), ''MagnitudeDisplay'',''Magnitude'')'}};

% [EOF]
