% Sample code for the entropy library.
% Written by Christopher Thomas.


%
% Configuration.

% This needs the Parallel Computing Toolbox.
want_parallel = false;

swept_histbins = [ 8 16 32 ];
fixed_histbins_te = 8;

% 30k takes a minute or two. Higher counts are more informative.
swept_sampcounts = [ 3000 10000 30000 ];
%swept_sampcounts = [ swept_sampcounts 100000 ];
%swept_sampcounts = [ swept_sampcounts 300000 ];
%swept_sampcounts = [ swept_sampcounts 1000000 ];

laglist = [ -15:15 ];
test_lag = 6;

signal_plot_samps = 300;

plotdir = 'plots';



%
% Startup.

addpath('../library');

if want_parallel
  parpool;
end



%
% Compute mutual information, lagged mutual information, and transfer
% entropy.


% Initialize output data.
% We aggregate it and then plot as a separate step.

mutualbits_weak = ...
  nan([ length(swept_sampcounts), length(swept_histbins) ]);
mutualbits_strong = mutualbits_weak;
mutualbits_extrap = mutualbits_weak;
mutualbits_3ch = mutualbits_weak;

mutualbits_lagged_st = ...
  nan([ length(laglist), length(swept_sampcounts), length(swept_histbins) ]);
mutualbits_lagged_wk = mutualbits_lagged_st;
mutualbits_discrete = mutualbits_lagged_st;

transferbits_st = mutualbits_lagged_st;
transferbits_wk = mutualbits_lagged_st;
transferbits_discrete = mutualbits_lagged_st;

ptebits_st = mutualbits_lagged_st;
ptebits_wk = mutualbits_lagged_st;


% Iterate sample counts.

