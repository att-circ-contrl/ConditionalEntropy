function [ telist1 telist2 ] = cEn_calcPartialTE_MT( ...
  src1series, src2series, dstseries, laglist, bins, exparams )

% function [ telist1 telist2 ] = cEn_calcPartialTE_MT( ...
%   src1series, src2series, dstseries, laglist, bins, exparams )
%
% This is a wrapper for cEn_calcPartialTE() that tests different lags in
% parallel with each other. This requires the Parallel Computing Toolbox.
%
% This calculates the partial transfer entropy from Src1 to Dst and from
% Src2 to Dst, for a specified set of time lags.
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
% In principle a similar calculation could be done for N sources rather than
% for two, but that requires evaluating an (N+2) dimensional histogram.
% Doing that runs into several practical difficulties (memory, time, and
% needing a prohibitive number of samples to get good statistics).
%
% "src1series" is a vector of length Nsamples containing the source signal A.
% "src2series" is a vector of length Nsamples containing the source signal B.
% "dstseries" is a vector of length Nsamples containing the destination
%   signal Y.
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
% "telist1" is a vector with the same size as "laglist" containing transfer
%   entropy estimates from "src1series" to "dstseries" for each time lag.
% "telist2" is a vector with the same size as "laglist" containing transfer
%   entropy estimates from "src2series" to "dstseries" for each time lag.


% Metadata.
want_extrap = exist('exparams', 'var');

% Parfor wants this to exist even if we don't use it.
if ~want_extrap
  exparams = struct();
end


telist1 = nan(size(laglist));
telist2 = nan(size(laglist));

parfor lagidx = 1:length(laglist)

  thislag = laglist(lagidx);

  if want_extrap
    % We were given an extrapolation configuration.
    [ scratch1 scratch2 ] = cEn_calcPartialTE( ...
      src1series, src2series, dstseries, thislag, bins, exparams );
  else
    % We were not given an extrapolation configuration.
    [ scratch1 scratch2 ] = cEn_calcPartialTE( ...
      src1series, src2series, dstseries, thislag, bins );
  end

  telist1(lagidx) = scratch1;
  telist2(lagidx) = scratch2;

end


% Done.
end


%
% This is the end of the file.
