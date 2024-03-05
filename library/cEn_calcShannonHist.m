function bits = cEn_calcShannonHist( bincounts )

% function bits = cEn_calcShannonHist( bincounts )
%
% This calculates the total Shannon entropy associated with a histogram.
% This is the average number of bits of information that you get from seeing
% an observation.
%
% Shannon entropy is:   H(X) = - sum_k[ P(x_k) * log2(P(x_k)) ]
% (This is the probability-weighted average of the individual bin entropies.)
%
% "bincounts" is a vector or matrix containing histogram counts.
%
% "binbits" is a matrix with the same dimensions as "bincounts" that
%   contains the Shannon entropy corresponding to each bin.

totalcount = sum( bincounts, 'all' );
probdensity = bincounts / totalcount;

bits = probdensity .* log2( probdensity );
bits = bits(~isnan(bits));
bits = - sum( bits, 'all' );

% Done.
end


%
% This is the end of the file.
