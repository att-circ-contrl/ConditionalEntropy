% Test code for the entropy library.
% Written by Christopher Thomas.


%
% Preamble.

addpath('../library');
addpath('../library/deprecated');

do_config;



%
% Startup.

% Start the parallel pool now, so that it doesn't eat into benchmark time.
if want_parallel
  parpool;
end



%
% Fixed-size tests.


datasets_entropy = helper_makeDatasetsShannon(sampcount);
datasets_mutual = helper_makeDatasetsMutual(sampcount, signal_type);
[ datasets_te_2ch datasets_te_3ch ] = ...
  helper_makeDatasetsTransfer(sampcount, te_test_lag, signal_type);

% Build Field Trip sets whether we test them or not.
ftsamps = round(sampcount / ft_trials);
datasets_mutual_ft = ...
  helper_makeDatasetsMutual_FT(ftsamps, ft_trials, signal_type);
[ datasets_te_2ch_ft datasets_te_3ch_ft ] = ...
  helper_makeDatasetsTransfer_FT(ftsamps, ft_trials, te_test_lag, signal_type);


if want_test_entropy && (~want_discrete_histbins) && want_nonswept

  reportmsg = '';
  thismsg = '== Shannon entropy report begins.';
  disp(thismsg);
  reportmsg = [ reportmsg thismsg newline ];


  datasets = datasets_entropy;
  datacount = size(datasets,1);


  % Test my functions with my bin counts.

  % NOTE - Equal-population bins should give entropy of log2(histbins).
  % This will occur for the linear and uniform random test cases.
  binedges = linspace(0, 1, histbins);

  for didx = 1:datacount;
    thisdata = datasets{didx,1};
    datalabel = datasets{didx,2};
    datatitle = datasets{didx,3};

    thismsg = '';

    if strcmp('hist', shannon_method)
      % Direct histogram test.
      [ bincounts scratch ] = histcounts( reshape(thisdata,1,[]), binedges );
      thisentropy = cEn_calcShannonHist( bincounts );
    elseif strcmp('edges', shannon_method)
      % Calculate specifying edges.
      [ thisentropy thisvar ] = ...
        cEn_calcShannon( thisdata, binedges, replicates );
    else  % Assume 'bins'.
      % Calculate specifying bin count.
      [ thisentropy thisvar ] = ...
        cEn_calcShannon( thisdata, histbins, replicates );
    end

    thismsg = [ thismsg sprintf( '  %6.2f (my lib)', thisentropy ) ];

    % NOTE - Extrapolated Shannon is deprecated.

    % Test that extrapolation can fall back to non-extrapolated.
    thisentropy = cEn_calcExtrapShannon( thisdata, binedges, ...
        cEn_extrapParamsNoExtrap() );
    thismsg = [ thismsg sprintf( '  %6.2f (ex1)', thisentropy ) ];

    thisentropy = cEn_calcExtrapShannon( thisdata, binedges, struct() );
    thismsg = [ thismsg sprintf( '  %6.2f (extrap)', thisentropy ) ];

    thismsg = [ thismsg '   ' datatitle ];

    disp(thismsg);
    reportmsg = [ reportmsg thismsg newline ];
  end


  % Test my functions against the built-in function, with a fixed bin count.

  binedges = linspace(0, 1, entropy_builtin_bins);

  if have_entropy
    thismsg = '-- Vs built-in "entropy" function:';
    disp(thismsg);
    reportmsg = [ reportmsg thismsg newline ];

    for didx = 1:datacount
      thisdata = datasets{didx,1};
      datalabel = datasets{didx,2};
      datatitle = datasets{didx,3};

      thismsg = '';

      % The built-in "entropy" function expects data in the range 0..1.
      % This uses 256 bins with linear spacing.
      thisentropy = entropy( thisdata );
      thismsg = [ thismsg sprintf( '  %6.2f (matlab)', thisentropy ) ];

      if strcmp('hist', shannon_method)
        % Direct histogram test.
        [ bincounts scratch ] = histcounts( reshape(thisdata,1,[]), binedges );
        thisentropy = cEn_calcShannonHist( bincounts );
      elseif strcmp('edges', shannon_method)
        % Calculate specifying edges.
        [ thisentropy thisvar ] = ...
          cEn_calcShannon( thisdata, binedges, replicates );
      else  % Assume 'bins'.
        % Calculate specifying bin count.
        [ thisentropy thisvar ] = ...
          cEn_calcShannon( thisdata, entropy_builtin_bins, replicates );
      end

      thismsg = [ thismsg sprintf( '  %6.2f (my lib)', thisentropy ) ];

      % NOTE - Extrapolated Shannon is deprecated.

      thisentropy = cEn_calcExtrapShannon( thisdata, binedges, struct() );
      thismsg = [ thismsg sprintf( '  %6.2f (extrap)', thisentropy ) ];

      thismsg = [ thismsg '   ' datatitle ];

      disp(thismsg);
      reportmsg = [ reportmsg thismsg newline ];
    end
  end

  thismsg = '== End of Shannon entropy report.';
  disp(thismsg);
  reportmsg = [ reportmsg thismsg newline ];

  helper_writeTextFile( [ outdir filesep 'report-entropy.txt' ], reportmsg );

end


