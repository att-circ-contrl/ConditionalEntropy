function helper_plotSweptData( datavals, sampcountlist, histbinlist, ...
  datalabels, datatitles, axistitle, titleprefix, fileprefix )

% function helper_plotSweptData( datavals, sampcountlist, histbinlist, ...
%   datalabels, datatitles, axistitle, titleprefix, fileprefix )
%
% This generates one plot per data case, with one curve per bin count,
% plotting entropy as a function of sample count.
%
% "datavals" is a matrix of size Nsampcounts x Nhistbins x Ndatacases,
%   containing entropy data.
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

  % FIXME - Kludge the upper bound.
  % We have three situations: Either it's near log2(bins), or it's 1-2 bits,
  % or it's absurdly high due to an extrapolation error. Force the first two.

  binmaxval = log2(max(histbinlist));
  datamaxval = datavals(:,:,didx);
  datamaxval = max(datamaxval, [], 'all');

  if isnan(binmaxval)
    ymaxval = datamaxval;
  else
    ymaxval = min(datamaxval, binmaxval);
  end

  ymaxval = max(1, ymaxval + 0.5);


  clf('reset');

  hold on;

  for bidx = 1:length(histbinlist)
    thisdata = datavals(:,bidx,didx);
    thisdata = reshape(thisdata, size(sampcountlist));

    if isnan(histbinlist(bidx))
      plot( sampcountlist, thisdata, ...
        'DisplayName', 'auto bins' );
    else
      plot( sampcountlist, thisdata, ...
        'DisplayName', sprintf('%d bins', histbinlist(bidx)) );
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

  title([ titleprefix ' - ' datatitles{didx} ]);

  saveas( thisfig, [ fileprefix '-' datalabels{didx} '.png' ] );

end


close(thisfig);


% Done.
end


%
% This is the end of the file.
