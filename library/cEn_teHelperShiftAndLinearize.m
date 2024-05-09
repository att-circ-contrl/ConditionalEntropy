function [ dstpresent dstpast srcpast ] = ...
  cEn_teHelperShiftAndLinearize( dstseries, srcseries, timelag, laglist )

% function [ dstpresent dstpast srcpast ] = ...
%   cEn_teHelperShiftAndLinearize( dstseries, srcseries, timelag, laglist )
%
% This produces cropped time-shfited series used for transfer entropy and
% partial transfer entropy calculations. Trials are concatenated after
% shifting and cropping.
%
% NOTE - Instead of shifting the "past" signals right, the "present" signal
% is shifted left (for testing positive time lags; reverse for negative).
%
% "dstseries" is a vector of length Nsamples or a Ntrials x Nsamples matrix
%   containing the destination signal Y.
% "srcseries" is a cell array of length Nsrcs containing source signals X_k.
%   These are either vectors of length Nsamples or matrices of size
%   Ntrials x Nsamples.
% "timelag" is the time lag to test, in samples.
% "laglist" is a vector containing all tested time lags (to get lag range).
%
% "dstpresent" is a 1xNoutsamps vector containing concatenated cropped
%   time-shifted trials from dstseries.
% "dstpast" is a 1xNoutsamps vector containing concatenated cropped trials
%   from dstseries.
% "srcpast" is a cell array of length Nsrcs containing 1xNoutsamps vectors
%   that are concatenated cropped trials from srcseries.


% Get metadata.

srccount = length(srcseries);



% If we were given vectors rather than matrices, make sure they're
% Ntrials x Nsamples.

if iscolumn(dstseries)
  dstseries = transpose(dstseries);
end

for sidx = 1:srccount
  thissrc = srcseries{sidx};
  if iscolumn(thissrc)
    srcseries{sidx} = transpose(thissrc);
  end
end



% Get the cropping range.

% NOTE - These really should be the same length, but bulletproof just in case.
nsamples = size(dstseries,2);
for sidx = 1:srccount
  nsamples = min([ nsamples, size(srcseries{sidx},2) ]);
end

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

% Instead of shifting the "past" versions right, shift "present" left.

dstpresent = circshift(dstseries, - timelag, 2);
dstpast = dstseries;
srcpast = srcseries;

% Crop to avoid wrapped portions.

dstpresent = dstpresent(:,firstsamp:lastsamp);
dstpast = dstpast(:,firstsamp:lastsamp);
for sidx = 1:srccount
  thissrc = srcpast{sidx};
  srcpast{sidx} = thissrc(:,firstsamp:lastsamp);
end

% Turn these into linear arrays.
% NOTE - Using a helper rather than "reshape", to guarantee consistent order.

dstpresent = helper_makeLinear(dstpresent);
dstpast = helper_makeLinear(dstpast);
for sidx = 1:srccount
  srcpast{sidx} = helper_makeLinear( srcpast{sidx} );
end



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