if want_test_conditional && want_nonswept

  reportmsg = '';
  thismsg = '== Conditional entropy report begins.';
  disp(thismsg);
  reportmsg = [ reportmsg thismsg newline ];

  datasets = datasets_mutual;
  datacount = size(datasets,1);

  for didx = 1:datacount
    thisdata = datasets{didx,1};
    datalabel = datasets{didx,2};
    datatitle = datasets{didx,3};

    thismsg = '';

    [ thisbinned scratch ] = cEn_getBinnedMultivariate( thisdata, histbins );
    thisentropy = cEn_calcConditionalShannonHist( thisbinned );

    thismsg = [ thismsg sprintf( ' %6.2f (hs)', thisentropy ) ];

    [ thisentropy thisvar ] = ...
      cEn_calcConditionalShannon( thisdata, histbins, replicates );

    thismsg = [ thismsg sprintf( ' %6.2f (raw)', thisentropy ) ];

    [ thisentropy thisvar ] = ...
      cEn_calcConditionalShannon( thisdata, histbins, replicates, struct() );

    thismsg = [ thismsg sprintf( ' %6.2f (ext)', thisentropy ) ];

    if want_test_ft
      thisdata = datasets_mutual_ft{didx,1};

      [ thisentropy thisvar ] = cEn_calcConditionalShannonFT( ...
        thisdata, {}, histbins, replicates );
      thismsg = [ thismsg sprintf( ' %6.2f (rft)', thisentropy ) ];

      [ thisentropy thisvar ] = cEn_calcConditionalShannonFT( ...
        thisdata, {}, histbins, replicates, struct() );
      thismsg = [ thismsg sprintf( ' %6.2f (eft)', thisentropy ) ];
    end

    thismsg = [ thismsg '   ' datatitle ];

    disp(thismsg);
    reportmsg = [ reportmsg thismsg newline ];
  end

  thismsg = '== End of conditional entropy report.';
  disp(thismsg);
  reportmsg = [ reportmsg thismsg newline ];

  helper_writeTextFile( [ outdir filesep 'report-conditional.txt' ], ...
    reportmsg );

end


if want_test_mutual && want_nonswept

  reportmsg = '';
  thismsg = '== Mutual information report begins.';
  disp(thismsg);
  reportmsg = [ reportmsg thismsg newline ];

  datasets = datasets_mutual;
  datacount = size(datasets,1);

  % Use the conditional entropy test cases for mutual information.
  for didx = 1:datacount
    thisdata = datasets{didx,1};
    datalabel = datasets{didx,2};
    datatitle = datasets{didx,3};

    thismsg = '';

    [ thisbinned scratch ] = cEn_getBinnedMultivariate( thisdata, histbins );
    thismutual = cEn_calcMutualInfoHist( thisbinned );

    thismsg = [ thismsg sprintf( ' %6.2f (hs)', thismutual ) ];

    [ thismutual thisvar ] = ...
      cEn_calcMutualInfo( thisdata, histbins, replicates );

    thismsg = [ thismsg sprintf( ' %6.2f (raw)', thismutual ) ];

    [ thismutual thisvar ] = ...
      cEn_calcMutualInfo( thisdata, histbins, replicates, struct() );

    thismsg = [ thismsg sprintf( ' %6.2f (ext)', thismutual ) ];

    if want_test_ft
      thisdata = datasets_mutual_ft{didx,1};

      [ thismutual thisvar ]= cEn_calcMutualInfoFT( ...
        thisdata, {}, histbins, replicates );
      thismsg = [ thismsg sprintf( ' %6.2f (rft)', thismutual ) ];

      [ thismutual thisvar ] = cEn_calcMutualInfoFT( ...
        thisdata, {}, histbins, replicates, struct() );
      thismsg = [ thismsg sprintf( ' %6.2f (eft)', thismutual ) ];
    end

    thismsg = [ thismsg '   ' datatitle ];

    disp(thismsg);
    reportmsg = [ reportmsg thismsg newline ];
  end

  thismsg = '== End of mutual information report.';
  disp(thismsg);
  reportmsg = [ reportmsg thismsg newline ];

  helper_writeTextFile( [ outdir filesep 'report-mutual.txt' ], ...
    reportmsg );

end


