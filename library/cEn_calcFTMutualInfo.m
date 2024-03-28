function bits = cEn_calcFTMutualInfo( ftdata, chanlist, numbins, exparams )

% function bits = cEn_calcFTMutualInfo( ftdata, chanlist, numbins, exparams )
%
% This calculates the mutual information associated with a set of signals.
% This is the amount of information shared between the variables, as
% measured by comparing the joint probability distribution with the
% distribution expected if the variables were independent.
%
% This processes Field Trip data as input, concatenating trials.
%
% This needs a large number of samples to generate accurate results. To
% compensate for smaller sample counts, this uses the extrapolation method
% described in EXTRAPOLATION.txt.
%
% "ftdata" is a ft_datatype_raw data structure produced by Field Trip.
% "chanlist" is a cell array containing channel labels or a vector containing
%   channel indices. If the list is empty, all channels are used.
% "numbins" is either a vector of length Nchans or a scalar, indicating how
%   many histogram bins to use for each channel's data.
% "exparams" is a structure containing extrapolation tuning parameters, per
%   EXTRAPOLATION.txt. This may be empty.
%
% "bits" is a scalar with the mutual information, computed as the reduction
%   in information content vs the joint distribution of independent variables.


% Extract a data series matrix from the Field Trip data.
dataseries = cEn_ftHelperConcatTrials( ftdata, chanlist );

% Wrap the non-FT function.
bits = cEn_calcExtrapMutualInfo( dataseries, numbins, exparams );


%
% This is the end of the file.
