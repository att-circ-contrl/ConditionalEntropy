function bits = cEn_calcConditionalShannonHist( bincounts )

% function bits = cEn_calcConditionalShannonHist( bincounts )
%
% This calculates the conditional entropy associated with a multidimensional
% histogram. This is the average amount of additional information that a
% sample from variable Y gives you when you already know variable X.
%
% NOTE - This needs a large number of samples to generate accurate results!
%
% Conditional entropy is:
%   H(Y|X) = - sum_j,k[  P(x_j,y_k) * log2( P(x_j,y_k) / P(x_j) )  ]
%
% For independent variables, where P(x_j,y_k) = P(x_j) * P(y_k), this
% reduces to the Shannon entropy H(Y) (since X provided no information
% about Y).
%
% "bincounts" is a matrix with at least 2 dimensions containing histogram
%   counts. The first dimension corresponds to the variable Y. Remaining
%   dimensions are one or more X variables.
%
% "bits" is a scalar with the average additional entropy provided by an
%   observation of Y, when X is known.


% Turn this into a probability density function.
pxy = bincounts / sum(bincounts, 'all');


% Collapse the first dimension to get p(x).
px = sum(pxy, 1);

% Expand it out again so we can use elementwise division.
px = repmat(px, size(pxy,1), 1);


% Calculate the conditional entropy.

bits = pxy .* log2( pxy ./ px );
bits = bits(~isnan(bits));
bits = - sum( bits, 'all' );


% done.
end


%
% This is the end of the file.
