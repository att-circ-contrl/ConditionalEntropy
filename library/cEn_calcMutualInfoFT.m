function bits = cEn_calcMutualInfoFT( ftdata, chanlist, bins, exparams )

% function bits = cEn_calcMutualInfoFT( ftdata, chanlist, bins, exparams )
%
% This calculates the mutual information associated with a set of signals.
% This is the amount of information shared between the variables, as
% measured by comparing the joint probability distribution with the
% distribution expected if the variables were independent.
%
% This processes Field Trip data as input, concatenating trials.
%
% This needs a large number of samples to generate accurate results. To
% compensate for smaller sample counts, this may optionally use the
% extrapolation method described in EXTRAPOLATION.txt.
%
% "ftdata" is a ft_datatype_raw data structure produced by Field Trip.
% "chanlist" is a cell array containing channel labels or a vector containing
%   channel indices. If the list is empty, all channels are used.
% "bins" is a scalar or vector (to generate bins) or a cell array (to supply
%   bin definitions). If it's a vector of length Nchans or a scalar, it
%   indicates how many bins to use for each channel's data. If it's a cell
%   array, bins{chanidx} provides the list of edges used for binning each
%   channel's data.
% "exparams" is an optional structure containing extrapolation tuning
%   parameters, per EXTRAPOLATION.txt. If this is empty, default parameters
%   are used. If this is absent, no extrapolation is performed.
%
% "bits" is a scalar with the mutual information, computed as the reduction
%   in information content vs the joint distribution of independent variables.


% Extract a data series matrix from the Field Trip data.
dataseries = cEn_ftHelperConcatTrials( ftdata, chanlist );

% Wrap the non-FT function.
if exist('exparams', 'var')
  bits = cEn_calcMutualInfo( dataseries, bins, exparams );
else
  bits = cEn_calcMutualInfo( dataseries, bins );
end


%
% This is the end of the file.
