% Sample code for the entropy library.
% Written by Christopher Thomas.


%
% Configuration.


want_parallel = false;

swept_histbins = [ 8 16 32 ];
fixed_histbins_te = 8;

%swept_sampcounts_mi = [ 3000 10000 30000 100000 300000 ];
swept_sampcounts_mi = [ 3000 10000 30000 100000 ];
swept_sampcounts_te = [ 3000 10000 30000 ];

te_laglist = [ -15:15 ];
te_test_lag = 6;

signal_plot_samps = 300;

plotdir = 'plots';



%
% Startup.

addpath('../library');

if want_parallel
  parpool;
end



%
% Mutual information tests.


disp('== Testing mutual information.');

for sidx = 1:length(swept_sampcounts_mi)

  sampcount = swept_sampcounts_mi(sidx);

  tic;


  % Build test signals.

  signalY = helper_makeDataSignal( sampcount, 'sine' );
  signalX1 = helper_makeDataSignal( sampcount, 'sine' );
  signalX2 = helper_makeDataSignal( sampcount, 'sine' );

  signalX1 = 0.7 * signalX1 + 0.3 * signalY;
  signalX2 = 0.3 * signalX2 + 0.7 * signalY;

  datamatrix_weak = [ signalY ; signalX1 ];
  datamatrix_strong = [ signalY ; signalX2 ];
  datamatrix_3ch = [ signalY ; signalX1 ; signalX2 ];


  % Set up the 3-channel case as a Field Trip structure, to demonstrate that.

  ftdata_3ch = struct();
  ftdata_3ch.fsample = 1000;
  timeseries = 1:sampcount;
  ftdata_3ch.time = { (timeseries - 1) / 1000 };
  ftdata_3ch.label = { 'chY' ; 'chX1' ; 'chX2' };
  ftdata_3ch.trial = { datamatrix_3ch };


  % Compute mutual information.

  mutualbits_weak = ...
    nan([ length(swept_sampcounts_mi), length(swept_histbins) ]);
  mutualbits_strong = mutualbits_weak;
  mutualbits_extrap = mutualbits_weak;
  mutualbits_3ch = mutualbits_weak;

  for bidx = 1:length(swept_histbins)

    histbins = swept_histbins(bidx);

    % Calculate mutual information without extrapolation.

    mutualbits_weak( sidx, bidx ) = ...
      cEn_calcMutualInfo( datamatrix_weak, histbins );
    mutualbits_strong( sidx, bidx ) = ...
      cEn_calcMutualInfo( datamatrix_strong, histbins );


    % Calculate it again for the "strong" case, using extrapolation.
    % Do this by adding an extrapolation parameter structure as the last
    % argument. An empty structure gets filled with default settings.
    mutualbits_extrap( sidx, bidx ) = ...
      cEn_calcMutualInfo( datamatrix_strong, histbins, struct() );


    % Calculate 3-channel mutual information using a Field Trip structure.
    % No extrapolation.
    % Give it an empty channel list to say "use all channels".

    mutualbits_3ch( sidx, bidx ) = ...
      cEn_calcMutualInfoFT( ftdata_3ch, {}, histbins );

  end


  % Progress report.

  durstring = helper_makePrettyTime(toc);
  disp(sprintf( '.. Mutual information for %d samples took %s.', ...
    sampcount, durstring ));

end


% Plot the resulting estimates.

helper_plotMutualInfo( ...
  mutualbits_weak, swept_sampcounts_mi, swept_histbins, ...
  'Mutual Information (bits)', 'Mutual Information (weak coupling)', ...
  [ plotdir filesep 'mutual-weak.png' ] );

helper_plotMutualInfo( ...
  mutualbits_strong, swept_sampcounts_mi, swept_histbins, ...
  'Mutual Information (bits)', 'Mutual Information (strong coupling)', ...
  [ plotdir filesep 'mutual-strong.png' ] );

helper_plotMutualInfo( ...
  mutualbits_extrap, swept_sampcounts_mi, swept_histbins, ...
  'Mutual Information (bits)', 'Mutual Information (strong extrapolated)', ...
  [ plotdir filesep 'mutual-extrap.png' ] );

helper_plotMutualInfo( ...
  mutualbits_3ch, swept_sampcounts_mi, swept_histbins, ...
  'Mutual Information (bits)', 'Mutual Information (three channels)', ...
  [ plotdir filesep 'mutual-three.png' ] );


disp('== Finished testing mutual information.');



%
% This is the end of the file.
