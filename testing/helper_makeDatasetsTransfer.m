function [ datasets_2ch datasets_3ch ] = ...
  helper_makeDatasetsTransfer( sampcount, samp_shift )

% function [ datasets_2ch datasets_3ch ] = ...
%   helper_makeDatasetsTransfer( sampcount, samp_shift )
%
% This builds data series used for testing calculation of transfer entropy.
% and partial transfer entropy. Signal pairs that are correlated may be
% time-lagged. All sample values are in the range 0..1.
%
% Data matrices have Nchans x Nsamples elements. data(1,:) is the dependent
% series, and data(k,:) are the independent series.
%
% "sampcount" is the desired number of samples per series.
% "samp_shift" is the number of samples by which data series should be
%   shifted forward or backward in time, for time-lagged signals.
%
% "datasets_2ch" is a Nx3 cell array. Element {k,1} is a 2 x Nsamples matrix
%   containing data samples, element {k,2} is a short plot- and
%   filename-safe label, and element {k,3} is a plot-safe verbose label for
%   data series k.
% "datasets_3ch" is a Nx3 cell array. Element {k,1} is a 3 x Nsamples matrix
%   containing data samples, element {k,2} is a short plot- and
%   filename-safe label, and element {k,3} is a plot-safe verbose label for
%   data series k.


% Make several uncorrelated noise series. One of them's our "signal".

data_te_data = rand([ 1 sampcount ]);

data_te_noise1 = rand([ 1 sampcount ]);
data_te_noise2 = rand([ 1 sampcount ]);


% Explicitly smear the data signal by one sample.

data_te_data = 0.5 * ( data_te_data + circshift( data_te_data, 1) );


% Get signal-plus-noise series.

data_te_withnoise1 = 0.5 * (data_te_data + data_te_noise1);
data_te_withnoise2 = 0.5 * (data_te_data + data_te_noise2);


%
% Build two-channel test cases.

data_te_2ch_indep = [ data_te_data ; data_te_noise1 ];
data_te_2ch_self = [ data_te_data ; ...
  circshift( data_te_data, samp_shift ) ];

% This does nothing, since H(Y|Ypast) = H(Y|Y) = 0, and likewise H(Y|YX).
%data_te_2ch_nolag = [ data_te_data ; data_te_withnoise1 ];

data_te_2ch_pos = [ data_te_data ; ...
  circshift( data_te_withnoise1, samp_shift ) ];
data_te_2ch_neg = [ data_te_data ; ...
  circshift( data_te_withnoise1, -samp_shift ) ];


datasets_2ch = ...
{ data_te_2ch_indep, 'te2indep', '2ch None' ; ...
  data_te_2ch_self,  'te2self',  '2ch Self' ; ...
  data_te_2ch_pos,   'te2pos',   '2ch Pos Lag' ; ...
  data_te_2ch_neg,   'te2neg',   '2ch Neg Lag' };

% This does nothing, since H(Y|Ypast) = H(Y|Y) = 0, and likewise H(Y|YX).
%  data_te_2ch_nolag, 'te2nolag', '2ch 0 Lag' ; ...


%
% Build three-channel test cases, for partial transfer entropy calculations.


% Information from both but at different time lags (no conflict).
data_te_3ch_weak = [ data_te_data ; ...
  circshift( data_te_withnoise1, samp_shift ) ; ...
  circshift( data_te_withnoise2, -samp_shift ) ];

% Partly-redundant information from both.
data_te_3ch_olap = [ data_te_data ; ...
  circshift( data_te_withnoise1, samp_shift ) ; ...
  circshift( data_te_withnoise2, samp_shift ) ];

% Self-sourced information from one, which should swamp the other.
data_te_3ch_self = [ data_te_data ; ...
  circshift( data_te_withnoise1, samp_shift ) ; ...
  circshift( data_te_data, samp_shift ) ];

datasets_3ch = ...
{ data_te_3ch_weak, 'te3weak', '3ch Weak' ; ...
  data_te_3ch_olap, 'te3olap', '3ch Aligned' ; ...
  data_te_3ch_self, 'te3self', '3ch Self' };


%
% This is the end of the file.



% Done.
end


%
% This is the end of the file.
