% Test code for the entropy library - Configuration.
% Written by Christopher Thomas.


%
% Switches.

want_test_entropy = false;
want_test_conditional = false;
want_test_mutual = false;
want_test_transfer = true;

want_nonswept = true;

want_sweep_sampcount = false;
want_sweep_histbins = false;

want_parallel = true;


%
% Geometry.

sampcount = 30000;
histbins = 32;

te_laglist = [-10:10];
te_test_lag = 5;

swept_histbins = [ 8 16 32 ];

swept_sampcounts = [ 10000 ];
swept_sampcounts = [ swept_sampcounts 30000 100000 ];
%swept_sampcounts = [ swept_sampcounts 300000 1000000 ];
%swept_sampcounts = [ swept_sampcounts 3000000 10000000 ];


%
% Library support.

have_entropy = exist('entropy');
entropy_builtin_bins = 256;


%
% Folders.

outdir = 'output';
plotdir = 'plots';


%
% Miscellaneous constants.

newline = sprintf('\n');


%
% This is the end of the file.
