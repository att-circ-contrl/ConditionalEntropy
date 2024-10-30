function [ bits bitvar ] = ...
  cEn_calcMutualInfo( dataseries, bins, replicates, exparams )

% function [ bits bitvar ] = ...
%   cEn_calcMutualInfo( dataseries, bins, replicates, exparams )
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
% "bins" is a scalar or vector (to generate bins) or a cell array (to supply
%   bin definitions). If it's a vector of length Nchans or a scalar, it
%   indicates how many bins to use for each channel's data. If it's a cell
%   array, bins{chanidx} provides the list of edges used for binning each
%   channel's data.
% "replicates" is the number of bootstrapping proxies to use when estimating
%   the uncertainty in mutual information. Use 1, 0, or NaN to disable
%   bootstrapping.
% "exparams" is an optional structure containing extrapolation tuning
%   parameters, per EXTRAPOLATION.txt. If this is empty, default parameters
%   are used. If this is absent, no extrapolation is performed.
%
% "bits" is a scalar with the mutual information, computed as the reduction
%   in information content vs the joint distribution of independent variables.
% "bitvar" is the estimated variance of "bits".


% Use consistent bin definitions.

if iscell(bins)
  % We were given edge lists.
  edges = bins;
else
  % We were given one or more bin counts; generate edge lists.
  edges = cEn_getMultivariateHistBins( dataseries, bins );
end


% Wrap the binning and mutual information calculation functions.
datafunc = @(funcdata) helper_calcMutualInfo( funcdata, edges );

% Add the extrapolation wrapper if desired.
wrapfunc = datafunc;
if exist('exparams', 'var')
  % We were given an extrapolation configuration; perform extrapolation.
  wrapfunc = ...
    @(funcdata) cEn_calcExtrapWrapper( dataseries, datafunc, exparams );
end

% Call the bootstrapping helper.
[ bits scratch bitvar ] = ...
  cEn_calcHelperBootstrap( dataseries, wrapfunc, replicates );


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
