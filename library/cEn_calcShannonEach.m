function binbits = cEn_calcShannonEach( bincounts )

% function binbits = cEn_calcShannonEach( bincounts )
%
% This calculates the Shannon entropy associated with each bin in a
% histogram. This is the number of bits of information that you get from
% seeing an observation that was in that bin.
%
% Shannon entropy is:   H(x_k) = - log2( P(x_k) )
%
% "bincounts" is a vector or matrix containing histogram counts.
%
% "binbits" is a matrix with the same dimensions as "bincounts" that
%   contains the Shannon entropy corresponding to each bin.

totalcount = sum( bincounts, 'all' );
binbits = - log2( bincounts / totalcount );

% Done.
end


%
% This is the end of the file.
