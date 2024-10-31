function helper_plotMutualInfo( datavals, dataval_vars, ...
  sampcountlist, histbinlist, axistitle, figtitle, fname )

% function helper_plotMutualInfo( datavals, dataval_vars, ...
%   sampcountlist, histbinlist, axistitle, figtitle, fname )
%
% This plots estimates of mutual information.
% This generates one plot per data case, with one curve per bin count,
% plotting estimated MI as a function of sample count.
%
% "datavals" is a matrix of size Nsampcounts x Nhistbins, containing data
%   to be plotted.
% "dataval_vars" is a matrix containing the estimated variance of each
%   element of "datavals".
% "sampcountlist" is a vector containing sample counts.
% "histbinlist" is a vector containing histogram bin counts.
% "axistitle" is a character vector with the Y axis title.
% "figtitle" is a character vector to use as the figure title.
% "fname" is a character vector with the filename to save the plot to.
%
% No return value.


thisfig = figure();
figure(thisfig);


% FIXME - Kludge the upper bound.
% We have three situations: Either it's near log2(bins), or it's 1-2 bits,
% or it's absurdly high due to an extrapolation error. Force the first two.

binmaxval = log2(max(histbinlist));
datamaxval = max(datavals, [], 'all');

if isnan(binmaxval)
  ymaxval = datamaxval;
else
  ymaxval = min(datamaxval, binmaxval);
end

ymaxval = max(1, ymaxval + 0.5);


clf('reset');

hold on;

% Plot values without confidence intervals first.
% Build the palette lookup table while we do this.

palette = {};

for bidx = 1:length(histbinlist)
  thisdata = datavals(:,bidx);
  thisdata = reshape(thisdata, size(sampcountlist));

  if isnan(histbinlist(bidx))
    thisline = plot( sampcountlist, thisdata, ...
      'DisplayName', 'auto bins' );
  else
    thisline = plot( sampcountlist, thisdata, ...
      'DisplayName', sprintf('%d bins', histbinlist(bidx)) );
  end

  palette{bidx} = thisline.Color;
end


% Plot axis.
plot( sampcountlist, zeros(size(sampcountlist)), ...
  'HandleVisibility', 'off', 'Color', [ 0.5 0.5 0.5 ] );


% Plot confidence intervals.

for bidx = 1:length(histbinlist)
  thisdata = datavals(:,bidx);
  thisdata = reshape(thisdata, size(sampcountlist));

  thisconf = dataval_vars(:,bidx);
  thisconf = reshape(thisconf, size(sampcountlist));

  % Convert variance to 2-sigma.
  thisconf = 2 * sqrt(thisconf);

  plot( sampcountlist, thisdata + thisconf, '--', ...
    'HandleVisibility', 'off', 'Color', palette{bidx} );

  plot( sampcountlist, thisdata - thisconf, '--', ...
    'HandleVisibility', 'off', 'Color', palette{bidx} );
end


hold off;

xlabel('Sample Count');
ylabel(axistitle);

set(gca, 'Xscale', 'log');

ylim([ -0.25 ymaxval ]);

legend('Location', 'southwest');

title(figtitle);

saveas( thisfig, fname );


close(thisfig);


% Done.
end


%
% This is the end of the file.
