function [ bincounts edges ] = cEn_getBinnedMultivariate( dataseries, bins )

% function [ bincounts edges ] = cEn_getBinnedMultivariate( dataseries, bins )
%
% This tallies multidimensional histogram counts representing the joint
% probability distribution between several data series. Histogram bins may
% either be generated or be supplied by the caller.
%
% If histogram bins are generated, they're chosen such that if each series
% were binned in isolation, each bin would have an approximately equal
% number of samples.
%
% NOTE - High-dimensional histograms can get very big very fast!
%
% "dataseries" is a (Nchans,Nsamples) matrix containing several data series.
% "bins" is a scalar or vector (to generate bins) or a cell array (to supply
%   bin definitions). If it's a vector of length Nchans or a scalar, it
%   indicates how many bins to use for each channel's data. If it's a cell
%   array, bins{chanidx} provides the list of edges used for binning each
%   channel's data.
%
% "bincounts" is a multidimensional matrix with histogram bin counts. The
%   k-th dimension corresponds to dataseries(k,:) and has length numbins(k).
% "edges" {chanidx} is a cell array, with each cell containing a vector with
%   bin edges for one channel's data.


% Get geometry.
nchans = size(dataseries,1);
nsamples = size(dataseries,2);



% Make sure we have bin counts _and_ edge lists.

if iscell(bins)
  edges = bins;
  numbins = [];

  for cidx = 1:nchans
    numbins(cidx) = length(edges{cidx}) - 1;
  end
else
  edges = {};
  numbins = bins;

  % Turn numbins into a vector if it isn't one already.
  if length(numbins) < nchans
    numbins = ones([1 nchans]) * numbins(1);
  end

  % Generate bin edges.
  for cidx = 1:nchans
    thisdata = dataseries(cidx,:);
    edges{cidx} = cEn_getHistBinsEqPop( thisdata, numbins(cidx) );
  end
end



% Turn input data series into input bin indices in each dimension.
% We can use "histcounts" to do this.

for cidx = 1:nchans
  thisdata = dataseries(cidx,:);

  [ scratchcounts scratchedges thisbinlist ] = ...
    histcounts( thisdata, edges{cidx} );

  dataseries(cidx,:) = thisbinlist;
end



% Walk through the data tuples, incrementing the relevant bin counts.

% Vector "numbins" specifies the multidimensional array size.
bincounts = zeros(numbins);

for sidx = 1:nsamples
  % FIXME - Doing matrix indexing this way is cursed, but it seems to be
  % the best available option.

  idxlist = dataseries(:,sidx);
  idxlist = num2cell(idxlist);

  bincounts(idxlist{:}) = bincounts(idxlist{:}) + 1;
end


% Done.
end


%
% This is the end of the file.
