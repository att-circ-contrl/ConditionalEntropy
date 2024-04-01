function [ dstpresent dstpast src1past src2past ] = ...
  cEn_teHelperShiftAndLinearize( dstseries, src1series, src2series, ...
    timelag, laglist )

% function [ dstpresent dstpast src1past src2past ] = ...
%   cEn_teHelperShiftAndLinearize( dstseries, src1series, src2series, ...
%     timelag, laglist )
%
% This produces cropped time-shfited series used for transfer entropy and
% partial transfer entropy calculations.
%
% NOTE - Instead of shfiting the "past" signals left, the "present" signal
% is shifted right (for positive time lags; reverse for negative).
%
% "dstseries" is a vector of length Nsamples or a Ntrials x Nsamples matrix
%   containing the destination signal Y.
% "src1series" is a vector of length Nsamples or a Ntrials x Nsamples matrix
%   containing the source signal X1.
% "src2series" is a vector of length Nsamples or a Ntrials x Nsamples matrix
%   containing the source signal X2.
% "timelag" is the time lag to test, in samples.
% "laglist" is a vector containing all tested time lags.
%
% "dstpresent" is a vector containing concatenated cropped time-shifted
%   trials from dstseries.
% "dstpast" is a vector containing concatenated cropped trials from dstseries.
% "src1past" is a vector containing concatenated cropped trials from
%   src1series.
% "src2past" is a vector containing concatenated cropped trials from
%   src2series.


% If we were given vectors rather than matrices, make sure they're
% Ntrials x Nsamples.

if iscolumn(dstseries)
  dstseries = transpose(dstseries);
end

if iscolumn(src1series)
  src1series = transpose(src1series);
end

if iscolumn(src2series)
  src1series = transpose(src2series);
end



% Get the cropping range.

% NOTE - These really should be the same length, but bulletproof just in case.
nsamples = ...
  min( [ size(dstseries,2), size(src1series,2), size(src2series,2) ] );

% Zero or negative.
minlag = min(laglist);
minlag = min(minlag, 0);

% Zero or positive.
maxlag = max(laglist);
maxlag = max(maxlag, 0);

firstsamp = 1 + maxlag;
lastsamp = nsamples + minlag;

% FIXME - Not checking for lag larger than input size!


% Shift, crop, and concatenate.

% Instead of shifting the "past" versions left, shift "present" right.

dstpresent = circshift(dstseries, timelag, 2);
dstpast = dstseries;
src1past = src1series;
src2past = src2series;

% Crop to avoid wrapped portions.

dstpresent = dstpresent(:,firstsamp:lastsamp);
dstpast = dstpast(:,firstsamp:lastsamp);
src1past = src1past(:,firstsamp:lastsamp);
src2past = src2past(:,firstsamp:lastsamp);

% Turn these into linear arrays.
% NOTE - Using a helper rather than "reshape", to guarantee consistent order.

dstpresent = helper_makeLinear(dstpresent);
dstpast = helper_makeLinear(dstpast);
src1past = helper_makeLinear(src1past);
src2past = helper_makeLinear(src2past);



% Done.
end



%
% Helper Functions

function flatseries = helper_makeLinear(trialseries)

  ntrials = size(trialseries,1);

  flatseries = [];

  for tidx = 1:ntrials
    flatseries = [ flatseries trialseries(tidx,:) ];
  end

end


%
% This is the end of the file.
