% Test code for the entropy library - Configuration.
% Written by Christopher Thomas.


%
% Switches.

want_test_entropy = true;
want_test_conditional = false;


%
% Geometry.

size1d = 100000;
size2d = 300;
histbins = 32;


%
% Library support.

have_entropy = exist('entropy');
entropy_builtin_bins = 256;


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
  data_2d_unirand, 'urand2', '2D Uniform Random' };
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
% Folders.

outdir = 'output';


%
% Miscellaneous constants.

newline = sprintf('\n');


%
% This is the end of the file.
