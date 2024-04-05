% Test code for the entropy library - Configuration.
% Written by Christopher Thomas.


%
% Switches.

want_test_entropy = false;
want_test_conditional = false;
want_test_mutual = false;
want_test_transfer = true;

want_nonswept = false;

want_sweep_sampcount = true;
want_sweep_histbins = true;

want_parallel = true;

want_test_ft = true;

want_plot_signals = false;


%
% Geometry.

sampcount = 10000;
histbins = 16;

te_laglist = [-10:10];
te_test_lag = 5;

swept_histbins = [ 8 16 32 ];

swept_sampcounts = [ ];
swept_sampcounts = [ swept_sampcounts 3000 ];
swept_sampcounts = [ swept_sampcounts 10000 ];
swept_sampcounts = [ swept_sampcounts 30000 ];
%swept_sampcounts = [ swept_sampcounts 100000 ];
%swept_sampcounts = [ swept_sampcounts 300000 1000000 ];
%swept_sampcounts = [ swept_sampcounts 3000000 10000000 ];

ft_trials = 10;


%
% Test signal parameters.

signal_type = 'noise';
%signal_type = 'sine';


%
% Plotting parameters.

signal_plot_samps = 300;


%
% Shannon entropy test config

have_entropy = exist('entropy');
entropy_builtin_bins = 256;

%shannon_method = 'hist';
shannon_method = 'edges';
%shannon_method = 'bins';


%
% Folders.

outdir = 'output';
plotdir = 'plots';


%
% Miscellaneous constants.

newline = sprintf('\n');


%
% This is the end of the file.
