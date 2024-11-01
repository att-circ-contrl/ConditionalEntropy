function [ rlist rvars ] = ...
  cEn_calcLaggedPCorr( dataseries, laglist, replicates )

% function [ rlist rvars ] = ...
%   cEn_calcLaggedPCorr( dataseries, laglist, replicates )
%
% This calculates the Pearson's correlation coefficient between a destination
% signal and time-lagged source signals. This can be used as a proxy for
% mutual information; for Gaussian RVs, I(X,Y) = - (1/2) log( 1 - r^2 ).
%
% "dataseries" is a Nchans x Nsamples matrix or a cell array of length
%   Nchans containing data series. The first series (chan = 1) is the
%   destination signal; remaining series are source signals. For cell
%   array data, each cell contains either a vector of length Nsamples or
%   a matrix of size Ntrials x Nsamples.
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


% Convert matrix data into single-trial cell data.

if ~iscell(dataseries)
  % This is a Nchans x Nsamples matrix.
  chancount = size(dataseries,1);
  scratch = {};
  for cidx = 1:chancount
    scratch{cidx} = dataseries(cidx,:);
  end
  dataseries = scratch;
end


% Get metadata.

xcount = length(dataseries) - 1;
lagcount = length(laglist);

% Unpack source and destination series.
dstseries = dataseries{1};
srcseries = dataseries(2:(xcount+1));



%
% Walk through the lag list, measuring correlation.

rlist = nan(size(laglist));
rvars = rlist;

for lidx = 1:lagcount

  thislag = laglist(lidx);

  % Shift, crop, and concatenate the data trials.
  % We don't care about "dstpast".
  [ dstpresent dstpast srcpast ] = ...
    cEn_teHelperShiftAndLinearize( dstseries, srcseries, thislag, laglist );


  % Calculate the correlation coefficient between each input and the output,
  % and estimate its variance via bootstrapping.

  for xidx = 1:xcount
    datamatrix = [ dstpresent ; srcpast{xidx} ];

    [ thisr scratch thisvar ] = ...
      cEn_calcHelperBootstrap( datamatrix, @helper_calcPCorr, replicates );

    rlist(xidx,lidx) = thisr;
    rvars(xidx,lidx) = thisvar;
  end

end


% Done.
end


%
% Helper Functions

function thisrval = helper_calcPCorr( datamatrix )
  % Blithely assume exactly two channels.
  rmatrix = corrcoef( datamatrix(1,:), datamatrix(2,:) );
  thisrval = rmatrix(1,2);
end


%
% This is the end of the file.
