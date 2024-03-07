function edges = cEn_getMultivariateHistBins( dataseries, numbins )

% function edges = cEn_getMultivariateHistBins( dataseries, numbins )
%
% This finds a set of histogram bins for multivariate data such that if
% each variable were binned in isolation, each bin would have an
% approximately equal number of samples.
%
% "dataseries" is a (Nchans,Nsamples) matrix containing several data series.
% "numbins" is either a vector of length Nchans or a scalar, indicating how
%   many histogram bins to use for each channel's data.
%
% "edges" {chanidx} is a cell array, with each cell containing a vector with
%   bin edges for one channel's data.


nchans = size(dataseries,1);
edges = {};

% Turn numbins into a vector if it isn't one already.
if length(numbins) < nchans
  numbins = ones([1 nchans]) * numbins(1);
end

% Generate bin edges.
for cidx = 1:nchans
  thisdata = dataseries(cidx,:);
  edges{cidx} = cEn_getHistBinsEqPop( thisdata, numbins(cidx) );
end


% Done.
end


%
% This is the end of the file.
