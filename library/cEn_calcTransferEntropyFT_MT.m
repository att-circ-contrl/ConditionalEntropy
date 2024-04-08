function telist = ...
  cEn_calcTransferEntropyFT_MT( ftdata, chanlist, laglist, bins, exparams )

% function telist = ...
%   cEn_calcTransferEntropyFT_MT( ftdata, chanlist, laglist, bins, exparams )
%
% This calculates the partial transfer entropy from signals X_1..X_k to
% signal Y, for a specified set of time lags. If there is only one X, this
% is the transfer entropy from X to Y.
%
% This processes Field Trip input, concatenating trials (after shifting).
%
% This calls cEn_calcTransferEntropy_MT(), which tests different lags in
% parallel with each other. This requires the Parallel Computing Toolbox.
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
% "ftdata" is a ft_datatype_raw structure produced by Field Trip.
% "chanlist" is a vector or cell array of length Nchans specifying which
%   channels to processes. If this is a cell array, it contains Field Trip
%   channel labels. If this is a vector, it contains channel indices. The
%   first channel (element 1) is the variable Y; remaining channels are X_k.
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
  telist = cEn_calcTransferEntropy_MT( dataseries, laglist, bins, exparams );
else
  % We were not given an extrapolation configuration.
  telist = cEn_calcTransferEntropy_MT( dataseries, laglist, bins );
end


% Done.
end


%
% This is the end of the file.
