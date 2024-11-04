function [ rlist rvars ] = ...
  cEn_calcLaggedPCorrFT( ftdata, chanlist, laglist, replicates )

% function [ rlist rvars ] = ...
%   cEn_calcLaggedPCorrFT( ftdata, chanlist, laglist, replicates )
%
% This calculates the Pearson's correlation coefficient between a destination
% signal and time-lagged source signals. This can be used as a proxy for
% mutual information; for Gaussian RVs, I(X,Y) = - (1/2) log( 1 - r^2 ).
%
% This processes Field Trip input, concatenating trials (after shifting).
%
% This tests different lags in parallel with each other. This requires the
% Parallel Computing Toolbox.
%
% "ftdata" is a ft_datatype_raw structure produced by Field Trip.
% "chanlist" is a vector or cell array of length Nchans specifying which
%   channels to process. If this is a cell array, it contains Field Trip
%   channel labels. If this is a vector, it contains channel indices. The
%   first channel (element 1) is the destination signal; remaining channels
%   are source signals.
% "laglist" is a vector containing sample time lags to test. These are
%   applied to the "source" signals. They may be negative (future times).
% "replicates" is the number of bootstrapping proxies to use when estimating
%   the uncertainty in the correlation coefficient. Use 1, 0, or NaN to
%   disable bootstrapping.
%
% "rlist" is a (Nchans-1,Nlags) matrix containing correlation coefficients
%   between X_k (dataseries{k+1}) to Y (dataseries{1}) for each time lag.
% "rvars" is a vector containing the estimated variance of each element
%   in "rlist".


% Convert Field Trip data into matrices.

dataseries = {};
for cidx = 1:length(chanlist)
  thischan = chanlist(cidx);
  if iscell(thischan)
    thischan = thischan{1};
  end

  dataseries{cidx} = cEn_ftHelperChannelToMatrix( ftdata, thischan );
end


% Wrap the non-FT function.
[ rlist, rvars ] = cEn_calcLaggedPCorr_MT( dataseries, laglist, replicates );


% Done.
end


%
% This is the end of the file.
