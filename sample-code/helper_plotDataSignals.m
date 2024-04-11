function helper_plotDataSignals( dataseries, chanlabels, ...
  plotsamps, figtitle, fname )

% function helper_plotDataSignals( dataseries, chanlabels, ...
%   plotsamps, figtitle, fname )
%
% This plots the signals from one dataset.
%
% "dataseries" is a Nchans x Nsamples matrix with signal data.
% "chanlabels" is a cell array containing plot-safe channel names.
% "plotsamps" is the number of samples to plot.
% "figtitle" is a character vector to use as the plot title.
% "fname" is a character vector with the filename to write the plot to.
%
% No return value.


chancount = size(dataseries,1);
sampcount = size(dataseries,2);

if sampcount > plotsamps
  sampcount = plotsamps;
  dataseries = dataseries(:,1:sampcount);
end


thisfig = figure();
figure(thisfig);

clf('reset');

hold on;

for cidx = 1:chancount
  plot( dataseries(cidx,:), 'DisplayName', chanlabels{cidx} );
end

hold off;

xlabel('Sample Index');
ylabel('Amplitude (a.u.)');

legend('Location', 'northeast');

title( figtitle );

saveas( thisfig, fname );

close(thisfig);



% Done.
end


%
% This is the end of the file.
