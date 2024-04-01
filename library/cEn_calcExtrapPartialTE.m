function [ telist1 telist2 ] = cEn_calcExtrapPartialTE( ...
  src1series, src2series, dstseries, laglist, numbins, exparams )

% function [ telist1 telist2 ] = cEn_calcExtrapPartialTE( ...
%   src1series, src2series, dstseries, laglist, numbins, exparams )
%
% This calculates the partial transfer entropy from Src1 to Dst and from
% Src2 to Dst, for a specified set of time lags.
%
% NOTE - This needs a large number of samples to generate accurate results!
% To compensate for smaller sample counts, this uses the extrapolation
% method described in EXTRAPOLATION.txt (per Palmigiano 2017).
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
% "numbins" is the number of bins to use for each signal's data when
%   constructing histograms.
% "exparams" is a structure containing extrapolation tuning parameters, per
%   EXTRAPOLATION.txt. This may be empty.
%
% "telist1" is a vector with the same size as "laglist" containing transfer
%   entropy estimates from "src1series" to "dstseries" for each time lag.
% "telist2" is a vector with the same size as "laglist" containing transfer
%   entropy estimates from "src2series" to "dstseries" for each time lag.


%
% Walk through the lag list, building partial TE estimates.

telist1 = nan(size(laglist));
telist2 = nan(size(laglist));

for lidx = 1:length(laglist)

  thislag = laglist(lidx);

  % Shift, crop, and concatenate the data trials.
  [ dstpresent dstpast src1past src2past ] = ...
    cEn_teHelperShiftAndLinearize( dstseries, src1series, src2series, ...
      thislag, laglist );


  % Assemble the conditional entropy data series.
  % Since evaluating the four-dimensional histogram takes most of the time,
  % build a->y and b->y three-dimensional histograms and compute both of
  % those partial TEs, instead of just one.

  serieslength = length(dstpresent);

  datamatrix_ya = zeros([ 3, serieslength ]);
  datamatrix_yb = zeros([ 3, serieslength ]);
  datamatrix_yab = zeros([ 4, serieslength ]);

  datamatrix_ya(1,:) = dstpresent;
  datamatrix_ya(2,:) = dstpast;
  datamatrix_ya(3,:) = src1past;

  datamatrix_yb(1,:) = dstpresent;
  datamatrix_yb(2,:) = dstpast;
  datamatrix_yb(3,:) = src2past;

  datamatrix_yab(1,:) = dstpresent;
  datamatrix_yab(2,:) = dstpast;
  datamatrix_yab(3,:) = src1past;
  datamatrix_yab(4,:) = src2past;


  % NOTE - Palmigiano 2017 took the difference and then extrapolated (I think).
  % We're doing extrapolation before subtraction. These gave very similar
  % output in my tests, and we'd otherwise have to calculate H_yab twice.

  H_ya = ...
    cEn_calcExtrapConditionalShannon( datamatrix_ya, numbins, exparams );
  H_yb = ...
    cEn_calcExtrapConditionalShannon( datamatrix_yb, numbins, exparams );
  H_yab = ...
    cEn_calcExtrapConditionalShannon( datamatrix_yab, numbins, exparams );

  % Output 1 (A) is conditioned on B, and vice versa.
  thiste1 = H_yb - H_yab;
  thiste2 = H_ya - H_yab;

  telist1(lidx) = thiste1;
  telist2(lidx) = thiste2;

end


% Done.
end


%
% This is the end of the file.
