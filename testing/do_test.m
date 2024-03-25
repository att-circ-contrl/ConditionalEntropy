% Test code for the entropy library.
% Written by Christopher Thomas.


%
% Preamble.

addpath('../library');

do_config;



%
% Fixed-size tests.


datasets_entropy = helper_makeDatasetsShannon(sampcount);
datasets_mutual = helper_makeDatasetsMutual(sampcount);
[ datasets_te_2ch datasets_te_3ch ] = ...
  helper_makeDatasetsTransfer(sampcount, te_test_lag);


if want_test_entropy

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

    [ bincounts scratch ] = histcounts( reshape(thisdata,1,[]), binedges );
    thisentropy = cEn_calcShannonHist( bincounts );
    thismsg = [ thismsg sprintf( '  %6.2f (my lib)', thisentropy ) ];

    % Test that extrapolation can fall back to non-extrapolated.
    thisentropy = cEn_calcExtrapShannon( thisdata, binedges, ...
        cEn_getNoExtrapWrapperParams() );
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

      [ bincounts scratch ] = histcounts( reshape(thisdata,1,[]), binedges );
      thisentropy = cEn_calcShannonHist( bincounts );
      thismsg = [ thismsg sprintf( '  %6.2f (my lib)', thisentropy ) ];

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


if want_test_conditional

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

    thismsg = [ thismsg sprintf( '  %6.2f (raw)', thisentropy ) ];

    thisentropy = ...
      cEn_calcExtrapConditionalShannon( thisdata, histbins, struct() );

    thismsg = [ thismsg sprintf( '  %6.2f (extrap)', thisentropy ) ];

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


if want_test_mutual

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

    thismsg = [ thismsg sprintf( '  %6.2f (raw)', thismutual ) ];

    thismutual = cEn_calcExtrapMutualInfo( thisdata, histbins, struct() );

    thismsg = [ thismsg sprintf( '  %6.2f (extrap)', thismutual ) ];

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


if want_test_transfer

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
    thisdata = datasets_te_2ch{didx,1};
    datalabel = datasets_te_2ch{didx,2};
    datatitle = datasets_te_2ch{didx,3};

    thismsg = '';
    tic;

    dstseries = thisdata(1,:);
    srcseries = thisdata(2,:);

    telist_raw = cEn_calcExtrapTransferEntropy( ...
      srcseries, dstseries, te_laglist, histbins, ...
      cEn_getNoExtrapWrapperParams() );

    telist_ext = cEn_calcExtrapTransferEntropy( ...
      srcseries, dstseries, te_laglist, histbins, struct() );

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
    thisdata = datasets_te_3ch{didx,1};
    datalabel = datasets_te_3ch{didx,2};
    datatitle = datasets_te_3ch{didx,3};

    thismsg = '';
    tic;

    dstseries = thisdata(1,:);
    src1series = thisdata(2,:);
    src2series = thisdata(3,:);

    [ telist1_raw telist2_raw ] = cEn_calcExtrapPartialTE( ...
      src1series, src2series, dstseries, te_laglist, histbins, ...
      cEn_getNoExtrapWrapperParams() );

    [ telist1_ext telist2_ext ] = cEn_calcExtrapPartialTE( ...
      src1series, src2series, dstseries, te_laglist, histbins, struct() );

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

  helper_writeTextFile( [ outdir filesep 'report-conditional.txt' ], ...
    reportmsg );

end


%
% This is the end of the file.
