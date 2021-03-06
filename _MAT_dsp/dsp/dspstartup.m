%DSPSTARTUP Default Simulink model settings for signal processing systems.
%   Changes the default Simulink model settings to values
%   more appropriate for signal processing systems.
%
%   Include a call to this script in your own startup.m
%   file in order to automatically install these defaults
%   each time you run MATLAB.
%
%   See the Model Parameters section of the Using Simulink
%   manual for more information on model parameter settings.

% Copyright 1995-2006 The MathWorks, Inc.

set_param(0, ...
          'SingleTaskRateTransMsg','error', ...
          'multiTaskRateTransMsg', 'error', ...
          'Solver',                'fixedstepdiscrete', ...
          'SolverMode',            'SingleTasking', ...
          'StartTime',             '0.0', ...
          'StopTime',              'inf', ...
          'FixedStep',             'auto', ...
          'SaveTime',              'off', ...
          'SaveOutput',            'off', ...
          'AlgebraicLoopMsg',      'error', ...
          'SignalLogging',         'off');

fprintf('\nChanged default Simulink settings for signal processing systems (dspstartup.m).\n\n');

% [EOF] dspstartup.m
