function bits = cEn_calcMutualInfoHist( bincounts )

% function bits = cEn_calcMutualInfoHist( bincounts )
%
% This calculates the mutual information associated with a multidimensional
% histogram. This is the amount of information shared between the variables,
% as measured by comparing the joint probability distribution with the
% distribution expected if the variables were independent.
%
% NOTE - This needs a large number of samples to generate accurate results!
%
% Mutual information is:
%   I(X,Y) = sum_j,k[  P(x_j,y_k) * log2( P(x_j,y_k) / P(x_j) P(y_k) )  ]
%
% For independent variables, where P(x_j,y_k) = P(x_j) * P(y_k), this
% is zero bits (since there is no shared information between X and Y).
%
% For more than two variables, this function computes MI using:
%   P(x_j, y_k, ...) / ( P(x_j) * P(y_k) * ... )
%
% "bincounts" is a matrix with at least 2 dimensions containing histogram
%   counts.
%
% "bits" is a scalar with the mutual information, computed as the reduction
%   in information content vs the joint distribution of independent variables.


% Turn this into a probability density function.
pxy = bincounts / sum(bincounts, 'all');


% Get the product of the univariate probability distributions.

dimsizes = size(pxy);
dimcount = length(dimsizes);

pxprod = ones(size(pxy));

for didx = 1:dimcount
  % Collapse everything except this dimension to get the univariate
  % distribution.
  thispx = pxy;
  for cidx = 1:dimcount
    if cidx ~= didx
      thispx = sum(thispx, cidx);
    end
  end

  % Expand it out again so that we can use elementwise multiplication.
  repdims = dimsizes;
  repdims(didx) = 1;
  thispx = repmat(thispx, repdims);

  % Multiply by this univariate distribution.
  pxprod = pxprod .* thispx;
end



% Calculate the mutual information.

bits = pxy .* log2( pxy ./ pxprod );
bits = bits(~isnan(bits));
% NOTE - Positive sum, not negative, for mutual information.
bits = sum( bits, 'all' );


% done.
end


%
% This is the end of the file.
