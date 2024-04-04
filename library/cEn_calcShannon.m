function bits = cEn_calcShannon( dataseries, bins )

% function bits = cEn_calcShannon( dataseries, bins )
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
%
% "bits" is a scalar with the average Shannon entropy of an observation.

dataseries = reshape( dataseries, 1, [] );

if length(bins) > 1
  binedges = bins;
else
  binedges = linspace( min(dataseries), max(dataseries), bins );
end

[ bincounts scratch ] = histcounts( dataseries, binedges );

bits = cEn_calcShannonHist( bincounts );


% Done.
end


%
% This is the end of the file.
