% Sample code for the entropy library.
% Written by Christopher Thomas.


%
% Configuration.

% This needs the Parallel Computing Toolbox.
want_parallel = false;

swept_histbins = [ 8 16 32 ];

% 30k takes a minute or two. Higher counts are more informative.
swept_sampcounts = [ 3000 10000 ];
swept_sampcounts = [ swept_sampcounts 30000 ];
swept_sampcounts = [ 1000 swept_sampcounts ];
%swept_sampcounts = [ swept_sampcounts 100000 ];
%swept_sampcounts = [ swept_sampcounts 300000 ];
%swept_sampcounts = [ swept_sampcounts 1000000 ];

% This slows down computation by a factor of N to estimate variance.
if true
  replicates_mi = 30;
  replicates_te = 10;
else
  replicates_mi = 1;
  replicates_te = 1;
end

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

mutualvars_weak = mutualbits_weak;
mutualvars_strong = mutualbits_weak;
mutualvars_extrap = mutualbits_weak;
mutualvars_3ch = mutualbits_weak;

mutualbits_lagged_st = ...
  nan([ length(laglist), length(swept_sampcounts), length(swept_histbins) ]);
mutualbits_lagged_wk = mutualbits_lagged_st;
mutualbits_discrete = mutualbits_lagged_st;
mutualbits_discrete_auto = ...
  nan([ length(laglist), length(swept_sampcounts), 1 ]);

mutualvars_lagged_st = mutualbits_lagged_st;
mutualvars_lagged_wk = mutualbits_lagged_st;
mutualvars_discrete = mutualbits_lagged_st;
mutualvars_discrete_auto = mutualbits_discrete_auto;


% Remember that the correlation coefficient doesn't need histogram bins.
pcorr_st = mutualbits_discrete_auto;
pcorr_wk = pcorr_st;
pcorr_discrete = pcorr_st;

pcvars_st = pcorr_st;
pcvars_wk = pcorr_st;
pcvars_discrete = pcorr_st;


transferbits_st = mutualbits_lagged_st;
transferbits_wk = mutualbits_lagged_st;
transferbits_discrete = mutualbits_lagged_st;
transferbits_discrete_auto = mutualbits_discrete_auto;

transfervars_st = mutualbits_lagged_st;
transfervars_wk = mutualbits_lagged_st;
transfervars_discrete = mutualbits_lagged_st;
transfervars_discrete_auto = mutualbits_discrete_auto;

ptebits_st = mutualbits_lagged_st;
ptebits_wk = mutualbits_lagged_st;

