function bits = cEn_calcExtrapShannon( dataseries, edges, exparams )

% function bits = cEn_calcExtrapShannon( dataseries, edges, exparams )
%
% FIXME - Don't use this. Its estimate is worse than without extrapolation.
% It's okay to use it with cEn_getNoExtrapWrapperParams(), to do a single
% evaluation without extrapolation.
%
% This calculates the total Shannon entropy associated with a signal. This
% is the average number of bits of information that you get from seeing an
% observation.
%
% This works by binning input data values into a histogram, treating that
% as a probability distribution, and calculating the Shannon entropy of
% each bin.
%
% This needs a large number of samples to generate accurate results. To
% compensate for smaller sample counts, this uses the extrapolation method
% described in cEn_calcExtrapWrapper().
%
% "dataseries" is a vector or matrix containing data samples. Dimensionality
%   is ignored (all samples are processed).
% "edges" is a vector of length (numbins+1) containing histogram bin edges.
% "exparams" is a structure containing extrapolation tuning parameters, per
%   cEn_calcExtrapWrapper. This may be empty.
%
% "bits" is a scalar with the average Shannon entropy of an observation.


% Wrap the binning and entropy calculation functions.
datafunc = @(funcdata) helper_calcShannon( funcdata, edges );

bits = cEn_calcExtrapWrapper( dataseries, datafunc, exparams );


% Done.
end


%
% Helper Functions

function thisentropy = helper_calcShannon( rawdata, edges )
  [ thisbinned scratch ] = histcounts( reshape(rawdata,1,[]), edges );
  thisentropy = cEn_calcShannonHist( thisbinned );
end


%
% This is the end of the file.
