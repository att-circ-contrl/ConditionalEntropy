function telist = ...
  cEn_calcTransferEntropy_MT( dataseries, laglist, bins, exparams )

% function telist = ...
%   cEn_calcTransferEntropy_MT( dataseries, laglist, bins, exparams )
%
% This is a wrapper for cEn_calcTransferEntropy() that tests different lags
% in parallel with each other. This requires the Parallel Computing Toolbox.
%
% This calculates the partial transfer entropy from signals X_1..X_k to
% signal Y, for a specified set of time lags. If there is only one X, this
% is the transfer entropy from X to Y.
%
% NOTE - This needs a large number of samples to generate accurate results!
% To compensate for smaller sample counts, this may optionally use the
% extrapolation method described in EXTRAPOLATION.txt (per Palmigiano 2017).
%
% Transfer entropy from X to Y is defined as:
%   TEx->y = H[Y|Ypast] - H[Y|Ypast,Xpast]
% This is the amount of additional information gained about the future of Y
% by knowing the past of X, vs just knowing the past of Y.
%
% Partial transfer entropy from A to Y in the presence of B is defined as:
%   pTEa->y = H[Y|Ypast,Bpast] - H[Y|Ypast,Bpast,Apast]
% This is the amount of additional information gained about the future of Y
% by knowing the past of A, vs just knowing the past of Y and B.
%
% This is prohibitively expensive to compute, so a proxy is usually used
% that considers a sample at some distance in the past as a proxy for the
% entire past history:
%   TEx->y(tau) = H[Y(t)|Y(t-tau)] - H[Y(t)|Y(t-tau),X(t-tau)]
%
% A similar proxy is used for computing partial transfer entropy.
%
% NOTE - For k source signals, this involves evaluating a (k+2) dimensional
% histogram. This gets very big very quickly, and also needs a very large
% number of samples to get good statistics.
%
% "dataseries" is a Nchans x Nsamples matrix or a cell array of length
%   Nchans containing data series. The first series (chan = 1) is the
%   destination signal Y; remaining series are source signals X_k. For cell
%   array data, each cell contains either a vector of length Nsamples or
%   a matrix of size Ntrials x Nsamples.
% "laglist" is a vector containing sample lags to test. These correspond to
%   tau in the equation above. These may be negative (looking at the future).
% "bins" is a scalar or vector (to generate bins) or a cell array (to supply
%   bin definitions). If it's a vector of length Nchans or a scalar, it
%   indicates how many bins to use for each channel's data. If it's a cell
%   array, bins{chanidx} provides the list of edges used for binning each
%   channel's data.
% "exparams" is an optional structure containing extrapolation tuning
%   parameters, per EXTRAPOLATION.txt. If this is empty, default parameters
%   are used. If this is absent, no extrapolation is performed.
%
% "telist" is a (Nchans-1,Nlags) matrix containing transfer entropy
%   estimates from X_k (dataseries{k+1}) to Y (dataseries{1}) for each
%   time lag.


% Convert matrix data into single-trial cell data.

if ~iscell(dataseries)
  % This is a Nchans x Nsamples matrix.
  chancount = size(dataseries,1);
  scratch = {};
  for cidx = 1:chancount
    scratch{cidx} = dataseries(cidx,:);
  end
  dataseries = scratch;
end


% Metadata.

want_extrap = exist('exparams', 'var');

% Parfor wants this to exist even if we don't use it.
if ~want_extrap
  exparams = struct();
end

xcount = length(dataseries) - 1;
lagcount = length(laglist);


% Iterate in parallel.

telistbylag = {};

parfor lidx = 1:lagcount

  if want_extrap
    % We were given an extrapolation configuration.
    telistbylag{lidx} = ...
      cEn_calcTransferEntropy( dataseries, laglist(lidx), bins, exparams );
  else
    % We were not given an extrapolation configuration.
    telistbylag{lidx} = ...
      cEn_calcTransferEntropy( dataseries, laglist(lidx), bins );
  end

end


% Copy the output.

telist = nan([ xcount, lagcount ]);

for lidx = 1:lagcount
  telist(:,lidx) = telistbylag{lidx}(:,1);
end


% Done.
end


%
% This is the end of the file.