ptevars_st = mutualbits_lagged_st;
ptevars_wk = mutualbits_lagged_st;


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

  datamatrix_lagged_st = [ signalY ; circshift( signalXst, -test_lag ) ];
  datamatrix_lagged_wk = [ signalY ; circshift( signalXwk, -test_lag ) ];
  datamatrix_3ch_lagged = ...
    [ signalY ; circshift( signalXst, test_lag ) ; ...
      circshift( signalXwk, test_lag ) ];

  discreteData = helper_makeDataSignal( sampcount, 'counts' );
  discreteN1 = helper_makeDataSignal( sampcount, 'counts' );
  discreteN2 = helper_makeDataSignal( sampcount, 'counts' );

  discreteY = discreteData + discreteN1;
  discreteX = discreteData + discreteN2;

  datamatrix_discrete = [ discreteY ; circshift( discreteX, -test_lag ) ];


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

    [ mutualbits_weak( sidx, bidx ), mutualvars_weak( sidx, bidx ) ]= ...
      cEn_calcMutualInfo( datamatrix_weak, histbins, replicates_mi );
    [ mutualbits_strong( sidx, bidx ), mutualvars_strong( sidx, bidx ) ] = ...
      cEn_calcMutualInfo( datamatrix_strong, histbins, replicates_mi );


    % Calculate it again for the "weak" case, using extrapolation.
    % Do this by adding an extrapolation parameter structure as the last
    % argument. An empty structure gets filled with default settings.

    [ mutualbits_extrap( sidx, bidx ), mutualvars_extrap( sidx, bidx ) ] = ...
      cEn_calcMutualInfo( datamatrix_weak, histbins, replicates_mi, struct() );


    % Calculate 3-channel mutual information using a Field Trip structure.
    % No extrapolation.
    % Give it an empty channel list to say "use all channels".

    [ mutualbits_3ch( sidx, bidx ), mutualvars_3ch( sidx, bidx ) ] = ...
      cEn_calcMutualInfoFT( ftdata_3ch, {}, histbins, replicates_mi );

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
      [ mutualbits_lagged_st(:, sidx, bidx), ...
        mutualvars_lagged_st(:, sidx, bidx ) ] = ...
        cEn_calcLaggedMutualInfo_MT( ...
          datamatrix_lagged_st, laglist, histbins, replicates_mi );

      [ mutualbits_lagged_wk(:, sidx, bidx), ...
        mutualvars_lagged_wk(:, sidx, bidx ) ] = ...
        cEn_calcLaggedMutualInfo_MT( ...
          datamatrix_lagged_wk, laglist, histbins, replicates_mi );

      [ mutualbits_discrete(:, sidx, bidx), ...
        mutualvars_discrete(:, sidx, bidx ) ] = ...
        cEn_calcLaggedMutualInfo_MT( ...
          datamatrix_discrete, laglist, histbins, replicates_mi );
    else
      [ mutualbits_lagged_st(:, sidx, bidx), ...
        mutualvars_lagged_st(:, sidx, bidx ) ] = ...
        cEn_calcLaggedMutualInfo( ...
          datamatrix_lagged_st, laglist, histbins, replicates_mi );

      [ mutualbits_lagged_wk(:, sidx, bidx), ...
        mutualvars_lagged_wk(:, sidx, bidx ) ] = ...
        cEn_calcLaggedMutualInfo( ...
          datamatrix_lagged_wk, laglist, histbins, replicates_mi );

      [ mutualbits_discrete(:, sidx, bidx), ...
        mutualvars_discrete(:, sidx, bidx ) ] = ...
        cEn_calcLaggedMutualInfo( ...
          datamatrix_discrete, laglist, histbins, replicates_mi );
    end

  end

  % For discrete data (event counts), we have the option of using one bin
  % per count value. There's a FT version of this function too.

  histbins = cEn_getMultivariateHistBinsDiscrete( datamatrix_discrete );

  % NOTE - Report the number of histogram bins.
  % "histbins" is a cell array of vectors with bin edges.
  thismsg = '.. Auto-detected bin counts for discrete data: ';
  for bidx = 1:length(histbins)
    thismsg = [ thismsg sprintf('  %d', length(histbins{bidx}) - 1) ];
  end
  disp(thismsg);

  if want_parallel
    [ mutualbits_discrete_auto(:,sidx,1), ...
      mutualvars_discrete_auto(:,sidx,1) ] = cEn_calcLaggedMutualInfo_MT( ...
      datamatrix_discrete, laglist, histbins, replicates_mi );
  else
    [ mutualbits_discrete_auto(:,sidx,1), ...
      mutualvars_discrete_auto(:,sidx,1) ] = cEn_calcLaggedMutualInfo( ...
      datamatrix_discrete, laglist, histbins, replicates_mi );
  end

  % Progress report.

  durstring = helper_makePrettyTime(toc);
  disp([ '.. Lagged mutual information took ' durstring '.' ]);


  %
  % Compute time-lagged Pearson's correlation.
  % This can be used as a proxy for mutual information; for Gaussian RVs,
  % I(X,Y) = - (1/2) log( 1 - r^2 ).

  tic;

  % This doesn't use histogram bins.

  if want_parallel
