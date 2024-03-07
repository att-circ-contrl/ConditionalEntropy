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

    [ thisentropy scratch ] = ...
      cEn_calcExtrapShannon( thisdata, binedges, struct() );
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

      [ thisentropy scratch ] = ...
        cEn_calcExtrapShannon( thisdata, binedges, struct() );
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

    [ thisentropy scratch ] = ...
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


%
% This is the end of the file.