for sidx = 1:length(swept_sampcounts)

  sampcount = swept_sampcounts(sidx);

  disp(sprintf('== Calculating statistics for %d samples.', sampcount));


  %
  % Build test signals.

  signalData = helper_makeDataSignal( sampcount, 'sine' );
  signalN1 = helper_makeDataSignal( sampcount, 'sine' );
  signalN2 = helper_makeDataSignal( sampcount, 'sine' );
  signalN3 = helper_makeDataSignal( sampcount, 'sine' );

  signalY = 0.7 * signalData + 0.3 * signalN1;
  signalXst = 0.7 * signalData + 0.3 * signalN2;
  signalXwk = 0.4 * signalData + 0.6 * signalN3;

  datamatrix_strong = [ signalY ; signalXst ];
  datamatrix_weak = [ signalY ; signalXwk ];
  datamatrix_3ch = [ signalY ; signalXst ; signalXwk ];

  datamatrix_lagged_st = [ signalY ; circshift( signalXst, test_lag ) ];
  datamatrix_lagged_wk = [ signalY ; circshift( signalXwk, test_lag ) ];
  datamatrix_3ch_lagged = ...
    [ signalY ; circshift( signalXst, test_lag ) ; ...
      circshift( signalXwk, test_lag ) ];

  discreteData = helper_makeDataSignal( sampcount, 'counts' );
  discreteN1 = helper_makeDataSignal( sampcount, 'counts' );
  discreteN2 = helper_makeDataSignal( sampcount, 'counts' );

  discreteY = discreteData + discreteN1;
  discreteX = discreteData + discreteN2;

  datamatrix_discrete = [ discreteY ; circshift( discreteX, test_lag ) ];


  % Plot the signals for one sample count, to show what they're like.

  if 1 == sidx
    helper_plotDataSignals(datamatrix_strong, { 'Y', 'Xst' }, ...
      signal_plot_samps, 'Strongly Coupled Signals', ...
      [ plotdir filesep 'signals-strong.png' ] );

    helper_plotDataSignals(datamatrix_weak, { 'Y', 'Xwk' }, ...
      signal_plot_samps, 'Weakly Coupled Signals', ...
      [ plotdir filesep 'signals-weak.png' ] );

    helper_plotDataSignals(datamatrix_lagged_st, { 'Y', 'Xst' }, ...
      signal_plot_samps, 'Time-Lagged Signals', ...
      [ plotdir filesep 'signals-lagged.png' ] );

    helper_plotDataSignals(datamatrix_discrete, { 'Y', 'X' }, ...
      signal_plot_samps, 'Time-Lagged Discrete Signals (event counts)', ...
      [ plotdir filesep 'signals-discrete.png' ] );
  end


  % Set up the 3-channel cases as Field Trip structures, to demonstrate that.

  ftdata_3ch = struct();
  ftdata_3ch.fsample = 1000;
  timeseries = 1:sampcount;
  ftdata_3ch.time = { (timeseries - 1) / 1000 };
  ftdata_3ch.label = { 'chY' ; 'chXst' ; 'chXwk' };
  ftdata_3ch.trial = { datamatrix_3ch };

  ftdata_3ch_lagged = ftdata_3ch;
  ftdata_3ch_lagged.label = { 'chY' ; 'chXst' ; 'chXwk' };
  ftdata_3ch_lagged.trial = { datamatrix_3ch_lagged };


  %
  % Compute mutual information.

  tic;

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
  disp([ '.. Mutual information took ' durstring '.' ]);


  %
  % Compute time-lagged mutual information.
  % This is similar to pairwise transfer entropy but is cheaper to compute.

  tic;

  for bidx = 1:length(swept_histbins)

    histbins = swept_histbins(bidx);

    % Don't use extrapolation for the demo.
    % Results are similar to above: It converges faster but isn't monotonic.

    if want_parallel
      mutualbits_lagged_st(:, sidx, bidx) = cEn_calcLaggedMutualInfo_MT( ...
        datamatrix_lagged_st, laglist, histbins );
      mutualbits_lagged_wk(:, sidx, bidx) = cEn_calcLaggedMutualInfo_MT( ...
        datamatrix_lagged_wk, laglist, histbins );

      mutualbits_discrete(:, sidx, bidx) = cEn_calcLaggedMutualInfo_MT( ...
        datamatrix_discrete, laglist, histbins );
    else
      mutualbits_lagged_st(:, sidx, bidx) = cEn_calcLaggedMutualInfo( ...
        datamatrix_lagged_st, laglist, histbins );
      mutualbits_lagged_wk(:, sidx, bidx) = cEn_calcLaggedMutualInfo( ...
        datamatrix_lagged_wk, laglist, histbins );

      mutualbits_discrete(:, sidx, bidx) = cEn_calcLaggedMutualInfo( ...
        datamatrix_discrete, laglist, histbins );
    end

  end

  % Progress report.

  durstring = helper_makePrettyTime(toc);
  disp([ '.. Lagged mutual information took ' durstring '.' ]);


  %
  % Compute two-channel transfer entropy.

  tic;

  for bidx = 1:length(swept_histbins)

    histbins = swept_histbins(bidx);

    % Don't use extrapolation for the demo.
    % Results are similar to above: It converges faster but isn't monotonic.

    if want_parallel
      transferbits_st(:, sidx, bidx) = cEn_calcTransferEntropy_MT( ...
        datamatrix_lagged_st, laglist, histbins );
      transferbits_wk(:, sidx, bidx) = cEn_calcTransferEntropy_MT( ...
        datamatrix_lagged_wk, laglist, histbins );

      transferbits_discrete(:, sidx, bidx) = cEn_calcTransferEntropy_MT( ...
        datamatrix_discrete, laglist, histbins );
    else
      transferbits_st(:, sidx, bidx) = cEn_calcTransferEntropy( ...
        datamatrix_lagged_st, laglist, histbins );
      transferbits_wk(:, sidx, bidx) = cEn_calcTransferEntropy( ...
        datamatrix_lagged_wk, laglist, histbins );

      transferbits_discrete(:, sidx, bidx) = cEn_calcTransferEntropy( ...
        datamatrix_discrete, laglist, histbins );
    end

  end

  % Progress report.

  durstring = helper_makePrettyTime(toc);
  disp([ '.. Two-channel transfer entropy took ' durstring '.' ]);


  %
  % Compute partial transfer entropy.

  tic;

  for bidx = 1:length(swept_histbins)

    histbins = swept_histbins(bidx);

    % Don't use extrapolation for the demo.
    % Results are similar to above: It converges faster but isn't monotonic.

    % Show how to do this with Field Trip data.
    % We can give a cell array of channel names or a vector of channel
    % indices. If we give {} or [], it means "use all channels".

    if want_parallel
      ptedata = cEn_calcTransferEntropyFT_MT( ...
        ftdata_3ch_lagged, { 'chY', 'chXst', 'chXwk' }, laglist, histbins );
      ptebits_st( :, sidx, bidx ) = ptedata(1,:);
      ptebits_wk( :, sidx, bidx ) = ptedata(2,:);
    else
      ptedata = cEn_calcTransferEntropyFT( ...
        ftdata_3ch_lagged, { 'chY', 'chXst', 'chXwk' }, laglist, histbins );
      ptebits_st( :, sidx, bidx ) = ptedata(1,:);
      ptebits_wk( :, sidx, bidx ) = ptedata(2,:);
    end

  end

  % Progress report.

  durstring = helper_makePrettyTime(toc);
  disp([ '.. Partial transfer entropy took ' durstring '.' ]);

