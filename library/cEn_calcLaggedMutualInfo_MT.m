function [ milist mivars ] = cEn_calcLaggedMutualInfo_MT( ...
  dataseries, laglist, bins, replicates, exparams)

% function [ milist mivars ] = cEn_calcLaggedMutualInfo_MT( ...
%   dataseries, laglist, bins, replicates, exparams)
%
% This calculates the mutual information between a destination signal and
% time-lagged source signals. This is the amount of information shared
% between the variables, as measured by comparing the joint probability
% distribution with the distribution expected for independent variables.
%
% This is less informative than transfer entropy but can be faster to
% calculate.
%
% This tests different lags in parallel with each other. This requires the
% Parallel Computing Toolbox.
%
% This needs a large number of samples to generate accurate results. To
% compensate for samller sample counts, this may optionally use the
% extrapolation method described in EXTRAPOLATION.txt.
%
% "dataseries" is a Nchans x Nsamples matrix or a cell array of length
%   Nchans containing data series. The first series (chan = 1) is the
%   destination signal; remaining series are source signals. For cell
%   array data, each cell contains either a vector of length Nsamples or
%   a matrix of size Ntrials x Nsamples.
% "laglist" is a vector containing sample time lags to test. These are
%   applied to the "source" signals. These may be negative (future times).
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
% "milist" is a vector with the same dimensions as "laglist" containing
%   mutual information estimates for each time lag.
% "mivars" is a vector containing the estimated variance of each element
%   in "milist".


% Metadata.

want_extrap = exist('exparams', 'var');

% Parfor wants this to exist even if we don't use it.
if ~want_extrap
  exparams = struct();
end

lagcount = length(laglist);


% Iterate in parallel.

milist = nan(size(laglist));
mivars = milist;

parfor lidx = 1:lagcount

  thislag = laglist(lidx);

  if want_extrap
    % We were given an extrapolation configuration.
    [ thismi thisvar ] = cEn_calcLaggedMutualInfo( ...
      dataseries, thislag, bins, replicates, exparams );
    milist(lidx) = thismi;
    mivars(lidx) = thisvar;
  else
    % We were not given an extrapolation configuration.
    [ thismi thisvar ] = cEn_calcLaggedMutualInfo( ...
      dataseries, thislag, bins, replicates );
    milist(lidx) = thismi;
    mivars(lidx) = thisvar;
  end

end


% Done.
end


%
% This is the end of the file.