if want_test_transfer && want_nonswept

  lagcount = length(te_laglist);

  reportmsg = '';

  thismsg = '== Transfer entropy report begins.';
  disp(thismsg);
  reportmsg = [ reportmsg thismsg newline ];


  % Two-channel cases: Standard TE.

  thismsg = '-- Transfer entropy between two channels.';
  disp(thismsg);
  reportmsg = [ reportmsg thismsg newline ];

  datacount = size(datasets_te_2ch,1);

  caselist = {};
  casecount = datacount;
  tetable_raw = nan([ lagcount, casecount ]);
  tetable_ext = nan(size(tetable_raw));

  for didx = 1:datacount
    datalabel = datasets_te_2ch{didx,2};
    datatitle = datasets_te_2ch{didx,3};

    thismsg = '';
    tic;

    dstidx = 1;
    srcidx = 2;

    if want_test_ft
      thisdata = datasets_te_2ch_ft{didx,1};

      if want_parallel
        [ telist_raw tevar_raw ] = cEn_calcTransferEntropyFT_MT( ...
          thisdata, [ dstidx srcidx ], te_laglist, histbins, replicates );

        [ telist_ext tevar_ext ] = cEn_calcTransferEntropyFT_MT( ...
          thisdata, [ dstidx srcidx ], te_laglist, histbins, replicates, ...
          struct() );
      else
        [ telist_raw tevar_raw ] = cEn_calcTransferEntropyFT( ...
          thisdata, [ dstidx srcidx ], te_laglist, histbins, replicates );

        [ telist_ext tevar_ext ] = cEn_calcTransferEntropyFT( ...
          thisdata, [ dstidx srcidx ], te_laglist, histbins, replicates, ...
          struct() );
      end
    else
      thisdata = datasets_te_2ch{didx,1};
      dstseries = thisdata(dstidx,:);
      srcseries = thisdata(srcidx,:);

      if want_parallel
        [ telist_raw tevar_raw ] = cEn_calcTransferEntropy_MT( ...
          { dstseries, srcseries }, te_laglist, histbins, replicates );

        [ telist_ext tevar_ext ] = cEn_calcTransferEntropy_MT( ...
          { dstseries, srcseries }, te_laglist, histbins, replicates, ...
          struct() );
      else
        [ telist_raw tevar_raw ] = cEn_calcTransferEntropy( ...
          { dstseries, srcseries }, te_laglist, histbins, replicates );

        [ telist_ext tevar_ext ] = cEn_calcTransferEntropy( ...
          { dstseries, srcseries }, te_laglist, histbins, replicates, ...
          struct() );
      end
    end

    durstring = helper_makePrettyTime(toc);
    disp([ '.. Computed "' datatitle '" TE in ' durstring '.' ]);

    caselist{didx} = datatitle;
    tetable_raw(:,didx) = telist_raw;
    tetable_ext(:,didx) = telist_ext;
  end

  thismsg = sprintf('%5s ', 'Lag');
  for cidx = 1:casecount
    thismsg = [ thismsg sprintf('%14s   ', caselist{cidx} ) ];
  end
  disp(thismsg);
  reportmsg = [ reportmsg thismsg newline ];

  for lidx = 1:lagcount
    thismsg = sprintf('%4d  ', te_laglist(lidx));
    for cidx = 1:casecount
      thismsg = [ thismsg sprintf('  %5.2f r %5.2f e', ...
        tetable_raw(lidx,cidx), tetable_ext(lidx,cidx) ) ];
    end
    disp(thismsg);
    reportmsg = [ reportmsg thismsg newline ];
  end


  % Three-channel cases: Partial TE.

  thismsg = '-- Partial transfer entropy (three channels).';
  disp(thismsg);
  reportmsg = [ reportmsg thismsg newline ];

  datacount = size(datasets_te_3ch,1);

  caselist = {};
  casecount = datacount;
  tetable1_raw = nan([ lagcount, casecount ]);
  tetable1_ext = nan(size(tetable_raw));
  tetable2_raw = nan([ lagcount, casecount ]);
  tetable2_ext = nan(size(tetable_raw));

  for didx = 1:datacount
    datalabel = datasets_te_3ch{didx,2};
    datatitle = datasets_te_3ch{didx,3};

    thismsg = '';
    tic;

    dstidx = 1;
    src1idx = 2;
    src2idx = 3;

    if want_test_ft
      thisdata = datasets_te_3ch_ft{didx,1};

      if want_parallel
        [ thistelist thistevar ] = cEn_calcTransferEntropyFT_MT( ...
          thisdata, [ dstidx src1idx src2idx ], ...
          te_laglist, histbins, replicates );
        telist1_raw = thistelist(1,:);
        telist2_raw = thistelist(2,:);

        [ thistelist thistevar ] = cEn_calcTransferEntropyFT_MT( ...
          thisdata, [ dstidx src1idx src2idx ], ...
          te_laglist, histbins, replicates, struct() );
        telist1_ext = thistelist(1,:);
        telist2_ext = thistelist(2,:);
      else
        [ thistelist thistevar ] = cEn_calcTransferEntropyFT( ...
          thisdata, [ dstidx src1idx src2idx ], ...
          te_laglist, histbins, replicates );
        telist1_raw = thistelist(1,:);
        telist2_raw = thistelist(2,:);

        [ thistelist thistevar ] = cEn_calcTransferEntropyFT( ...
          thisdata, [ dstidx src1idx src2idx ], ...
          te_laglist, histbins, replicates, struct() );
        telist1_ext = thistelist(1,:);
        telist2_ext = thistelist(2,:);
      end
    else
      thisdata = datasets_te_3ch{didx,1};

      dstseries = thisdata(dstidx,:);
      src1series = thisdata(src1idx,:);
      src2series = thisdata(src2idx,:);

      if want_parallel
        [ thistelist thistevar ] = cEn_calcTransferEntropy_MT( ...
          { dstseries, src1series, src2series }, ...
          te_laglist, histbins, replicates );
        telist1_raw = thistelist(1,:);
        telist2_raw = thistelist(2,:);

        [ thistelist thistevar ] = cEn_calcTransferEntropy_MT( ...
          { dstseries, src1series, src2series }, ...
          te_laglist, histbins, replicates, struct() );
        telist1_ext = thistelist(1,:);
        telist2_ext = thistelist(2,:);
      else
        [ thistelist thistevar ] = cEn_calcTransferEntropy( ...
          { dstseries, src1series, src2series }, ...
          te_laglist, histbins, replicates );
        telist1_raw = thistelist(1,:);
        telist2_raw = thistelist(2,:);

        [ thistelist thistevar ] = cEn_calcTransferEntropy( ...
          { dstseries, src1series, src2series }, ...
          te_laglist, histbins, replicates, struct() );
        telist1_ext = thistelist(1,:);
        telist2_ext = thistelist(2,:);
      end
    end

    durstring = helper_makePrettyTime(toc);
    disp([ '.. Computed "' datatitle '" partial TE in ' durstring '.' ]);

    caselist{didx} = datatitle;
    tetable1_raw(:,didx) = telist1_raw;
    tetable1_ext(:,didx) = telist1_ext;
    tetable2_raw(:,didx) = telist2_raw;
    tetable2_ext(:,didx) = telist2_ext;

    disp(thismsg);
    reportmsg = [ reportmsg thismsg newline ];
  end

  table1msg = [ '-- pTE from src1 to dst:' newline ];
  table2msg = [ '-- pTE from src2 to dst:' newline ];

  thismsg = sprintf('%5s ', 'Lag');
  for cidx = 1:casecount
    thismsg = [ thismsg sprintf('%14s   ', caselist{cidx} ) ];
  end
  table1msg = [ table1msg thismsg newline ];
  table2msg = [ table2msg thismsg newline ];

  for lidx = 1:lagcount
    thismsg1 = sprintf('%4d  ', te_laglist(lidx));
    thismsg2 = thismsg1;

    for cidx = 1:casecount
      thismsg1 = [ thismsg1 sprintf('  %5.2f r %5.2f e', ...
        tetable1_raw(lidx,cidx), tetable1_ext(lidx,cidx) ) ];
      thismsg2 = [ thismsg2 sprintf('  %5.2f r %5.2f e', ...
        tetable2_raw(lidx,cidx), tetable2_ext(lidx,cidx) ) ];
    end

    table1msg = [ table1msg thismsg1 newline ];
    table2msg = [ table2msg thismsg2 newline ];
  end

  disp(table1msg);
  disp(table2msg);
  % The table messages already have newlines.
  reportmsg = [ reportmsg table1msg table2msg ];

  thismsg = '== End of transfer entropy report.';
  disp(thismsg);
  reportmsg = [ reportmsg thismsg newline ];

  helper_writeTextFile( [ outdir filesep 'report-transfer.txt' ], ...
    reportmsg );