end

disp('== Finished calculating statistics.');



%
% Plot the resulting mutual information and transfer entropy estimates.

disp('== Generating plots.');


% Mutual information.

helper_plotMutualInfo( ...
  mutualbits_weak, swept_sampcounts, swept_histbins, ...
  'Mutual Information (bits)', 'Mutual Information (weak coupling)', ...
  [ plotdir filesep 'mutual-weak.png' ] );

helper_plotMutualInfo( ...
  mutualbits_strong, swept_sampcounts, swept_histbins, ...
  'Mutual Information (bits)', 'Mutual Information (strong coupling)', ...
  [ plotdir filesep 'mutual-strong.png' ] );

helper_plotMutualInfo( ...
  mutualbits_extrap, swept_sampcounts, swept_histbins, ...
  'Mutual Information (bits)', ...
  'Mutual Information (strong coupling) (extrapolated)', ...
  [ plotdir filesep 'mutual-extrap.png' ] );

helper_plotMutualInfo( ...
  mutualbits_3ch, swept_sampcounts, swept_histbins, ...
  'Mutual Information (bits)', 'Mutual Information (three channels)', ...
  [ plotdir filesep 'mutual-three.png' ] );


% Time-lagged mutual information.

helper_plotLagged( ...
  mutualbits_lagged_st, ...
  laglist, test_lag, swept_sampcounts, swept_histbins, ...
  'Mutual Information (bits)', ...
  'Time-Lagged Mutual Information (strong channel)', ...
  [ plotdir filesep 'lagged-mutual-st-%s.png' ] );

helper_plotLagged( ...
  mutualbits_lagged_wk, ...
  laglist, test_lag, swept_sampcounts, swept_histbins, ...
  'Mutual Information (bits)', ...
  'Time-Lagged Mutual Information (weak channel)', ...
  [ plotdir filesep 'lagged-mutual-wk-%s.png' ] );

helper_plotLagged( ...
  mutualbits_discrete, ...
  laglist, test_lag, swept_sampcounts, swept_histbins, ...
  'Mutual Information (bits)', ...
  'Time-Lagged Mutual Information (discrete events)', ...
  [ plotdir filesep 'lagged-mutual-disc-%s.png' ] );


% Transfer entropy.

helper_plotLagged( ...
  transferbits_st, laglist, test_lag, swept_sampcounts, swept_histbins, ...
  'Transfer Entropy (bits)', 'Transfer Entropy (strong channel)', ...
  [ plotdir filesep 'transfer-st-%s.png' ], 'squashzero' );

helper_plotLagged( ...
  transferbits_wk, laglist, test_lag, swept_sampcounts, swept_histbins, ...
  'Transfer Entropy (bits)', 'Transfer Entropy (weak channel)', ...
  [ plotdir filesep 'transfer-wk-%s.png' ], 'squashzero' );

helper_plotLagged( ...
  transferbits_discrete, ...
  laglist, test_lag, swept_sampcounts, swept_histbins, ...
  'Transfer Entropy (bits)', 'Transfer Entropy (discrete events)', ...
  [ plotdir filesep 'transfer-disc-%s.png' ], 'squashzero' );


% Partial transfer entropy.

helper_plotLagged( ...
  ptebits_st, laglist, test_lag, swept_sampcounts, swept_histbins, ...
  'Transfer Entropy (bits)', 'Partial Transfer Entropy (strong channel)', ...
  [ plotdir filesep 'pte-st-%s.png' ], 'squashzero' );

helper_plotLagged( ...
  ptebits_wk, laglist, test_lag, swept_sampcounts, swept_histbins, ...
  'Transfer Entropy (bits)', 'Partial Transfer Entropy (weak channel)', ...
  [ plotdir filesep 'pte-wk-%s.png' ], 'squashzero' );


disp('== Finished generating plots.');



%
% This is the end of the file.
