function [ rlist rvars ] = ...
  cEn_calcLaggedPCorr_MT( dataseries, laglist, replicates )

% function [ rlist rvars ] = ...
%   cEn_calcLaggedPCorr_MT( dataseries, laglist, replicates )
%
% This calculates the Pearson's correlation coefficient between a destination
% signal and time-lagged source signals. This can be used as a proxy for
% mutual information; for Gaussian RVs, I(X,Y) = - (1/2) log( 1 - r^2 ).
%
% This tests different lags in parallel with each other. This requires the
% Parallel Computing Toolbox.
%
% "dataseries" is a Nchans x Nsamples matrix or a cell array of length
%   Nchans containing data series. The first series (chan = 1) is the
%   destination signal; remaining series are source signals. For cell
%   array data, each cell contains either a vector of length Nsamples or
%   a matrix of size Ntrials x Nsamples.
% "laglist" is a vector containing sample time lags to test. These are
%   applied to the "source" signals. They may be negative (future times).
% "replicates" is the number of bootstrapping proxies to use when estimating
%   the uncertainty in the correlation coefficient. Use 1, 0, or NaN to
%   disable bootstrapping.
%
% "rlist" is a (Nchans-1,Nlags) matrix containing correlation coefficients
%   between X_k (dataseries{k+1}) to Y (dataseries{1}) for each time lag.
% "rvars" is a vector containing the estimated variance of each element
%   in "rlist".


% Get metadata.
lagcount = length(laglist);


% Iterate in parallel.

rawlists = {};
rawvars = {};

parfor lidx = 1:lagcount
  thislag = laglist(lidx);

  [ thisraw, thisvar ] = ...
    cEn_calcLaggedPCorr( dataseries, thislag, replicates );

  rawlists{lidx} = thisraw;
  rawvars{lidx} = thisvar'
end


% Unpack the output.

rlist = [];
rvars = [];

for lidx = 1:lagcount
  rlist(:,lidx) = rawlists{lidx};
  rvars(:,lidx) = rawvars{lidx};
end


% Done.
end


%
% This is the end of the file.
