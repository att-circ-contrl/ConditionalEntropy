function helper_plotDataSignals( dataseries, chanlabels, ...
  plotsamps, titleprefix, fileprefix )

% function helper_plotDataSignals( dataseries, chanlabels, ...
%   plotsamps, titleprefix, fileprefix )
%
% This plots the signals from one dataset.
%
% "dataseries" is a Nchans x Nsamples matrix with signal data.
% "chanlabels" is a cell array containing plot-safe channel names.
% "plotsamps" is the number of samples to plot.
% "titleprefix" is a character vector used for building the plot title.
% "fileprefix" is a character vector used for building filenames.
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

title( titleprefix );

saveas( thisfig, [ fileprefix '.png' ] );

close(thisfig);



% Done.
end


%
% This is the end of the file.
