function dataseries = cEn_ftHelperConcatTrials( ftdata, chanlist )

% function dataseries = cEn_ftHelperConcatTrials( ftdata, chanlist )
%
% This extracts trial data from a ft_datatype_raw dataset, concatenates
% the trials, and returns a Nchans x Nsamples data matrix with selected
% channels.
%
% "ftdata" is a ft_datatype_raw structure containing trial data.
% "chanlist" is a cell array containing channel labels or a vector containing
%   channel indices. Channels are assembled in the order given in this list.
%   If the list is empty, ftdata.label is used as the list.
%
% "dataseries" is a Nchans x Nsamples matrix containing concatenated trial
%   data. Channels are copied in the order specified by "chanlist".


% Turn the channel list into indices.
% NOTE - Falling back to the first channel for invalid entries!

chanlist = cEn_ftHelperCheckChannels( ftdata.label, chanlist );
chanlist(isnan(chanlist)) = 1;


% Get geometry metadata.

trialcount = length(ftdata.trial);
chancount = length(chanlist);

sampcount = 0;
if ~isempty(ftdata.time)
  sampcount = length(ftdata.time{1});
end


% Build the output matrix.

dataseries = [];

for tidx = 1:trialcount
  thisraw = ftdata.trial{tidx};
  thisgrid = nan(chancount, sampcount);

  for cidx = 1:chancount
    thisgrid(cidx,:) = thisraw(chanlist(cidx), :);
  end

  dataseries = [ dataseries thisgrid ];
end


% Done.
end


%
% This is the end of the file.
