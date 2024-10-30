function [ telist tevars ] = ...
  cEn_calcTransferEntropy( dataseries, laglist, bins, replicates, exparams )

% function [ telist tevars ] = ...
%   cEn_calcTransferEntropy( dataseries, laglist, bins, replicates, exparams )
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
% NOTE - To compute the estimated variance, we're adding the estimated
% variance of the two H[|] terms in the equation above. This is only correct
% if the two H[|] terms are independent RVs. They aren't, but if the
% variance of one is very much larger than the variance of the other, it's
% a close enough approximation. This should usually be the case, as one
% histogram has higher dimensionality than the other (and so has fewer
% elements per bin and much worse SNR for a given sample count).
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
% "replicates" is the number of bootstrapping proxies to use when estimating
%   the uncertainty in transfer entropy. Use 1, 0, or NaN to disable
%   bootstrapping.
% "exparams" is an optional structure containing extrapolation tuning
%   parameters, per EXTRAPOLATION.txt. If this is empty, default parameters
%   are used. If this is absent, no extrapolation is performed.
%
% "telist" is a (Nchans-1,Nlags) matrix containing transfer entropy
%   estimates from X_k (dataseries{k+1}) to Y (dataseries{1}) for each
%   time lag.
% "tevars" is a matrix containing the estimated variance of each element
%   in "telist".


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

xcount = length(dataseries) - 1;
lagcount = length(laglist);


% Unpack source and destination series.

dstseries = dataseries{1};
srcseries = dataseries(2:(xcount+1));


% Get bin definitions.
% This works with cell and numeric bin definitions.

if length(bins) > 1
  % We were given several bin definitions.
  dstbins = bins(1);
  srcbins = bins(2:length(bins));
else
  % We were only given one bin definition.
  % Expand it.
  dstbins = bins;
  srcbins(1:xcount) = bins;
end



%
% Walk through the lag list, building partial TE estimates.

telist = nan([ xcount, lagcount ]);
tevars = telist;

for lidx = 1:lagcount

  thislag = laglist(lidx);

  % Shift, crop, and concatenate the data trials.
  [ dstpresent dstpast srcpast ] = ...
    cEn_teHelperShiftAndLinearize( dstseries, srcseries, thislag, laglist );


  % NOTE - Palmigiano 2017 took the difference and then extrapolated (I think).
  % We're doing extrapolation before subtraction. These gave very similar
  % output in my tests, and we'd otherwise have to calculate H_allpast
  % repeatedly (once for each source signal).


  % We need the "conditioned on everything" conditional entropy for all
  % calculations, and it's the most expensive thing to compute.
  % So, compute it only once, before iterating sources.

  datamatrix_allpast = [ dstpresent ; dstpast ];
  bins_allpast = [ dstbins dstbins ];
  for xidx = 1:xcount
    datamatrix_allpast = [ datamatrix_allpast ; srcpast{xidx} ];
    bins_allpast = [ bins_allpast srcbins(xidx) ];
  end

  if want_extrap
    % We were given an extrapolation configuration.
    [ H_allpast H_allpast_var ] = cEn_calcConditionalShannon( ...
      datamatrix_allpast, bins_allpast, replicates, exparams );
  else
    % We were not given an extrapolation configuration.
    [ H_allpast H_allpast_var ] = cEn_calcConditionalShannon( ...
      datamatrix_allpast, bins_allpast, replicates );
  end


  % Walk through choices of primary source series.

  for srcidx = 1:xcount

    % Condition on everything _except_ this source.

    datamatrix_somepast = [ dstpresent ; dstpast ];
    bins_somepast = [ dstbins dstbins ];
    for xidx = 1:xcount
      if xidx ~= srcidx
        datamatrix_somepast = [ datamatrix_somepast ; srcpast{xidx} ];
        bins_somepast = [ bins_somepast srcbins(xidx) ];
      end
    end


    % Calculate conditional entropy.

    if want_extrap
      % We were given an extrapolation configuration.
      [ H_somepast H_somepast_var ] = cEn_calcConditionalShannon( ...
        datamatrix_somepast, bins_somepast, replicates, exparams );
    else
      % We were not given an extrapolation configuration.
      [ H_somepast H_somepast_var ] = cEn_calcConditionalShannon( ...
        datamatrix_somepast, bins_somepast, replicates );
    end


    % Compute and store this transfer entropy value.

    telist(srcidx,lidx) = H_somepast - H_allpast;
    % FIXME - Pretend that these are independent RVs.
    % They aren't, but if H_allpast_var is much larger (it likely will be),
    % this is still approximately correct.
    tevars(srcidx,lidx) = H_somepast_var + H_allpast_var;

  end

end


% Done.
end


%
% This is the end of the file.
