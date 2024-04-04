function bits = cEn_calcMutualInfo( dataseries, numbins, exparams )

% function bits = cEn_calcMutualInfo( dataseries, numbins, exparams )
%
% This calculates the mutual information associated with a set of signals.
% This is the amount of information shared between the variables, as
% measured by comparing the joint probability distribution with the
% distribution expected if the variables were independent.
%
% This needs a large number of samples to generate accurate results. To
% compensate for smaller sample counts, this may optionally use the
% extrapolation method described in EXTRAPOLATION.txt.
%
% "dataseries" is a (Nchans,Nsamples) matrix containing several data series.
% "numbins" is either a vector of length Nchans or a scalar, indicating how
%   many histogram bins to use for each channel's data.
% "exparams" is an optional structure containing extrapolation tuning
%   parameters, per EXTRAPOLATION.txt. If this is empty, default parameters
%   are used. If this is absent, no extrapolation is performed.
%
% "bits" is a scalar with the mutual information, computed as the reduction
%   in information content vs the joint distribution of independent variables.


% Use consistent bin definitions.
edges = cEn_getMultivariateHistBins( dataseries, numbins );


% Wrap the binning and mutual information calculation functions.
datafunc = @(funcdata) helper_calcMutualInfo( funcdata, edges );

if exist('extparams', 'var')
  % We were given an extrapolation configuration; perform extrapolation.
  bits = cEn_calcExtrapWrapper( dataseries, datafunc, exparams );
else
  % We were not given an extrapolation configuration; don't extrapolate.
  bits = datafunc(dataseries);
end


% Done.
end


%
% Helper Functions

function thismutual = helper_calcMutualInfo( rawdata, edges )
  [ thisbinned scratch ] = cEn_getBinnedMultivariate( rawdata, edges );
  thismutual = cEn_calcMutualInfoHist( thisbinned );
end


%
% This is the end of the file.