end



%
% Plot the test signals, if desired.

if want_plot_signals

  % NOTE - Getting channel names from the FT versions of the datasets.

  if want_test_mutual || want_test_conditional
    for didx = 1:size(datasets_mutual,2)
      helper_plotDataSignals( datasets_mutual{didx,1}, ...
        datasets_mutual_ft{didx,1}.label, signal_plot_samps, ...
        [ 'CE/MI Signals - ' datasets_mutual{didx,3} ], ...
        [ plotdir filesep 'signals-mi-' datasets_mutual{didx,2} ] );
    end
  end

  if want_test_transfer
    for didx = 1:size(datasets_te_2ch,2)
      helper_plotDataSignals( datasets_te_2ch{didx,1}, ...
        datasets_te_2ch_ft{didx,1}.label, signal_plot_samps, ...
        [ 'TE Signals - ' datasets_te_2ch{didx,3} ], ...
        [ plotdir filesep 'signals-te-' datasets_te_2ch{didx,2} ] );
    end

    for didx = 1:size(datasets_te_3ch,2)
      helper_plotDataSignals( datasets_te_3ch{didx,1}, ...
        datasets_te_3ch_ft{didx,1}.label, signal_plot_samps, ...
        [ 'TE Signals - ' datasets_te_3ch{didx,3} ], ...
        [ plotdir filesep 'signals-te-' datasets_te_3ch{didx,2} ] );
    end
  end

end



%
% Swept tests.


