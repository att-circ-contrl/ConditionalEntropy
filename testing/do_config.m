% Test code for the entropy library - Configuration.
% Written by Christopher Thomas.


%
% Switches.

want_test_entropy = false;
want_test_conditional = false;
want_test_mutual = false;
want_test_transfer = false;


%
% Geometry.

sampcount = 10000;
histbins = 32;

te_laglist = [-10:10];
te_test_lag = 5;

swept_histbins = [ 8 16 32 ];

swept_sampcounts = [ 10000 30000 100000 ];
%swept_sampcounts = [ swept_sampcounts 300000 1000000 ];
%swept_sampcounts = [ swept_sampcounts 3000000 10000000 ];


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
% This is the end of the file.
