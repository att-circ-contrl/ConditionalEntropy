% Test code for the entropy library - Configuration.
% Written by Christopher Thomas.


%
% Switches.

want_test_entropy = true;


%
% Geometry.

size1d = 1000;
size2d = 100;
histbins = 32;


%
% Library support.

have_entropy = exist('entropy');
entropy_builtin_bins = 256;


%
% Single-channel data series.

data_1d_const = ones([ 1 size1d ]);
data_1d_ramp = 1:size1d;
data_1d_para = data_1d_ramp .* data_1d_ramp;
data_1d_unirand = rand([ 1 size1d ]);

datasets_1d = ...
{ data_1d_const,   'const1', '1D Constant' ; ...
  data_1d_ramp,    'ramp1',  '1D Ramp' ; ...
  data_1d_para,    'para1',  '1D Parabola' ; ...
  data_1d_unirand, 'urand1', '1D Uniform Random' };
datacount_1d = size(datasets_1d, 1);

data_2d_const = ones([ size2d size2d ]);
data_2d_ramp = 1:(size2d * size2d);
data_2d_ramp = reshape(data_2d_ramp, [ size2d size2d ]);
data_2d_para = data_2d_ramp .* data_2d_ramp;
data_2d_unirand = rand([ size2d size2d ]);

datasets_2d = ...
{ data_2d_const,   'const2', '2D Constant' ; ...
  data_2d_ramp,    'ramp2',  '2D Ramp' ; ...
  data_2d_para,    'para2',  '2D Parabola' ; ...
  data_2d_unirand, 'urand2', '2D Uniform Random' };
datacount_2d = size(datasets_2d, 1);

datasets_alldim = [ datasets_1d ; datasets_2d ];
datacount_alldim = size(datasets_alldim, 1);


%
% Multi-channel data series (for conditional entropy).

data_2ch_1d_corr = [ data_1d_ramp ; data_1d_ramp ];
data_2ch_1d_uncorr = [ data_1d_ramp ; data_1d_unirand ];

data_2ch_2d_corr = cat( 3, data_2d_ramp, data_2d_ramp );
data_2ch_2d_uncorr = cat( 3, data_2d_ramp, data_2d_unirand );


%
% Folders.

outdir = 'output';


%
% Miscellaneous constants.

newline = sprintf('\n');


%
% This is the end of the file.