% FIXME - NYI.
  else
    [ pcorr_st(:,sidx,1), pcvars_st(:,sidx,1) ] = ...
      cEn_calcLaggedPCorr( datamatrix_lagged_st, laglist, replicates_mi );

    [ pcorr_wk(:,sidx,1), pcvars_wk(:,sidx,1) ] = ...
      cEn_calcLaggedPCorr( datamatrix_lagged_wk, laglist, replicates_mi );

    [ pcorr_discrete(:,sidx,1), pcvars_discrete(:,sidx,1) ] = ...
      cEn_calcLaggedPCorr( datamatrix_discrete, laglist, replicates_mi );
  end

  % Progress report.

  durstring = helper_makePrettyTime(toc);
  disp([ '.. Lagged Pearson''s correlation took ' durstring '.' ]);


  %
  % Compute two-channel transfer entropy.

  tic;

  for bidx = 1:length(swept_histbins)

    histbins = swept_histbins(bidx);

    % Don't use extrapolation for the demo.
    % Results are similar to above: It converges faster but isn't monotonic.

    if want_parallel
      [ transferbits_st(:, sidx, bidx), ...
        transfervars_st(:, sidx, bidx) ] = cEn_calcTransferEntropy_MT( ...
        datamatrix_lagged_st, laglist, histbins, replicates_te );

      [ transferbits_wk(:, sidx, bidx), ...
        transfervars_wk(:, sidx, bidx) ] = cEn_calcTransferEntropy_MT( ...
        datamatrix_lagged_wk, laglist, histbins, replicates_te );

      [ transferbits_discrete(:, sidx, bidx), ...
        transfervars_discrete(:, sidx, bidx) ] = ...
        cEn_calcTransferEntropy_MT( ...
          datamatrix_discrete, laglist, histbins, replicates_te );
    else
      [ transferbits_st(:, sidx, bidx), ...
        transfervars_st(:, sidx, bidx) ] = cEn_calcTransferEntropy( ...
        datamatrix_lagged_st, laglist, histbins, replicates_te );

      [ transferbits_wk(:, sidx, bidx), ...
        transfervars_wk(:, sidx, bidx) ] = cEn_calcTransferEntropy( ...
        datamatrix_lagged_wk, laglist, histbins, replicates_te );

      [ transferbits_discrete(:, sidx, bidx), ...
        transfervars_discrete(:, sidx, bidx) ] = ...
        cEn_calcTransferEntropy( ...
          datamatrix_discrete, laglist, histbins, replicates_te );
    end

  end

  % For discrete data (event counts), we have the option of using one bin
  % per count value. There's a FT version of this function too.

  histbins = cEn_getMultivariateHistBinsDiscrete( datamatrix_discrete );

  if want_parallel
    [ transferbits_discrete_auto(:,sidx,1), ...
      transferbits_discrete_auto(:,sidx,1) ] = cEn_calcTransferEntropy_MT( ...
      datamatrix_discrete, laglist, histbins, replicates_te );
  else
    [ transferbits_discrete_auto(:,sidx,1), ...
      transferbits_discrete_auto(:,sidx,1) ] = cEn_calcTransferEntropy( ...
      datamatrix_discrete, laglist, histbins, replicates_te );
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
      [ ptedata ptedata_var ] = cEn_calcTransferEntropyFT_MT( ...
        ftdata_3ch_lagged, { 'chY', 'chXst', 'chXwk' }, ...
        laglist, histbins, replicates_te );
      ptebits_st( :, sidx, bidx ) = ptedata(1,:);
      ptebits_wk( :, sidx, bidx ) = ptedata(2,:);
      ptevars_st( :, sidx, bidx ) = ptedata_var(1,:);
      ptevars_wk( :, sidx, bidx ) = ptedata_var(2,:);
    else
      [ ptedata ptedata_var ] = cEn_calcTransferEntropyFT( ...
        ftdata_3ch_lagged, { 'chY', 'chXst', 'chXwk' }, ...
        laglist, histbins, replicates_te );
      ptebits_st( :, sidx, bidx ) = ptedata(1,:);
      ptebits_wk( :, sidx, bidx ) = ptedata(2,:);
      ptevars_st( :, sidx, bidx ) = ptedata_var(1,:);
      ptevars_wk( :, sidx, bidx ) = ptedata_var(2,:);
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
  mutualbits_weak, mutualvars_weak, swept_sampcounts, swept_histbins, ...
  'Mutual Information (bits)', 'Mutual Information (weak coupling)', ...
  [ plotdir filesep 'mutual-weak.png' ] );

helper_plotMutualInfo( ...
  mutualbits_strong, mutualvars_strong, swept_sampcounts, swept_histbins, ...
  'Mutual Information (bits)', 'Mutual Information (strong coupling)', ...
  [ plotdir filesep 'mutual-strong.png' ] );

helper_plotMutualInfo( ...
  mutualbits_extrap, mutualvars_extrap, swept_sampcounts, swept_histbins, ...
  'Mutual Information (bits)', ...
  'Mutual Information (weak coupling) (extrapolated)', ...
  [ plotdir filesep 'mutual-extrap.png' ] );

helper_plotMutualInfo( ...
  mutualbits_3ch, mutualvars_3ch, swept_sampcounts, swept_histbins, ...
  'Mutual Information (bits)', 'Mutual Information (three channels)', ...
  [ plotdir filesep 'mutual-three.png' ] );


% Time-lagged mutual information.

helper_plotLagged( ...
  mutualbits_lagged_st, mutualvars_lagged_st, ...
  laglist, test_lag, swept_sampcounts, swept_histbins, ...
  'Mutual Information (bits)', ...
  'Time-Lagged Mutual Information (strong channel)', ...
  [ plotdir filesep 'lagged-mutual-st-%s.png' ] );

helper_plotLagged( ...
  mutualbits_lagged_wk, mutualvars_lagged_wk, ...
  laglist, test_lag, swept_sampcounts, swept_histbins, ...
  'Mutual Information (bits)', ...
  'Time-Lagged Mutual Information (weak channel)', ...
  [ plotdir filesep 'lagged-mutual-wk-%s.png' ] );

