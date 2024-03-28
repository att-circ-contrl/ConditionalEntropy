function dataseries = cEn_ftHelperChannelToMatrix( ftdata, chanwanted )

% function dataseries = cEn_ftHelperChannelToMatrix( ftdata, chanwanted )
%
% This extracts one channel's trials from a ft_datatype_raw dataset and
% converts it to a Ntrials x Nsamples data matrix.
%
% "ftdata" is a ft_datatype_raw structure containing trial data.
% "chanwanted" is a character vector containing a channel label, or a
%   scalar containing a channel index. If this is empty or invalid, the
%   first channel in ftdata.label is chosen.
%
% "dataseries" is a Ntrials x Nsamples matrix containing the desired
%   channel's trial data.


% Bulletproof the desired channel.

if ischar(chanwanted) && (~isempty(chanwanted))
  chanwanted = min(find( strcmp( chanwanted, ftdata.label ) ));
end

if isempty(chanwanted)
  chanwanted = 1;
end

if (chanwanted < 1) || (chanwanted > length(ftdata.label))
  chanwanted = 1;
end


% Get geometry metadata.

trialcount = length(ftdata.trial);
sampcount = 0;
if ~isempty(ftdata.time)
  sampcount = length(ftdata.time{1});
end


% Build the output matrix.

dataseries = [];

for tidx = 1:trialcount
  thisraw = ftdata.trial{tidx};
  thisseries = thisraw(chanwanted,:);
  dataseries = [ dataseries ; thisseries ];
end


% Done.
end


%
% This is the end of the file.
