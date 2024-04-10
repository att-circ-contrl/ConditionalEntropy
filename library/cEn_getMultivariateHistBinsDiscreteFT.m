function edges = cEn_getMultivariateHistBinsDiscreteFT( ftdata, chanlist )

% function edges = cEn_getMultivariateHistBinsDiscreteFT( ftdata, chanlist )
%
% This finds a set of histogram bins for multivariate data such that if
% each variable were binned in isolation, each unique data value for that
% variable would have an associated bin.
%
% This processes Field Trip input.
%
% "ftdata" is a ft_datatype_raw structure produced by Field Trip.
% "chanlist" is a vector or cell array of length Nchans specifying which
%   channels to process. If this is a cell array, it contains Field Trip
%   channel labels. If this is a vector, it contains channel indices.
%
% "edges" {chanidx} is a cell array, with each cell containing a vector with
%   bin edges for one channel's data.


edges = {};

for cidx = 1:length(chanlist)

  thischan = chanlist(cidx);
  if iscell(thischan)
    thischan = thischan{1};
  end

  thisdata = cEn_ftHelperChannelToMatrix( ftdata, thischan );

  edges{cidx} = cEn_getHistBinsDiscrete( thisdata );

end


% Done.
end


%
% This is the end of the file.
