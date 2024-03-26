function helper_plotTESweptData( ...
  datavals, laglist, sampcountlist, histbinlist, ...
  datalabels, datatitles, axistitle, titleprefix, fileprefix )

% function helper_plotSweptData( ...
%   datavals, laglist, sampcountlist, histbinlist, ...
%   datalabels, datatitles, axistitle, titleprefix, fileprefix )
%
% This generates one plot per data case, with one curve per bin count,
% plotting entropy as a function of sample count.
%
% "datavals" is a matrix of size Nlags x Nsampcounts x Nhistbins x Ndatacases,
%   containing transfer entropy data.
% "laglist" is a vector containing time lags (in samples).
% "sampcountlist" is a vector containing sample counts.
% "histbinlist" is a vector containing histogram bin counts.
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


thisfig = figure();
figure(thisfig);

for didx = 1:length(datalabels)
  for bidx = 1:length(histbinlist)

    % FIXME - Kludge the upper bound.
    % We have three situations: Either it's near log2(bins), or it's 1-2 bits,
    % or it's absurdly high due to an extrapolation error. Force the first two.

    ymaxval = log2(histbinlist(bidx));
    datamaxval = datavals(:,:,bidx,didx);
    datamaxval = max(datamaxval, [], 'all');
    ymaxval = min(datamaxval, ymaxval);
    ymaxval = max(1, ymaxval);


    clf('reset');

    hold on;

    for sidx = 1:length(sampcountlist)
      thisdata = datavals(:,sidx,bidx,didx);
      thisdata = reshape(thisdata, size(laglist));

      % NOTE - Squash "lag = 0". It's always zero.
      squashmask = ( abs(laglist) < 0.5 );
      thisdata(squashmask) = NaN;

      plot( laglist, thisdata, 'DisplayName', ...
        [ helper_makePrettyCount(sampcountlist(sidx)) ' samples' ] );
    end

    hold off;

    xlabel('Time Lag (samples)');
    ylabel(axistitle);

    ylim([ 0 ymaxval ]);

    legend('Location', 'southwest');

    title([ titleprefix ' - ' datatitles{didx} ...
      sprintf(' - %d bins', histbinlist(bidx)) ]);

    saveas( thisfig, [ fileprefix '-' datalabels{didx} ...
      sprintf('-%02dbins.png', histbinlist(bidx)) ] );

  end
end


close(thisfig);


% Done.
end


%
% This is the end of the file.
