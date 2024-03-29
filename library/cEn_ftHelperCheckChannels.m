function chanindices = cEn_ftHelperCheckChannels( ftlabels, chanlist )

% function chanindices = cEn_ftHelperCheckChannels( ftlabels, chanlist )
%
% This checks a user-supplied list of channels or channel indices against
% a Field Trip channel list, translating and adjusting as needed.
%
% Invalid requested channels result in indices of NaN.
%
% "ftlabels" is the "label" cell array from a ft_datatype_raw structure.
% "chanlist" is a cell array containing channel labels or a vector containing
%   channel indices or a character vector containing a single channel label.
%   Channels are processed in the order given in this list. If the list is
%   empty, "ftlabels" is used as the list.
%
% "chanindices" is a vector of the same size as "chanlist" containing
%   channel indices of the requested channels, in the order specified by
%   "chanlist". Invalid requested channels have indices of NaN.


% Check for an empty list.

if isempty(chanlist)
  chanlist = ftlabels;
end


% Check for a single label and promote it to a list.

if ischar(chanlist)
  chanlist = { chanlist };
end


% If we have labels rather than indices, translate them if possible.

if iscell(chanlist)
  newlist = [];
  for cidx = 1:length(chanlist)
    thisidx = min(find( strcmp( chanlist{cidx}, ftlabels ) ));
    if isempty(thisidx)
      thisidx = NaN;
    end
    newlist(cidx) = thisidx;
  end
  chanlist = newlist;
end


% If anything's out of range, squash it.

validmask = (chanlist > 0) & (chanlist <= length(ftlabels));
chanlist(~validmask) = NaN;


% Copy the list.

chanindices = chanlist;



% Done.
end


%
% This is the end of the file.
