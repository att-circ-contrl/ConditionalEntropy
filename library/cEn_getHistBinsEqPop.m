function edges = cEn_getHistBinsEqPop( datavals, numbins )

% function edges = cEn_getHistBinsEqPop( datavals, numbins )
%
% This finds a set of histogram bin edges that results in having
% approximately equal numbers of samples in each bin.
%
% "datavals" is a vector or matrix containing samples to be binned.
% "numbins" is the number of bins.
%
% "edges" is a vector of length (numbins+1) containing bin edges.

prclist = 0:numbins;
prclist = prclist * 100 / numbins;

datavals = reshape(datavals, 1, []);

edges = prctile(datavals, prclist);

% If we had constant data, the edge values will all be the same. Fix that.
if length(unique(edges)) ~= length(edges)
  % It doesn't matter what we add, since we'll always end up in the first bin.
  % Leave the first element alone, in case of rounding errors.
  scratch = 1:numbins;
  scratch = scratch / numbins;
  edges(2:(numbins+1)) = edges(2:(numbins+1)) + scratch;
end


% Done.
end


%
% This is the end of the file.
