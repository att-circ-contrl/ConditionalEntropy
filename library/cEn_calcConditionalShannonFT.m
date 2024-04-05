function bits = ...
  cEn_calcConditionalShannonFT( ftdata, chanlist, bins, exparams )

% function bits = ...
%   cEn_calcConditionalShannonFT( ftdata, chanlist, bins, exparams )
%
% This calculates the conditional entropy associated with a set of signals.
% This is the average amount of additional information that a sample from
% variable Y gives you when you already know variables X_1..X_k.
%
% This processes Field Trip data as input, concatenating trials.
%
% This needs a large number of samples to generate accurate results. To
% compensate for smaller sample counts, this may optionally use the
% extrapolation method described in EXTRAPOLATION.txt.
%
% "ftdata" is a ft_datatype_raw data structure produced by Field Trip.
% "chanlist" is a cell array containing channel labels or a vector containing
%   channel indices. If the list is empty, all channels are used. The first
%   channel in this list is used as the variable Y; remaining channels are
%   X_k.
% "bins" is a scalar or vector (to generate histogram bins) or a cell array
%   (to supply bin edge lists). If it's a vector of length Nchans or a
%   scalar, it indicates how many bins to use for each channel's data. If
%   it's a cell array, bins{chanidx} provides the list of edges used for
%   binning each channel's data.
% "exparams" is an optional structure containing extrapolation tuning
%   parameters, per EXTRAPOLATION.txt. If this is empty, default parameters
%   are used. If this is absent, no extrapolation is performed.
%
% "bits" is a scalar with the average additional entropy provided by an
%   observation of Y, when all X_k are known.


% Extract a data series matrix from the Field Trip data.
dataseries = cEn_ftHelperConcatTrials( ftdata, chanlist );

% Wrap the non-FT function.
if exist('exparams', 'var')
  bits = cEn_calcConditionalShannon( dataseries, bins, exparams );
else
  bits = cEn_calcConditionalShannon( dataseries, bins );
end


%
% This is the end of the file.