helper_plotLagged( ...
  mutualbits_discrete, mutualvars_discrete, ...
  laglist, test_lag, swept_sampcounts, swept_histbins, ...
  'Mutual Information (bits)', ...
  'Time-Lagged Mutual Information (discrete events)', ...
  [ plotdir filesep 'lagged-mutual-disc-%s.png' ] );

helper_plotLagged( ...
  mutualbits_discrete_auto, mutualvars_discrete_auto, ...
  laglist, test_lag, swept_sampcounts, NaN, ...
  'Mutual Information (bits)', ...
  'Time-Lagged Mutual Information (discrete events)', ...
  [ plotdir filesep 'lagged-mutual-autodisc-%s.png' ] );


% Time-lagged Pearson's correlation.
% This didn't use swept bins.

if true
  % NOTE - Plot r^2, not r, to keep axis scale consistent.
  % For confidence intervals much smaller than the mean (s << u),
  % the variance of x2 is approximately 4*x2*s2.

  pcorr_st = pcorr_st .* pcorr_st;
  pcvars_st = 4 * pcvars_st .* pcorr_st;

  pcorr_wk = pcorr_wk .* pcorr_wk;
  pcvars_wk = 4 * pcvars_wk .* pcorr_wk;

  pcorr_discrete = pcorr_discrete .* pcorr_discrete;
  pcvars_discrete = 4 * pcvars_discrete .* pcorr_discrete;

  pearsonunits = 'Squared Pearson''s Correlation';
else
  pearsonunits = 'Pearson''s Correlation';
end

helper_plotLagged( ...
  pcorr_st, pcvars_st, ...
  laglist, test_lag, swept_sampcounts, NaN, ...
  pearsonunits, ...
  'Time-Lagged Pearson''s Correlation (strong channel)', ...
  [ plotdir filesep 'lagged-pcorr-st-%s.png' ] );

helper_plotLagged( ...
  pcorr_wk, pcvars_wk, ...
  laglist, test_lag, swept_sampcounts, NaN, ...
  pearsonunits, ...
  'Time-Lagged Pearson''s Correlation (weak channel)', ...
  [ plotdir filesep 'lagged-pcorr-wk-%s.png' ] );

helper_plotLagged( ...
  pcorr_discrete, pcvars_discrete, ...
  laglist, test_lag, swept_sampcounts, NaN, ...
  pearsonunits, ...
  'Time-Lagged Pearson''s Correlation (discrete events)', ...
  [ plotdir filesep 'lagged-pcorr-disc-%s.png' ] );


% Transfer entropy.

helper_plotLagged( ...
  transferbits_st, transfervars_st, ...
  laglist, test_lag, swept_sampcounts, swept_histbins, ...
  'Transfer Entropy (bits)', 'Transfer Entropy (strong channel)', ...
  [ plotdir filesep 'transfer-st-%s.png' ], 'squashzero' );

helper_plotLagged( ...
  transferbits_wk, transfervars_wk, ...
  laglist, test_lag, swept_sampcounts, swept_histbins, ...
  'Transfer Entropy (bits)', 'Transfer Entropy (weak channel)', ...
  [ plotdir filesep 'transfer-wk-%s.png' ], 'squashzero' );

helper_plotLagged( ...
  transferbits_discrete, transfervars_discrete, ...
  laglist, test_lag, swept_sampcounts, swept_histbins, ...
  'Transfer Entropy (bits)', 'Transfer Entropy (discrete events)', ...
  [ plotdir filesep 'transfer-disc-%s.png' ], 'squashzero' );

helper_plotLagged( ...
  transferbits_discrete_auto, transfervars_discrete_auto, ...
  laglist, test_lag, swept_sampcounts, NaN, ...
  'Transfer Entropy (bits)', 'Transfer Entropy (discrete events)', ...
  [ plotdir filesep 'transfer-autodisc-%s.png' ], 'squashzero' );


% Partial transfer entropy.

helper_plotLagged( ...
  ptebits_st, ptevars_st, ...
  laglist, test_lag, swept_sampcounts, swept_histbins, ...
  'Transfer Entropy (bits)', 'Partial Transfer Entropy (strong channel)', ...
  [ plotdir filesep 'pte-st-%s.png' ], 'squashzero' );

helper_plotLagged( ...
  ptebits_wk, ptevars_wk, ...
  laglist, test_lag, swept_sampcounts, swept_histbins, ...
  'Transfer Entropy (bits)', 'Partial Transfer Entropy (weak channel)', ...
  [ plotdir filesep 'pte-wk-%s.png' ], 'squashzero' );


disp('== Finished generating plots.');



%
% This is the end of the file.
