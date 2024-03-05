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

  for didx = 1:datacount_alldim
    thisdata = datasets_alldim{didx,1};
    datalabel = datasets_alldim{didx,2};
    datatitle = datasets_alldim{didx,3};

    thismsg = '';

    binedges = cEn_getHistBinsEqPop( thisdata, histbins );
    [ bincounts scratch ] = histcounts( reshape(thisdata,1,[]), binedges );
    thisentropy = cEn_calcShannon( bincounts );
    thismsg = [ thismsg sprintf( '  %6.2f (my lib)', thisentropy ) ];

    if have_entropy
      minval = min( thisdata, [], 'all' );
      maxspan = max( thisdata, [], 'all' ) - minval;
      maxspan = max(1e-20,maxspan);

      thisentropy = entropy( (thisdata - minval) / maxspan );
      thismsg = [ thismsg sprintf( '  %6.2f (matlab)', thisentropy ) ];

      binedges = cEn_getHistBinsEqPop( thisdata, entropy_builtin_bins );
      [ bincounts scratch ] = histcounts( reshape(thisdata,1,[]), binedges );
      thisentropy = cEn_calcShannon( bincounts );
      thismsg = [ thismsg sprintf( '  %6.2f (my lib mat)', thisentropy ) ];
    end

    thismsg = [ thismsg '   ' datatitle ];

    disp(thismsg);
    reportmsg = [ reportmsg thismsg newline ];
  end

  thismsg = '== End of Shannon entropy report.';
  disp(thismsg);
  reportmsg = [ reportmsg thismsg newline ];

  helper_writeTextFile( [ outdir filesep 'report-entropy.txt' ], reportmsg );

end


%
% This is the end of the file.
