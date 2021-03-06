function [mapName, relativePathToMapFile, found] = getBlockHelpMapNameAndPath(block_type)
%  Returns the mapName and the relative path to the maps file for this block_type

% Copyright 2007-2013 The MathWorks, Inc.
    
    blks = {...
    'FrameConversion'                'dspframeconversion'           ;...
    'DSPFlip'                        'dspflip'                      ;...
    'Buffer'                         'dspbuffer'                    ;...
    'Unbuffer'                       'dspunbuffer'                  ;...
    'SignalToWorkspace'              'dspsignaltoworkspace'         ;...
    'AllpoleFilter'                  'dspallpolefilter'             ;...
    'TimeScope'                      'dsptimescope'                 ;...
    'SpectrumAnalyzer'               'dspspectrumanalyzer'          ;...
    'DCBlocker'                      'dspdcblocker'                 ;...
    'dsp.HDLNCO'                     'nco_hdl'                      ;...
    'dsp.TransferFunctionEstimator'  'dsptransferfunctionestimator' ;...
    'dsp.HDLFFT'            'dsphdlfft'        ;...
    'dsp.HDLIFFT'           'dsphdlifft'       ;...
    };
relativePathToMapFile = '/dsp/dsp.map';
found = false;
% See whether or not the block is a DSP System Toolbox core or built-in
i = strmatch(block_type, blks(:,1), 'exact');

if isempty(i)
    mapName = 'User Defined';
else
    found = true;
    mapName = blks(i,2);
end

