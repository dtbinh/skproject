%-----------------------------------------------------------------
%      DATAQUEST - Specific Parameters for NRHO datasets
%-----------------------------------------------------------------
function S = DataQuestSchema(ds)

%Check for dataset with newer version of the stimulus type and warn
%the user ...
VERSION = 3.0; VerFieldName = 'NRHOversion';
if ~isfield(ds.StimParam, VerFieldName), warning(sprintf('Failed to do version check on dataset %s.', ds.title));
elseif (getfield(ds.StimParam, VerFieldName) > VERSION), warning(sprintf('Dataset %s found that has newer version than script was intended for.', ds.title)); end

%For an NRHO dataset all parameters are already accessable via the
%common stimulus parameters, nevertheless all the parameters in the
%StimParam field are included in the Specific field of the database.
%Make sure the returned structure S always has the same fieldnames in
%the right order ...
Template = struct( ...
    'reps', NaN, ...
    'interval', NaN, ...
    'order', NaN, ...
    'burstDur', NaN, ...
    'riseDur', NaN, ...
    'fallDur', NaN, ...
    'delay', NaN, ...
    'lowFreq', NaN, ...
    'highFreq', NaN, ...
    'rho', NaN, ...
    'noisechar', NaN, ...
    'varchan', NaN, ...
    'SPL', NaN, ...
    'active', NaN, ...
    'Rseed', NaN, ...
    'noisePolarity', NaN, ...
    'IPD', NaN, ...
    'NRHOversion', NaN);
S = structtemplate(ds.StimParam, Template, 'warning', 'off', 'reduction', 'off');

%-----------------------------------------------------------------