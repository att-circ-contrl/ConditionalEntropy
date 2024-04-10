function edges = cEn_getHistBinsDiscrete( datavals )

% function edges = cEn_getHistBinsEqPop( datavals )
%
% This finds a set of histogram bin edges such that each unique data value
% in the input series has an associated bin.
%
% This is intended to be used with discrete-valued data (such as spike
% counts).
%
% "datavals" is a vector or matrix containing samples to be binned.
%
% "edges" is a vector containing bin edges.

% Get a sorted list of unique values.
datavals = reshape(datavals, 1, []);
datavals = unique(datavals);

% Special-case the "no data" and "only one data value" cases.
if length(datavals) < 1
  edges = [ 0 1 ];
elseif length(datavals) < 2
  edges = [ datavals(1) - 0.5, datavals(1) + 0.5 ];
else

  % We have at least two data points.
  % Get midpoint edges and then handle the endpoints.

  datacount = length(datavals);
  edges = 0.5 * ( datavals(1:(datacount-1)) + datavals(2:datacount) );

  firstval = datavals(1) + datavals(1) - edges(1);
  lastval = datavals(datacount) + datavals(datacount) - edges(datacount - 1);

  edges = [ firstval edges lastval ];

end


% Done.
end


%
% This is the end of the file.
