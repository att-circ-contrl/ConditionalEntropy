function edges = cEn_getMultivariateHistBinsDiscrete( dataseries )

% function edges = cEn_getMultivariateHistBinsDiscrete( dataseries )
%
% This finds a set of histogram bins for multivariate data such that if
% each variable were binned in isolation, each unique data value for that
% variable would have an associated bin.
%
% "dataseries" is a (Nchans,Nsamples) matrix containing several data series.
%
% "edges" {chanidx} is a cell array, with each cell containing a vector with
%   bin edges for one channel's data.


nchans = size(dataseries,1);
edges = {};

% Generate bin edges.
for cidx = 1:nchans
  thisdata = dataseries(cidx,:);
  edges{cidx} = cEn_getHistBinsDiscrete( thisdata );
end


% Done.
end


%
% This is the end of the file.
