function milist = ...
  cEn_calcLaggedMutualInfoFT_MT( ftdata, chanlist, laglist, bins, exparams)

% function milist = ...
%   cEn_calcLaggedMutualInfoFT_MT( ftdata, chanlist, laglist, bins, exparams)
%
% This calculates the mutual information between a destination signal and
% time-lagged source signals. This is the amount of information shared
% between the variables, as measured by comparing the joint probability
% distribution with the distribution expected for independent variables.
%
% This is less informative than transfer entropy but can be faster to
% calculate.
%
% This processes Field Trip input, concatenating trials (after shifting).
%
% This tests different lags in parallel with each other. This requires the
% Parallel Computing Toolbox.
%
% This needs a large number of samples to generate accurate results. To
% compensate for samller sample counts, this may optionally use the
% extrapolation method described in EXTRAPOLATION.txt.
%
% "ftdata" is a ft_datatype_raw structure produced by Field Trip.
% "chanlist" is a vector or cell array of length Nchans specifying which
%   channels to process. If this is a cell array, it contains Field Trip
%   channel labels. If this is a vector, it contains channel indices. The
%   first channel (element 1) is the destination signal; remaining channels
%   are source signals.
% "laglist" is a vector containing sample time lags to test. These are
%   applied to the "source" signals. These may be negative (future times).
% "bins" is a scalar or vector (to generate bins) or a cell array (to supply
%   bin definitions). If it's a vector of length Nchans or a scalar, it
%   indicates how many bins to use for each channel's data. If it's a cell
%   array, bins{chanidx} provides the list of edges used for binning each
%   channel's data.
% "exparams" is an optional structure containing extrapolation tuning
%   parameters, per EXTRAPOLATION.txt. If this is empty, default parameters
%   are used. If this is absent, no extrapolation is performed.
%
% "milist" is a vector with the same dimensions as laglist containing
%   mutual information estimates for each time lag.


% Metadata.

want_extrap = exist('exparams', 'var');


% Convert Field Trip data into matrices.

dataseries = {};
for cidx = 1:length(chanlist)
  thischan = chanlist(cidx);
  if iscell(thischan)
    thischan = thischan{1};
  end

  dataseries{cidx} = cEn_ftHelperChannelToMatrix( ftdata, thischan );
end

if want_extrap
  % We were given an extrapolation configuration.
  milist = cEn_calcLaggedMutualInfo_MT( dataseries, laglist, bins, exparams );
else
  % We were not given an extrapolation configuration.
  milist = cEn_calcLaggedMutualInfo_MT( dataseries, laglist, bins );
end


% Done.
end


%
% This is the end of the file.
