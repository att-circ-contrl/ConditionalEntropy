function [ bits bitvar ] = cEn_calcShannon( dataseries, bins, replicates )

% function [ bits bitvar ] = cEn_calcShannon( dataseries, bins, replicates )
%
% This calculates the total Shannon entropy associated with a signal.
% This is the average number of bits of information that you get from seeing
% an observation.
%
% Shannon entropy is:   H(X) = - sum_k[ P(x_k) * log2(P(x_k)) ]
% (This is the probability-weighted average of the individual bin entropies.)
%
% A histogram is built of the input signal values, with each histogram bin
% corresponding to an input symbol, and the histogram being the probability
% distribution across symbols.
%
% "dataseries" is the signal to evaluate.
% "bins" is a scalar (to generate uniform histogram bins) or a vector
%   (to specify histogram bin edges).
% "replicates" is the number of bootstrapping proxies to use when estimating
%   the uncertainty in the entropy. Use 1, 0, or NaN to disable bootstrapping.
%
% "bits" is a scalar with the average Shannon entropy of an observation.
% "bitvar" is the estimated variance of "bits".


dataseries = reshape( dataseries, 1, [] );

if length(bins) > 1
  binedges = bins;
else
  binedges = linspace( min(dataseries), max(dataseries), bins );
end

datafunc = @(funcdata) helper_calcShannon( funcdata, binedges );

% Call the bootstrapping helper.
[ bits scratch bitvar ] = ...
  cEn_calcHelperBootstrap( dataseries, datafunc, replicates );


% Done.
end



%
% Helper Functions

function thisentropy = helper_calcShannon( rawdata, edges )
  [ bincounts scratch ] = histcounts( rawdata, edges );
  thisentropy = cEn_calcShannonHist( bincounts );
end


%
% This is the end of the file.
