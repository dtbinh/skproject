%-----------------------------------------------------------------
%     DATAQUEST - Specific Parameters for WAV datasets
%-----------------------------------------------------------------
function S = DataQuestSchema(ds)

%Make sure the returned structure S always has the same fieldnames in
%the right order ...
WAVdetails = struct( ...
             'Nwav', NaN, ...
     'wavFileNames', '', ...
        'ShortName', '', ...
          'Fsample', NaN, ...
       'NewFsample', NaN, ...
      'FilterIndex', NaN, ...
    'ResampleRatio', NaN, ...
        'Durations', NaN, ...
           'maxDur', NaN, ...
        'MaxSample', NaN, ...
          'MaxBoth', NaN, ...
           'Scalor', NaN, ...
          'MaxSPLs', NaN, ...
      'GrandMaxSPL', NaN);
Template = struct( ...
         'wavlistname', '', ...
            'stimtype', '', ...
                'reps', NaN, ...
            'interval', NaN, ...
               'atten', NaN, ...
              'active', NaN, ...
    'activeDAchannels', '', ...
           'calibmode', '', ...
               'order', NaN, ...
          'WAVdetails', WAVdetails);
S = structtemplate(ds.StimParam, Template, 'warning', 'off', 'reduction', 'off');

%-----------------------------------------------------------------