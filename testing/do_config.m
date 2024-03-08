% Test code for the entropy library - Configuration.
% Written by Christopher Thomas.


%
% Switches.

want_test_entropy = false;
want_test_conditional = false;
want_test_transfer = true;


%
% Geometry.

size1d = 100000;
size2d = round(sqrt(size1d));
histbins = 32;

te_max_shift = 10;


%
% Library support.

have_entropy = exist('entropy');
entropy_builtin_bins = 256;


%
% Folders.

outdir = 'output';


%
% Miscellaneous constants.

newline = sprintf('\n');


%
% Single-channel data series.


% All of these have data ranging from 0..1.

data_1d_const = ones([ 1 size1d ]);
data_1d_ramp = 1:size1d;

data_1d_ramp = data_1d_ramp / max(data_1d_ramp);
data_1d_para = data_1d_ramp .* data_1d_ramp;

data_1d_norm = normrnd(0.5, 0.17, [ 1 size1d ]);
data_1d_norm = min(data_1d_norm, 1);
data_1d_norm = max(data_1d_norm, 0);

data_1d_unirand = rand([ 1 size1d ]);

datasets_1d = ...
{ data_1d_const,   'const1', '1D Constant' ; ...
  data_1d_ramp,    'ramp1',  '1D Ramp' ; ...
  data_1d_para,    'para1',  '1D Parabola' ; ...
  data_1d_norm,    'norm1',  '1D Normal' ; ...
  data_1d_unirand, 'urand1', '1D Uniform Random' };
datacount_1d = size(datasets_1d, 1);


% All of these have data ranging from 0..1.

data_2d_const = ones([ size2d size2d ]);

data_2d_ramp = 1:(size2d * size2d);
data_2d_ramp = reshape(data_2d_ramp, [ size2d size2d ]);
data_2d_ramp = data_2d_ramp / max(data_2d_ramp, [], 'all');

data_2d_para = data_2d_ramp .* data_2d_ramp;

data_2d_norm = normrnd(0.5, 0.17, [ size2d size2d ]);
data_2d_norm = min(data_2d_norm, 1);
data_2d_norm = max(data_2d_norm, 0);

data_2d_unirand = rand([ size2d size2d ]);

datasets_2d = ...
{ data_2d_const,   'const2', '2D Constant' ; ...
  data_2d_ramp,    'ramp2',  '2D Ramp' ; ...
  data_2d_para,    'para2',  '2D Parabola' ; ...
  data_2d_norm,    'norm2',  '2D Normal' ; ...
  data_2d_unirand, 'urand2', '2D Unif Random' };
datacount_2d = size(datasets_2d, 1);

datasets_alldim = [ datasets_1d ; datasets_2d ];
datacount_alldim = size(datasets_alldim, 1);


%
% Multi-channel data series (for conditional entropy).

% Make sure our noisy channels' noise isn't correlated with unirand noise.
data_1d_noise1 = rand(size(data_1d_unirand));
data_1d_noise2 = rand(size(data_1d_unirand));
data_1d_noisyramp1 = 0.5 * (data_1d_ramp + data_1d_noise1);
data_1d_noisyramp2 = 0.5 * (data_1d_ramp + data_1d_noise2);
data_2ch_corr = [ data_1d_ramp ; data_1d_ramp ];
data_2ch_semicorr = [ data_1d_ramp; data_1d_noisyramp1 ];
data_2ch_uncorr = [ data_1d_ramp ; data_1d_unirand ];

data_3ch_onecorr = [ data_1d_ramp ; data_1d_noisyramp1 ; data_1d_unirand ];
data_3ch_bothcorr = [ data_1d_ramp; data_1d_noisyramp1; data_1d_noisyramp2 ];

datasets_cond = ...
{ data_2ch_corr,     'cond2corr',  '2ch Strong' ; ...
  data_2ch_semicorr, 'cond2semi',  '2ch Weak' ; ...
  data_2ch_uncorr,   'cond2indep', '2ch None' ; ...
  data_3ch_onecorr,  'cond3one',   '3ch One' ; ...
  data_3ch_bothcorr, 'cond3both',  '3ch Both' };
datacount_conditional = size(datasets_cond, 1);


%
% Shifted multi-channel data series (for transfer entropy).

te_test_shift = round(te_max_shift * 0.5);

% NOTE - The ramp doesn't change much across nearby samples. We need a
% data signal that does; so use noise.

data_te_data = rand(size(data_1d_unirand));
% Explicitly smear this by one sample.
data_te_data = 0.5 * ( data_te_data + circshift( data_te_data, 1) );

data_te_noise1 = data_1d_noise1;
data_te_noise2 = data_1d_noise2;

data_te_withnoise1 = 0.5 * (data_te_data + data_te_noise1);
data_te_withnoise2 = 0.5 * (data_te_data + data_te_noise2);

data_te_2ch_indep = [ data_te_data ; data_te_noise1 ];
data_te_2ch_self = [ data_te_data ; ...
  circshift( data_te_data, te_test_shift ) ];
% This does nothing, since H(Y|Ypast) = H(Y|Y) = 0, and likewise H(Y|YX).
%data_te_2ch_nolag = [ data_te_data ; data_te_withnoise1 ];
data_te_2ch_pos = [ data_te_data ; ...
  circshift( data_te_withnoise1, te_test_shift ) ];
data_te_2ch_neg = [ data_te_data ; ...
  circshift( data_te_withnoise1, -te_test_shift ) ];

% Information from both but at different time lags (no conflict).
data_te_3ch_weak = [ data_te_data ; ...
  circshift( data_te_withnoise1, te_test_shift ) ; ...
  circshift( data_te_withnoise2, -te_test_shift ) ];
% Partly-redundant information from both.
data_te_3ch_olap = [ data_te_data ; ...
  circshift( data_te_withnoise1, te_test_shift ) ; ...
  circshift( data_te_withnoise2, te_test_shift ) ];
% Self-sourced information from one, which should swamp the other.
data_te_3ch_self = [ data_te_data ; ...
  circshift( data_te_withnoise1, te_test_shift ) ; ...
  circshift( data_te_data, te_test_shift ) ];

datasets_te_2ch = ...
{ data_te_2ch_indep, 'te2indep', '2ch None' ; ...
  data_te_2ch_self,  'te2self',  '2ch Self' ; ...
  data_te_2ch_pos,   'te2pos',   '2ch Pos Lag' ; ...
  data_te_2ch_neg,   'te2neg',   '2ch Neg Lag' };
%  data_te_2ch_nolag, 'te2nolag', '2ch 0 Lag' ; ...
datacount_te_2ch = size(datasets_te_2ch, 1);

datasets_te_3ch = ...
{ data_te_3ch_weak, 'te3weak', '3ch Weak' ; ...
  data_te_3ch_olap, 'te3olap', '3ch Aligned' ; ...
  data_te_3ch_self, 'te3self', '3ch Self' };
datacount_te_3ch = size(datasets_te_3ch, 1);


%
% This is the end of the file.
