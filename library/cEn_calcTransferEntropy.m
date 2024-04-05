function telist = cEn_calcTransferEntropy( ...
  srcseries, dstseries, laglist, numbins, exparams )

% function telist = cEn_calcTransferEntropy( ...
%   srcseries, dstseries, laglist, numbins, exparams )
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
% "srcseries" is a vector of length Nsamples or a Ntrials x Nsamples matrix
%   containing the source signal X.
% "dstseries" is a vector of length Nsamples or a Ntrials x Nsamples matrix
%   containing the destination signal Y.
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


% Metadata.
want_extrap = exist('exparams', 'var');


%
% Walk through the lag list, building TE estimates.

telist = nan(size(laglist));

for lidx = 1:length(laglist)

  thislag = laglist(lidx);

  % Shift, crop, and concatenate the data trials.
  % Supply the source sequence twice, since the helper expects two sources.
  [ dstpresent dstpast srcpast scratch ] = ...
    cEn_teHelperShiftAndLinearize( dstseries, srcseries, srcseries, ...
      thislag, laglist );


  % Assemble the conditional entropy data series.

  serieslength = length(dstpresent);

  datamatrix_y = zeros([ 2, serieslength ]);
  datamatrix_yx = zeros([ 3, serieslength ]);

  datamatrix_y(1,:) = dstpresent;
  datamatrix_y(2,:) = dstpast;

  datamatrix_yx(1,:) = dstpresent;
  datamatrix_yx(2,:) = dstpast;
  datamatrix_yx(3,:) = srcpast;


  if want_extrap
    % NOTE - Palmigiano 2017 took the difference and then extrapolated (I
    % think).
    % Offer the option of doing the extrapolation and then the subtraction.
    % These give very similar output in my tests.

    if false
      % Subtract and then extrapolate, per Palmigiano 2017.
      % Use a consistent set of edges for histogram binning during
      % extrapolation.
      edges = cEn_getMultivariateHistBins( datamatrix_yx, numbins );
      datafunc = @(funcdata) helper_calcTE( funcdata, edges );
      thiste = cEn_calcExtrapWrapper( datamatrix_yx, datafunc, exparams );
    else
      % Extrapolate and then subtract.
      thiste = ...
        cEn_calcConditionalShannon( datamatrix_y, numbins, exparams ) ...
        - cEn_calcConditionalShannon( datamatrix_yx, numbins, exparams );
    end
  else
    % We were not given an extrapolation configuration; don't extrapolate.
    thiste = cEn_calcConditionalShannon( datamatrix_y, numbins ) ...
      - cEn_calcConditionalShannon( datamatrix_yx, numbins );
  end

  telist(lidx) = thiste;

end


% Done.
end


%
% Helper Functions

function thiste = helper_calcTE( data_yx, edges_yx )

  data_y = data_yx(1:2,:);
  edges_y = edges_yx(1:2);

  [ binned_y scratch ] = cEn_getBinnedMultivariate( data_y, edges_y );
  [ binned_yx scratch ] = cEn_getBinnedMultivariate( data_yx, edges_yx );

  thiste = cEn_calcConditionalShannonHist( binned_y ) ...
    - cEn_calcConditionalShannonHist( binned_yx );
end


%
% This is the end of the file.
