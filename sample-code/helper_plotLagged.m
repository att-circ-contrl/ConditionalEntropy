function helper_plotLagged( ...
  datavals, laglist, testlag, sampcountlist, histbinlist, ...
  axistitle, titleprefix, filepattern, squashflag )

% function helper_plotLagged( ...
%   datavals, laglist, testlag, sampcountlist, histbinlist, ...
%   axistitle, titleprefix, filepattern, squashflag )
%
% This generates two types of plot for measures that are functions of time
% lag.
%
% The first type generates one plot per bin count, with one curve per sample
% count, plotting the measure as a function of time lag.
%
% The second type generates a single plot with one curve per bin count,
% plotting the measure as a function of sample count at the "test" time
% lag.
%
% "datavals" is a matrix of size Nlags x Nsampcounts x Nhistbins, containing
%   containing the data measure (mutual information or transfer entropy).
% "laglist" is a vector containing time lags (in samples).
% "testlag" is a scalar with a time lag to use for the single-lag plot.
% "sampcountlist" is a vector containing sample counts.
% "histbinlist" is a vector containing histogram bin counts.
% "axistitle" is a character vector with the Y axis title.
% "titleprefix" is a character vector with a prefix to use when building
%   plot titles.
% "filepattern" is a character vector with a sprintf pattern with exactly one
%   '%s' code to use when building filenames.
% "squashflag" is 'squashzero' to squash the sample at lag 0. If it's
%   anything else, or omitted as an argument, no squashing is performed.
%
% No return value.


% Get metadata.

bincount = length(histbinlist);
sizecount = length(sampcountlist);

want_squash = false;
if exist('squashflag', 'var')
  want_squash = strcmp(squashflag, 'squashzero');
end


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



% Measure as a function of time lag.
% One plot per bin count.
% One curve per sample count.

for bidx = 1:bincount

  % FIXME - Kludge the upper bound.
  % We have three situations: Either it's near log2(bins), or it's 1-2 bits,
  % or it's absurdly high due to an extrapolation error. Force the first two.

  ymaxval = helper_getYMax( histbinlist(bidx), datavals(:,:,bidx) );


  clf('reset');

  hold on;

  for sidx = 1:sizecount
    thisdata = datavals(:,sidx,bidx);
    thisdata = reshape(thisdata, size(laglist));

    if want_squash
      % NOTE - Squash "lag = 0". It's always zero for transfer entropy.
      squashmask = ( abs(laglist) < 0.5 );
      thisdata(squashmask) = NaN;
    end

    plot( laglist, thisdata, 'DisplayName', ...
      sprintf('%d samples', sampcountlist(sidx)) );
  end

  plot( laglist, zeros(size(laglist)), 'HandleVisibility', 'off', ...
    'Color', [ 0.5 0.5 0.5 ] );

  hold off;

  xlabel('Time Lag (samples)');
  ylabel(axistitle);

  ylim([ -0.25 ymaxval ]);

  legend('Location', 'northwest');

  if isnan(histbinlist(bidx))
    title([ titleprefix ' - auto bins' ]);

    saveas( thisfig, sprintf(filepattern, 'laglength-autobins') );
  else
    title([ titleprefix sprintf(' - %d bins', histbinlist(bidx)) ]);

    thislabel = sprintf('laglength-%02dbins', histbinlist(bidx));
    saveas( thisfig, sprintf(filepattern, thislabel) );
  end

end



% Measure as a function of sample count.
% One curve per bin count.
% Fixed time lag.

% FIXME - Kludge the upper bound.
% We have three situations: Either it's near log2(bins), or it's 1-2 bits,
% or it's absurdly high due to an extrapolation error. Force the first two.

ymaxval = helper_getYMax( histbinlist, datavals(testlagidx,:,:) );


clf('reset');

hold on;

for bidx = 1:bincount
  thisdata = datavals(testlagidx,:,bidx);
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

title([ titleprefix sprintf(' - Lag %+d samps', testlag) ]);

saveas( thisfig, sprintf(filepattern, 'binlength') );



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