if want_sweep_sampcount

  if ~want_sweep_histbins
    swept_histbins = [ histbins ];
  end

  if want_discrete_histbins
    want_sweep_histbins = false;
    swept_histbins = [ nan ];
  end


  % Get geometry.
  sampsweepsize = length(swept_sampcounts);
  binsweepsize = length(swept_histbins);
  lagcount = length(te_laglist);


  % Get lookup tables of case labels, from the non-swept data.

  datalabels_entropy = datasets_entropy(:,2);
  datatitles_entropy = datasets_entropy(:,3);
  datasize_entropy = length(datalabels_entropy);

  datalabels_mutual = datasets_mutual(:,2);
  datatitles_mutual = datasets_mutual(:,3);
  datasize_mutual = length(datalabels_mutual);

  datalabels_te_2ch = datasets_te_2ch(:,2);
  datatitles_te_2ch = datasets_te_2ch(:,3);
  datasize_te_2ch = length(datalabels_te_2ch);

  datalabels_te_3ch = datasets_te_3ch(:,2);
  datatitles_te_3ch = datasets_te_3ch(:,3);
  datasize_te_3ch = length(datalabels_te_3ch);


  %
  % Precompute the data before plotting. This makes life much easier, since
  % we'd otherwise have to nest loops strangely.

  entropyraw = nan([ sampsweepsize, binsweepsize, datasize_entropy ]);
  entropyext = entropyraw;

  conditionalraw = nan([ sampsweepsize, binsweepsize, datasize_mutual ]);
  conditionalext = conditionalraw;

  mutualraw = nan([ sampsweepsize, binsweepsize, datasize_mutual ]);
  mutualext = mutualraw;

  % Using the 2-channel transfer entropy test cases for lagged MI.
  lagmutualraw = ...
    nan([ lagcount, sampsweepsize, binsweepsize, datasize_te_2ch ]);
  lagmutualext = lagmutualraw;

  te2chraw = nan([ lagcount, sampsweepsize, binsweepsize, datasize_te_2ch ]);
  te2chext = te2chraw;

  te3ch1raw = nan([ lagcount, sampsweepsize, binsweepsize, datasize_te_3ch ]);
  te3ch1ext = te3ch1raw;
  te3ch2raw = te3ch1raw;
  te3ch2ext = te3ch2raw;

  disp('== Beginning sample count sweep.');

  for sidx = 1:sampsweepsize

    thissampcount = swept_sampcounts(sidx);
    prettysamps = helper_makePrettyCount( thissampcount );

    thisftsamps = round(thissampcount / ft_trials);


    % Entropy.

    if want_test_entropy && (~want_discrete_histbins)
      thisdatasetlist = helper_makeDatasetsShannon( thissampcount );

      tic;

      for didx = 1:length(thisdatasetlist)
        thisdata = thisdatasetlist{didx,1};
        for bidx = 1:binsweepsize
          binedges = linspace(0, 1, swept_histbins(bidx));

          if strcmp('hist', shannon_method)
            % Direct histogram test.
            [ bincounts scratch ] = ...
              histcounts( reshape(thisdata, 1, []), binedges );
            entropyraw( sidx, bidx, didx ) = cEn_calcShannonHist( bincounts );
          elseif strcmp('edges', shannon_method)
            % Calculate specifying edges.
            [ thisentropy thisvar ] = ...
              cEn_calcShannon( thisdata, binedges, replicates );
            entropyraw( sidx, bidx, didx ) = thisentropy;
          else  % Assume 'bins'.
            % Calculate specifying bin count.
            [ thisentropy thisvar ] = ...
              cEn_calcShannon( thisdata, swept_histbins(bidx), replicates );
            entropyraw( sidx, bidx, didx ) = thisentropy;
          end

          % NOTE - Extrapolated Shannon is deprecated.

          entropyext( sidx, bidx, didx ) = ...
            cEn_calcExtrapShannon( thisdata, binedges, struct() );
        end
      end

      durstring = helper_makePrettyTime(toc);
      disp([ ' -- Shannon entropy for ' prettysamps ' samples took ' ...
        durstring '.' ]);
    end


    % Conditional entropy.

    if want_test_conditional
      thisdatasetlist = ...
        helper_makeDatasetsMutual( thissampcount, signal_type );
      thisdatasetlist_ft = ...
        helper_makeDatasetsMutual_FT( thisftsamps, ft_trials, signal_type );

      tic;

      for didx = 1:length(thisdatasetlist)
        if want_test_ft
          thisdata = thisdatasetlist_ft{didx,1};

          for bidx = 1:binsweepsize
            if want_discrete_histbins
              thisbins = cEn_getMultivariateHistBinsDiscreteFT( ...
                thisdata, thisdata.label );
            else
              thisbins = swept_histbins(bidx);
            end

            [ thisentropy thisvar ] = cEn_calcConditionalShannonFT( ...
              thisdata, {}, thisbins, replicates );
            conditionalraw( sidx, bidx, didx ) = thisentropy;

            [ thisentropy thisvar ] = cEn_calcConditionalShannonFT( ...
              thisdata, {}, thisbins, replicates, struct() );
            conditionalext( sidx, bidx, didx ) = thisentropy;
          end
        else
          thisdata = thisdatasetlist{didx,1};

          for bidx = 1:binsweepsize
            if want_discrete_histbins
              thisbins = cEn_getMultivariateHistBinsDiscrete( thisdata );
            else
              thisbins = swept_histbins(bidx);
            end

            [ thisentropy thisvar ] = cEn_calcConditionalShannon( ...
              thisdata, thisbins, replicates );
            conditionalraw( sidx, bidx, didx ) = thisentropy;

            [ thisentropy thisvar ] = cEn_calcConditionalShannon( ...
              thisdata, thisbins, replicates, struct() );
            conditionalext( sidx, bidx, didx ) = thisentropy;
          end
        end
      end

      durstring = helper_makePrettyTime(toc);
      disp([ ' -- Conditional entropy for ' prettysamps ' samples took ' ...
        durstring '.' ]);
    end


    % Mutual information.

    if want_test_mutual
      thisdatasetlist = ...
        helper_makeDatasetsMutual( thissampcount, signal_type );
      thisdatasetlist_ft = ...
        helper_makeDatasetsMutual_FT( thisftsamps, ft_trials, signal_type );

      tic;

      for didx = 1:length(thisdatasetlist)
        if want_test_ft
          thisdata = thisdatasetlist_ft{didx,1};

          for bidx = 1:binsweepsize
            if want_discrete_histbins
              thisbins = cEn_getMultivariateHistBinsDiscreteFT( ...
                thisdata, thisdata.label );
            else
              thisbins = swept_histbins(bidx);
            end

            [ thismutual thisvar ] = cEn_calcMutualInfoFT( ...
              thisdata, {}, thisbins, replicates );
            mutualraw( sidx, bidx, didx ) = thismutual;

            [ thismutual thisvar ] = cEn_calcMutualInfoFT( ...
              thisdata, {}, thisbins, replicates, struct() );
            mutualext( sidx, bidx, didx ) = thismutual;
          end
        else
          thisdata = thisdatasetlist{didx,1};

          for bidx = 1:binsweepsize
            if want_discrete_histbins
              thisbins = cEn_getMultivariateHistBinsDiscrete( thisdata );
            else
              thisbins = swept_histbins(bidx);
            end

            [ thismutual thisvar ] = cEn_calcMutualInfo( ...
              thisdata, thisbins, replicates );
            mutualraw( sidx, bidx, didx ) = thismutual;

            [ thismutual thisvar ] = cEn_calcMutualInfo( ...
              thisdata, thisbins, replicates, struct() );
            mutualext( sidx, bidx, didx ) = thismutual;
          end
        end
      end

      durstring = helper_makePrettyTime(toc);
      disp([ ' -- Mutual information for ' prettysamps ' samples took ' ...
        durstring '.' ]);
    end


    % Time-lagged mutual information.

    if want_test_mutual_lagged
      % Using the 2-channel transfer entropy test cases for lagged MI.
      [ thisdatasetlist_2ch thisdatasetlist_3ch ] = ...
        helper_makeDatasetsTransfer( ...
          thissampcount, te_test_lag, signal_type );
      [ thisdatasetlist_2ch_ft thisdatasetlist_3ch_ft ] = ...
        helper_makeDatasetsTransfer_FT( ...
          thisftsamps, ft_trials, te_test_lag, signal_type );
      thisdatasetlist = thisdatasetlist_2ch;
      thisdatasetlist_ft = thisdatasetlist_2ch_ft;

      tic;

      dstidx = 1;
      srcidx = 2;

      for didx = 1:length(thisdatasetlist)
        if want_test_ft
          thisdata = thisdatasetlist_ft{didx,1};

          for bidx = 1:binsweepsize
            if want_discrete_histbins
              thisbins = cEn_getMultivariateHistBinsDiscreteFT( ...
                thisdata, [ dstidx srcidx ] );
            else
              thisbins = swept_histbins(bidx);
            end

            if want_parallel
              [ milist_raw mivar ] = cEn_calcLaggedMutualInfoFT_MT( ...
                thisdata, [ dstidx srcidx ], ...
                te_laglist, thisbins, replicates );
              [ milist_ext mivar ] = cEn_calcLaggedMutualInfoFT_MT( ...
                thisdata, [ dstidx srcidx ], ...
                te_laglist, thisbins, replicates, struct() );
            else
              [ milist_raw mivar ] = cEn_calcLaggedMutualInfoFT( ...
                thisdata, [ dstidx srcidx ], ...
                te_laglist, thisbins, replicates );
              [ milist_ext mivar ] = cEn_calcLaggedMutualInfoFT( ...
                thisdata, [ dstidx srcidx ], ...
                te_laglist, thisbins, replicates, struct() );
            end

            lagmutualraw( :, sidx, bidx, didx ) = milist_raw;
            lagmutualext( :, sidx, bidx, didx ) = milist_ext;
          end
        else
          thisdata = thisdatasetlist{didx,1};
          dstseries = thisdata(dstidx,:);
          srcseries = thisdata(srcidx,:);

          for bidx = 1:binsweepsize
            if want_discrete_histbins
              thisbins = cEn_getMultivariateHistBinsDiscrete( ...
                [ dstseries ; srcseries ] );
            else
              thisbins = swept_histbins(bidx);
            end

            if want_parallel
              [ milist_raw mivar ] = cEn_calcLaggedMutualInfo_MT( ...
                { dstseries, srcseries }, ...
                te_laglist, thisbins, replicates );
              [ milist_ext mivar ] = cEn_calcLaggedMutualInfo_MT( ...
                { dstseries, srcseries }, ...
                te_laglist, thisbins, replicates, struct() );
            else
              [ milist_raw mivar ] = cEn_calcLaggedMutualInfo( ...
                { dstseries, srcseries }, ...
                te_laglist, thisbins, replicates );
              [ milist_ext mivar ] = cEn_calcLaggedMutualInfo( ...
                { dstseries, srcseries }, ...
                te_laglist, thisbins, replicates, struct() );
            end

            lagmutualraw( :, sidx, bidx, didx ) = milist_raw;
            lagmutualext( :, sidx, bidx, didx ) = milist_ext;
          end
        end
      end

      durstring = helper_makePrettyTime(toc);
      disp([ ' -- Time-lagged mutual information for ' prettysamps ...
        ' samples took ' durstring '.' ]);
    end


    % Transfer entropy.

    if want_test_transfer
      [ thisdatasetlist_2ch thisdatasetlist_3ch ] = ...
        helper_makeDatasetsTransfer( thissampcount, te_test_lag, signal_type );
      [ thisdatasetlist_2ch_ft thisdatasetlist_3ch_ft ] = ...
        helper_makeDatasetsTransfer_FT( ...
          thisftsamps, ft_trials, te_test_lag, signal_type );

      % 2-channel transfer entropy.

      dstidx = 1;
      srcidx = 2;

      for didx = 1:length(thisdatasetlist_2ch)
        datatitle = thisdatasetlist_2ch{didx,3};
        tic;

        if want_test_ft
          thisdata = thisdatasetlist_2ch_ft{didx,1};

          for bidx = 1:binsweepsize
            if want_discrete_histbins
              thisbins = cEn_getMultivariateHistBinsDiscreteFT( ...
                thisdata, [ dstidx srcidx ] );
            else
              thisbins = swept_histbins(bidx);
            end

            if want_parallel
              [ telist_raw tevar ] = cEn_calcTransferEntropyFT_MT( ...
                thisdata, [ dstidx srcidx ], ...
                te_laglist, thisbins, replicates );

              [ telist_ext tevar ] = cEn_calcTransferEntropyFT_MT( ...
                thisdata, [ dstidx srcidx ], ...
                te_laglist, thisbins, replicates, struct() );
            else
              [ telist_raw tevar ] = cEn_calcTransferEntropyFT( ...
                thisdata, [ dstidx srcidx ], ...
                te_laglist, thisbins, replicates );

              [ telist_ext tevar ] = cEn_calcTransferEntropyFT( ...
                thisdata, [ dstidx srcidx ], ...
                te_laglist, thisbins, replicates, struct() );
            end

            te2chraw(:,sidx,bidx,didx) = telist_raw;
            te2chext(:,sidx,bidx,didx) = telist_ext;
          end
        else
          thisdata = thisdatasetlist_2ch{didx,1};
          dstseries = thisdata(dstidx,:);
          srcseries = thisdata(srcidx,:);

          for bidx = 1:binsweepsize
            if want_discrete_histbins
              thisbins = cEn_getMultivariateHistBinsDiscrete( ...
                [ dstseries ; srcseries ] );
            else
              thisbins = swept_histbins(bidx);
            end

            if want_parallel
              [ telist_raw tevar ] = cEn_calcTransferEntropy_MT( ...
                { dstseries, srcseries }, ...
                te_laglist, thisbins, replicates );

              [ telist_ext tevar ] = cEn_calcTransferEntropy_MT( ...
                { dstseries, srcseries }, ...
                te_laglist, thisbins, replicates, struct() );
            else
              [ telist_raw tevar ] = cEn_calcTransferEntropy( ...
                { dstseries, srcseries }, ...
                te_laglist, thisbins, replicates );

              [ telist_ext tevar ] = cEn_calcTransferEntropy( ...
                { dstseries, srcseries }, ...
                te_laglist, thisbins, replicates, struct() );
            end

            te2chraw(:,sidx,bidx,didx) = telist_raw;
            te2chext(:,sidx,bidx,didx) = telist_ext;
          end
        end

        durstring = helper_makePrettyTime(toc);
        disp([ ' -- Transfer entropy for "' datatitle '" with ' ...
          prettysamps ' samples took ' durstring '.' ]);
      end

      % 3-channel partial transfer entropy.

      dstidx = 1;
      src1idx = 2;
      src2idx = 3;

      for didx = 1:length(thisdatasetlist_3ch)
        datatitle = thisdatasetlist_3ch{didx,3};
        tic;

        if want_test_ft
          thisdata = thisdatasetlist_3ch_ft{didx,1};

          for bidx = 1:binsweepsize
            if want_discrete_histbins
              thisbins = cEn_getMultivariateHistBinsDiscreteFT( ...
                thisdata, [ dstidx src1idx src2idx ] );
            else
              thisbins = swept_histbins(bidx);
            end

            if want_parallel
              [ thistelist thisvar ] = cEn_calcTransferEntropyFT_MT( ...
                thisdata, [ dstidx src1idx src2idx ], ...
                te_laglist, thisbins, replicates );
              telist1_raw = thistelist(1,:);
              telist2_raw = thistelist(2,:);

              [ thistelist thisvar ] = cEn_calcTransferEntropyFT_MT( ...
                thisdata, [ dstidx src1idx src2idx ], ...
                te_laglist, thisbins, replicates, struct() );
              telist1_ext = thistelist(1,:);
              telist2_ext = thistelist(2,:);
            else
              [ thistelist thisvar ] = cEn_calcTransferEntropyFT( ...
                thisdata, [ dstidx src1idx src2idx ], ...
                te_laglist, thisbins, replicates );
              telist1_raw = thistelist(1,:);
              telist2_raw = thistelist(2,:);

              [ thistelist thisvar ] = cEn_calcTransferEntropyFT( ...
                thisdata, [ dstidx src1idx src2idx ], ...
                te_laglist, thisbins, replicates, struct() );
              telist1_ext = thistelist(1,:);
              telist2_ext = thistelist(2,:);
            end

            te3ch1raw(:,sidx,bidx,didx) = telist1_raw;
            te3ch1ext(:,sidx,bidx,didx) = telist1_ext;

            te3ch2raw(:,sidx,bidx,didx) = telist2_raw;
            te3ch2ext(:,sidx,bidx,didx) = telist2_ext;
          end
        else
          thisdata = thisdatasetlist_3ch{didx,1};
          dstseries = thisdata(dstidx,:);
          src1series = thisdata(src1idx,:);
          src2series = thisdata(src2idx,:);

          for bidx = 1:binsweepsize
            if want_discrete_histbins
              thisbins = cEn_getMultivariateHistBinsDiscrete( ...
                [ dstseries ; src1series ; src2series ] );
            else
              thisbins = swept_histbins(bidx);
            end

            if want_parallel
              [ thistelist thisvar ] = cEn_calcTransferEntropy_MT( ...
                { dstseries, src1series, src2series }, ...
                te_laglist, thisbins, replicates );
              telist1_raw = thistelist(1,:);
              telist2_raw = thistelist(2,:);

              [ thistelist thisvar ] = cEn_calcTransferEntropy_MT( ...
                { dstseries, src1series, src2series }, ...
                te_laglist, thisbins, replicates, struct() );
              telist1_ext = thistelist(1,:);
              telist2_ext = thistelist(2,:);
            else
              [ thistelist thisvar ] = cEn_calcTransferEntropy( ...
                { dstseries, src1series, src2series }, ...
                te_laglist, thisbins, replicates );
              telist1_raw = thistelist(1,:);
              telist2_raw = thistelist(2,:);

              [ thistelist thisvar ] = cEn_calcTransferEntropy( ...
                { dstseries, src1series, src2series }, ...
                te_laglist, thisbins, replicates, struct() );
              telist1_ext = thistelist(1,:);
              telist2_ext = thistelist(2,:);
            end

            te3ch1raw(:,sidx,bidx,didx) = telist1_raw;
            te3ch1ext(:,sidx,bidx,didx) = telist1_ext;

            te3ch2raw(:,sidx,bidx,didx) = telist2_raw;
            te3ch2ext(:,sidx,bidx,didx) = telist2_ext;
          end
        end

        durstring = helper_makePrettyTime(toc);
        disp([ ' -- Partial transfer entropy for "' datatitle '" with ' ...
          prettysamps ' samples took ' durstring '.' ]);
      end
    end


    % Finished with this sample count.

  end

  disp('== Finished sample count sweep.');


  %
  % Plot the data.

  % Everything except TE: Single plot per case, one curve per bin count.
  % TE: One plot per bin count per case.

  disp('== Generating sweep plots.');

  if want_test_entropy && (~want_discrete_histbins)
    helper_plotSweptData( entropyraw, swept_sampcounts, swept_histbins, ...
      datalabels_entropy, datatitles_entropy, 'Shannon Entropy (bits)', ...
      'Entropy (raw)', [ plotdir filesep 'entropy-raw' ] );

    helper_plotSweptData( entropyext, swept_sampcounts, swept_histbins, ...
      datalabels_entropy, datatitles_entropy, 'Shannon Entropy (bits)', ...
      'Entropy (extrap)', [ plotdir filesep 'entropy-ext' ] );
  end

  if want_test_conditional
    helper_plotSweptData( conditionalraw, swept_sampcounts, swept_histbins, ...
      datalabels_mutual, datatitles_mutual, 'Conditional Entropy (bits)', ...
      'Conditional Entropy (raw)', [ plotdir filesep 'conditional-raw' ] );

    helper_plotSweptData( conditionalext, swept_sampcounts, swept_histbins, ...
      datalabels_mutual, datatitles_mutual, 'Conditional Entropy (bits)', ...
      'Conditional Entropy (extrap)', [ plotdir filesep 'conditional-ext' ] );
  end

  if want_test_mutual
    helper_plotSweptData( mutualraw, swept_sampcounts, swept_histbins, ...
      datalabels_mutual, datatitles_mutual, 'Mutual Information (bits)', ...
      'Mutual Information (raw)', [ plotdir filesep 'mutual-raw' ] );

    helper_plotSweptData( mutualext, swept_sampcounts, swept_histbins, ...
      datalabels_mutual, datatitles_mutual, 'Mutual Information (bits)', ...
      'Mutual Information (extrap)', [ plotdir filesep 'mutual-ext' ] );
  end

  if want_test_mutual_lagged

    % Using the 2-channel transfer entropy test cases for lagged MI.

    helper_plotTESweptData( lagmutualraw, ...
      te_laglist, te_test_lag, swept_sampcounts, swept_histbins, ...
      datalabels_te_2ch, datatitles_te_2ch, 'Mutual Information (bits)', ...
      'Lagged Mutual Information (raw)', ...
      [ plotdir filesep 'lagmutual-raw' ] );

    helper_plotTESweptData( lagmutualext, ...
      te_laglist, te_test_lag, swept_sampcounts, swept_histbins, ...
      datalabels_te_2ch, datatitles_te_2ch, 'Mutual Information (bits)', ...
      'Lagged Mutual Information (extrap)', ...
      [ plotdir filesep 'lagmutual-ext' ] );

  end

  if want_test_transfer
    helper_plotTESweptData( te2chraw, ...
      te_laglist, te_test_lag, swept_sampcounts, swept_histbins, ...
      datalabels_te_2ch, datatitles_te_2ch, 'Transfer Entropy (bits)', ...
      '2ch Transfer Entropy (raw)', [ plotdir filesep 'te2ch-raw' ] );

    helper_plotTESweptData( te2chext, ...
      te_laglist, te_test_lag, swept_sampcounts, swept_histbins, ...
      datalabels_te_2ch, datatitles_te_2ch, 'Transfer Entropy (bits)', ...
      '2ch Transfer Entropy (extrap)', [ plotdir filesep 'te2ch-ext' ] );

    helper_plotTESweptData( te3ch1raw, ...
      te_laglist, te_test_lag, swept_sampcounts, swept_histbins, ...
      datalabels_te_3ch, datatitles_te_3ch, ...
      'Partial Transfer Entropy (bits)', ...
      '3ch Partial TE (src1, raw)', [ plotdir filesep 'te3ch1-raw' ] );

    helper_plotTESweptData( te3ch1ext, ...
      te_laglist, te_test_lag, swept_sampcounts, swept_histbins, ...
      datalabels_te_3ch, datatitles_te_3ch, ...
      'Partial Transfer Entropy (bits)', ...
      '3ch Partial TE (src1, extrap)', [ plotdir filesep 'te3ch1-ext' ] );

    helper_plotTESweptData( te3ch2raw, ...
      te_laglist, te_test_lag, swept_sampcounts, swept_histbins, ...
      datalabels_te_3ch, datatitles_te_3ch, ...
      'Partial Transfer Entropy (bits)', ...
      '3ch Partial TE (src2, raw)', [ plotdir filesep 'te3ch2-raw' ] );

    helper_plotTESweptData( te3ch2ext, ...
      te_laglist, te_test_lag, swept_sampcounts, swept_histbins, ...
      datalabels_te_3ch, datatitles_te_3ch, ...
      'Partial Transfer Entropy (bits)', ...
      '3ch Partial TE (src2, extrap)', [ plotdir filesep 'te3ch2-ext' ] );
  end

  disp('== Finished generating sweep plots.');

end



%
% This is the end of the file.
