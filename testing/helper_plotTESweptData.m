function helper_plotTESweptData( ...
  datavals, laglist, testlag, sampcountlist, histbinlist, ...
  datalabels, datatitles, axistitle, titleprefix, fileprefix )

% function helper_plotSweptData( ...
%   datavals, laglist, testlag, sampcountlist, histbinlist, ...
%   datalabels, datatitles, axistitle, titleprefix, fileprefix )
%
% This generates three types of transfer entropy plot.
%
% The first type generates one plot per data case and bin count, with one
% curve per sample count, plotting entropy as a function of time lag.
%
% The second type generates one plot per data case, with one curve per bin
% count, plotting entropy as a function of sample count at the "test" time
% lag.
%
% The third type generates one plot per bin count and sample count, with
% one curve per data case, plotting entropy as a function of time lag.
%
% "datavals" is a matrix of size Nlags x Nsampcounts x Nhistbins x Ndatacases,
%   containing transfer entropy data.
% "laglist" is a vector containing time lags (in samples).
% "testlag" is a scalar with a time lag to use for single-lag plots.
% "sampcountlist" is a vector containing sample counts.
% "histbinlist" is a vector containing histogram bin counts. If this is NaN,
%   discrete-event auto-binning is assumed.
% "datalabels" is a cell array containing filename- and plot-safe data case
%   labels.
% "datatitles" is a cell array containing plot-safe descriptive data case
%   labels.
% "axistitle" is a character vector with the Y axis title.
% "titleprefix" is a character vector with a prefix to use when building
%   plot titles.
% "fileprefix" is a character vector with a prefix to use when building
%   filenames.
%
% No return value.


% Get geometry metadata.

datacount = length(datalabels);
bincount = length(histbinlist);
sizecount = length(sampcountlist);


% Tolerate the test lag not being in the list.

distlist = laglist - testlag;
distlist = distlist .* distlist;

bestdist = min(distlist);

% Epsilon of 0.1 is fine, since sample counts and distances are integers.
testlagidx = find( distlist < (bestdist + 0.1) );

% Tolerate multiple outputs. Might happen if testlag is between two list lags.
testlagidx = min(testlagidx);

% Tolerate empty output. Shouldn't happen unless laglist is empty.
if isempty(testlagidx)
  testlagidx = 1;
end



% Set up for plotting.

thisfig = figure();
figure(thisfig);



% Entropy as a function of time lag.
% One plot per data case and bin count.
% One curve per sample count.

for didx = 1:datacount
  for bidx = 1:bincount

    % FIXME - Kludge the upper bound.
    % We have three situations: Either it's near log2(bins), or it's 1-2 bits,
    % or it's absurdly high due to an extrapolation error. Force the first two.

    ymaxval = helper_getYMax( histbinlist(bidx), datavals(:,:,bidx,didx) );


    clf('reset');

    hold on;

    for sidx = 1:sizecount
      thisdata = datavals(:,sidx,bidx,didx);
      thisdata = reshape(thisdata, size(laglist));

      % NOTE - Squash "lag = 0". It's always zero.
      squashmask = ( abs(laglist) < 0.5 );
      thisdata(squashmask) = NaN;

      plot( laglist, thisdata, 'DisplayName', ...
        [ helper_makePrettyCount(sampcountlist(sidx)) ' samples' ] );
    end

    plot( laglist, zeros(size(laglist)), 'HandleVisibility', 'off', ...
      'Color', [ 0.5 0.5 0.5 ] );

    hold off;

    xlabel('Time Lag (samples)');
    ylabel(axistitle);

    ylim([ -0.25 ymaxval ]);

    legend('Location', 'northwest');

    if isnan(histbinlist(bidx))
      title([ titleprefix ' - ' datatitles{didx} ' - auto bins' ]);

      saveas( thisfig, [ fileprefix '-laglength-' datalabels{didx} ...
        '-autobins.png' ] );
    else
      title([ titleprefix ' - ' datatitles{didx} ...
        sprintf(' - %d bins', histbinlist(bidx)) ]);

      saveas( thisfig, [ fileprefix '-laglength-' datalabels{didx} ...
        sprintf('-%02dbins.png', histbinlist(bidx)) ] );
    end

  end
