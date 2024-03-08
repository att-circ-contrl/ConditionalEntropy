% Test code for the entropy library.
% Written by Christopher Thomas.


%
% Preamble.

addpath('../library');

do_config;



%
% Tests.


if want_test_entropy

  reportmsg = '';
  thismsg = '== Shannon entropy report begins.';
  disp(thismsg);
  reportmsg = [ reportmsg thismsg newline ];


  % Test my functions with my bin counts.

  % NOTE - Equal-population bins should give entropy of log2(histbins).
  % This will occur for the linear and uniform random test cases.
  binedges = linspace(0, 1, histbins);

  for didx = 1:datacount_alldim
    thisdata = datasets_alldim{didx,1};
    datalabel = datasets_alldim{didx,2};
    datatitle = datasets_alldim{didx,3};

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

    for didx = 1:datacount_alldim
      thisdata = datasets_alldim{didx,1};
      datalabel = datasets_alldim{didx,2};
      datatitle = datasets_alldim{didx,3};

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

  for didx = 1:datacount_conditional
    thisdata = datasets_cond{didx,1};
    datalabel = datasets_cond{didx,2};
    datatitle = datasets_cond{didx,3};

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

  thismsg = '== End of Conditional entropy report.';
  disp(thismsg);
  reportmsg = [ reportmsg thismsg newline ];

  helper_writeTextFile( [ outdir filesep 'report-conditional.txt' ], ...
    reportmsg );

end


if want_test_transfer

  laglist = [ (-te_max_shift) : te_max_shift ];
  lagcount = length(laglist);

  reportmsg = '';

  thismsg = '== Transfer entropy report begins.';
  disp(thismsg);
  reportmsg = [ reportmsg thismsg newline ];

  thismsg = '-- Transfer entropy between two channels.';
  disp(thismsg);
  reportmsg = [ reportmsg thismsg newline ];

  caselist = {};
  casecount = datacount_te_2ch;
  tetable_raw = nan([ lagcount, casecount ]);
  tetable_ext = nan(size(tetable_raw));

  for didx = 1:datacount_te_2ch
    thisdata = datasets_te_2ch{didx,1};
    datalabel = datasets_te_2ch{didx,2};
    datatitle = datasets_te_2ch{didx,3};

    thismsg = '';
    tic;

    dstseries = thisdata(1,:);
    srcseries = thisdata(2,:);

    telist_raw = cEn_calcExtrapTransferEntropy( ...
      srcseries, dstseries, laglist, histbins, ...
      cEn_getNoExtrapWrapperParams() );

    telist_ext = cEn_calcExtrapTransferEntropy( ...
      srcseries, dstseries, laglist, histbins, struct() );

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
    thismsg = sprintf('%4d  ', laglist(lidx));
    for cidx = 1:casecount
      thismsg = [ thismsg sprintf('  %5.2f r %5.2f e', ...
        tetable_raw(lidx,cidx), tetable_ext(lidx,cidx) ) ];
    end
    disp(thismsg);
    reportmsg = [ reportmsg thismsg newline ];
  end

  thismsg = '-- Partial transfer entropy (three channels).';
  disp(thismsg);
  reportmsg = [ reportmsg thismsg newline ];

  for didx = 1:datacount_te_3ch
    thisdata = datasets_te_3ch{didx,1};
    datalabel = datasets_te_3ch{didx,2};
    datatitle = datasets_te_3ch{didx,3};

    thismsg = '';

    thismsg = [ thismsg '   ' datatitle ];

    disp(thismsg);
    reportmsg = [ reportmsg thismsg newline ];
  end

  thismsg = '== End of Conditional entropy report.';
  disp(thismsg);
  reportmsg = [ reportmsg thismsg newline ];

  helper_writeTextFile( [ outdir filesep 'report-conditional.txt' ], ...
    reportmsg );

end


%
% This is the end of the file.
