function telist = cEn_calcFTTransferEntropy( ...
  ftdata, srcchan, dstchan, laglist, numbins, exparams )

% function telist = cEn_calcFTTransferEntropy( ...
%   ftdata, srcchan, dstchan, laglist, numbins, exparams )
%
% This calculates the transfer entropy from Src to Dst, for a specified set
% of time lags.
%
% This processes Field Trip input, concatenating trials (after shifting).
%
% NOTE - This needs a large number of samples to generate accurate results!
% To compensate for smaller sample counts, this uses the extrapolation
% method described in EXTRAPOLATION.txt (per Palmigiano 2017).
%
% Transfer entropy from X to Y is defined as:
%   TEx->y = H[Y|Ypast] - H[Y|Ypast,Xpast]
% This is the amount of additional information gained about the future of Y
% by knowing the past of X, vs just knowing the past of Y.
%
% This is prohibitively expensive to compute, so a proxy is usually used
% that considers a sample at some distance in the past as a proxy for the
% entire past history:
%   TEx->y(tau) = H[Y(t)|Y(t-tau)] - H[Y(t)|Y(t-tau),X(t-tau)]
%
% "ftdata" is a ft_datatype_raw data structure produced by Field Trip.
% "srcchan" is a character vector containing a channel label, or a scalar
%   containing a channel index. This specifies the source channel X.
% "dstchan" is a character vector containing a channel label, or a scalar
%   containing a channel index. This specifies the destinaion channel Y.
% "laglist" is a vector containing sample lays to test. These correspond to
%   tau in the equation above. These may be negative (looking at the future).
% "numbins" is the number of bins to use for each signal's data when
%   constructing histograms.
% "exparams" is a structure containing extrapolation tuning parameters, per
%   EXTRAPOLATION.txt. This may be empty.
%
% "telist" is a vector with the same size as "laglist" containing transfer
%   entropy estimates for each specified time lag.


% Bulletproof the desired channel indices.

srcchan = helper_checkChannel(ftdata, srcchan);
dstchan = helper_checkChannel(ftdata, dstchan);


% Extract the desired signals.

srcseries = cEn_ftHelperChannelToMatrix(ftdata, srcchan);
dstseries = cEn_ftHelperChannelToMatrix(ftdata, dstchan);


% Wrap the TE function.

telist = cEn_calcExtrapTransferEntropy( ...
  srcseries, dstseries, laglist, numbins, exparams );


% Done.
end


%
% Helper Functions

function chanidx = helper_checkChannel(ftdata, chanlabel)

  chanidx = chanlabel;

  if ischar(chanidx) && (~isempty(chanidx))
    chanidx = min(find( strcmp( chanidx, ftdata.label ) ));
  end

  if isempty(chanidx)
    chanidx = 1;
  end

  if (chanidx < 1 ) || (chanidx > length(ftdata.label))
    chanidx = 1;
  end

end


%
% This is the end of the file.
