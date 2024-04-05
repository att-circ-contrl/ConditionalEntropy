function telist = cEn_calcTransferEntropy_MT( ...
  srcseries, dstseries, laglist, numbins, exparams )

% function telist = cEn_calcTransferEntropy_MT( ...
%   srcseries, dstseries, laglist, numbins, exparams )
%
% This is a wrapper for cEn_calcTransferEntropy() that tests different lags
% in parallel with each other. This requires the Parallel Computing Toolbox.
%
% This calculates the transfer entropy from Src to Dst, for a specified set
% of time lags.
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
% This is prohibitively expensive to compute, so a proxy is usually used
% that considers a sample at some distance in the past as a proxy for the
% entire past history:
%   TEx->y(tau) = H[Y(t)|Y(t-tau)] - H[Y(t)|Y(t-tau),X(t-tau)]
%
% "srcseries" is a vector of length Nsamples containing the source signal X.
% "dstseries" is a vector of length Nsamples containing the destination
%   signal Y.
% "laglist" is a vector containing sample lags to test. These correspond to
%   tau in the equation above. These may be negative (looking at the future).
% "numbins" is the number of bins to use for each signal's data when
%   constructing histograms.
% "exparams" is an optional structure containing extrapolation tuning
%   parameters, per EXTRAPOLATION.txt. If this is empty, default parameters
%   are used. If this is absent, no extrapolation is performed.
%
% "telist" is a vector with the same size as "laglist" containing transfer
%   entropy estimates for each specified time lag.


telist = nan(size(laglist));

if exist('exparams', 'var')
  parfor lagidx = 1:length(laglist)
    thislag = laglist(lagidx);

    % We were given an extrapolation configuration.
    telist(lagidx) = cEn_calcTransferEntropy( ...
      srcseries, dstseries, thislag, numbins, exparams );
  end
else
  parfor lagidx = 1:length(laglist)
    thislag = laglist(lagidx);

    % We were not given an extrapolation configuration.
    telist(lagidx) = cEn_calcTransferEntropy( ...
      srcseries, dstseries, thislag, numbins );
  end
end


% Done.
end


%
% This is the end of the file.
