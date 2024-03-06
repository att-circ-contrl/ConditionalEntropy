function bincounts = cEn_getBinnedMultivariate( dataseries, numbins )

% function bincounts = cEn_getBinnedMultivariate( dataseries, numbins )
%
% This tallies multidimensional histogram counts representing the joint
% probability distribution between several data series. Histogram bins
% are chosen such that if each series were binned in isolation, each bin
% would have an approximately equal number of samples.
%
% NOTE - High-dimensional histograms can get very big very fast!
%
% "dataseries" is a (Nchans,Nsamples) matrix containing several data series.
% "numbins" is either a vector of length Nchans or a scalar, indicating how
%   many bins to use for each channel's data.
%
% "bincounts" is a multidimensional matrix with histogram bin counts. The
%   k-th dimension corresponds to dataseries(k,:) and has length numbins(k).

% Get geometry.
nchans = size(dataseries,1);
nsamples = size(dataseries,2);

% Turn numbins into a vector if it isn't one already.
if length(numbins) < nchans
  numbins = ones([1 nchans]) * numbins(1);
end

% Initialize output. "numbins" specifies the multidimensional array size.
bincounts = zeros(numbins);


% Turn input data series into input bin indices in each dimension.
% We can use "histcounts" to do this.

for cidx = 1:nchans
  thisdata = dataseries(cidx,:);

  thisedgelist = cEn_getHistBinsEqPop( thisdata, numbins(cidx) );
  [ scratchcounts scratchedges thisbinlist ] = ...
    histcounts( thisdata, thisedgelist );

  dataseries(cidx,:) = thisbinlist;
end


% Walk through the data tuples, incrementing the relevant bin counts.

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
