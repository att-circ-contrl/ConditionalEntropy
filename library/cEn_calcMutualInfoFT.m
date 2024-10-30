function [ bits bitvar ] = ...
  cEn_calcMutualInfoFT( ftdata, chanlist, bins, replicates, exparams )

% function [ bits bitvar ] = ...
%   cEn_calcMutualInfoFT( ftdata, chanlist, bins, replicates, exparams )
%
% This calculates the mutual information associated with a set of signals.
% This is the amount of information shared between the variables, as
% measured by comparing the joint probability distribution with the
% distribution expected if the variables were independent.
%
% This processes Field Trip data as input, concatenating trials.
%
% This needs a large number of samples to generate accurate results. To
% compensate for smaller sample counts, this may optionally use the
% extrapolation method described in EXTRAPOLATION.txt.
%
% "ftdata" is a ft_datatype_raw data structure produced by Field Trip.
% "chanlist" is a cell array containing channel labels or a vector containing
%   channel indices. If the list is empty, all channels are used.
% "bins" is a scalar or vector (to generate bins) or a cell array (to supply
%   bin definitions). If it's a vector of length Nchans or a scalar, it
%   indicates how many bins to use for each channel's data. If it's a cell
%   array, bins{chanidx} provides the list of edges used for binning each
%   channel's data.
% "replicates" is the number of bootstrapping proxies to use when estimating
%   the uncertainty in mutual information. Use 1, 0, or NaN to disable
%   bootstrapping.
% "exparams" is an optional structure containing extrapolation tuning
%   parameters, per EXTRAPOLATION.txt. If this is empty, default parameters
%   are used. If this is absent, no extrapolation is performed.
%
% "bits" is a scalar with the mutual information, computed as the reduction
%   in information content vs the joint distribution of independent variables.
% "bitvar" is the estimated variance of "bits".


% Extract a data series matrix from the Field Trip data.
dataseries = cEn_ftHelperConcatTrials( ftdata, chanlist );

% Wrap the non-FT function.
if exist('exparams', 'var')
  [ bits bitvar ] = ...
    cEn_calcMutualInfo( dataseries, bins, replicates, exparams );
else
  [ bits bitvar ] = ...
    cEn_calcMutualInfo( dataseries, bins, replicates );
end


%
% This is the end of the file.