end



% Entropy as a function of time lag.
% One plot per bin count and sample count.
% One curve per data case.

for bidx = 1:bincount
  for sidx = 1:sizecount

    % FIXME - Kludge the upper bound.
    % We have three situations: Either it's near log2(bins), or it's 1-2 bits,
    % or it's absurdly high due to an extrapolation error. Force the first two.

    ymaxval = helper_getYMax( histbinlist(bidx), datavals(:,sidx,bidx,:) );


    clf('reset');

    hold on;

    for didx = 1:datacount

      thisdata = datavals(:,sidx,bidx,didx);
      thisdata = reshape(thisdata, size(laglist));

      % NOTE - Squash "lag = 0". It's always zero.
      squashmask = ( abs(laglist) < 0.5 );
      thisdata(squashmask) = NaN;

      plot( laglist, thisdata, 'DisplayName', datatitles{didx} );
    end

    plot( laglist, zeros(size(laglist)), 'HandleVisibility', 'off', ...
      'Color', [ 0.5 0.5 0.5 ] );

    hold off;

    xlabel('Time Lag (samples)');
    ylabel(axistitle);

    ylim([ -0.25 ymaxval ]);

    legend('Location', 'northwest');

    countlabel = helper_makePrettyCount(sampcountlist(sidx));

    if isnan(histbinlist(bidx))
      title([ titleprefix ' - auto bins - ' countlabel ' samples' ]);

      saveas( thisfig, [ fileprefix '-lagcase-autobins-' ...
        countlabel 'samp.png' ] );
    else
      title([ titleprefix ' - ' ...
        sprintf('%d bins - ', histbinlist(bidx)) ...
        countlabel ' samples' ]);

      saveas( thisfig, [ fileprefix '-lagcase-' ...
        sprintf('%02dbins', histbinlist(bidx)) '-' countlabel 'samp.png' ] );
    end

  end
end



% Entropy as a function of sample count.
% One plot per data case.
% One curve per bin count.
% Fixed time lag.

for didx = 1:datacount

  % FIXME - Kludge the upper bound.
  % We have three situations: Either it's near log2(bins), or it's 1-2 bits,
  % or it's absurdly high due to an extrapolation error. Force the first two.

  ymaxval = helper_getYMax( histbinlist, datavals(testlagidx,:,:,didx) );


  clf('reset');

  hold on;

  for bidx = 1:bincount
    thisdata = datavals(testlagidx,:,bidx,didx);
    thisdata = reshape(thisdata, size(sampcountlist));

    if isnan(histbinlist(bidx))
      plot( sampcountlist, thisdata, 'DisplayName', 'auto bins' );
    else
      plot( sampcountlist, thisdata, 'DisplayName', ...
        sprintf('%d bins', histbinlist(bidx)) );
    end
  end

  plot( sampcountlist, zeros(size(sampcountlist)), ...
    'HandleVisibility', 'off', 'Color', [ 0.5 0.5 0.5 ] );

  hold off;

  xlabel('Sample Count');
  ylabel(axistitle);

  set(gca, 'Xscale', 'log');

  ylim([ -0.25 ymaxval ]);

  legend('Location', 'southwest');

  title([ titleprefix ' - ' datatitles{didx} ...
    sprintf(' - Lag %+d samps', testlag) ]);

  saveas( thisfig, [ fileprefix '-binlength-' datalabels{didx} '.png' ] );

end



% Finished plotting.

close(thisfig);


% Done.
end


%
% Helper Functions


function ymaxval = helper_getYMax( histbins, datavals )

  % FIXME - Kludge the upper bound.
  % We have three situations: Either it's near log2(bins), or it's 1-2 bits,
  % or it's absurdly high due to an extrapolation error. Force the first two.

  % We may also be passed a bin count of "NaN" for discrete data.

  binmaxval = log2(max(histbins));
  datamaxval = max(datavals, [], 'all');

  if isnan(binmaxval)
    ymaxval = datamaxval;
  else
    ymaxval = min(datamaxval, binmaxval);
  end

  ymaxval = max(1, ymaxval + 0.5);

end


%
% This is the end of the file.
