function [ datasets_2ch datasets_3ch ] = ...
  helper_makeDatasetsTransfer_FT( ...
    sampcount, trialcount, samp_shift, signaltype )

% function [ datasets_2ch datasets_3ch ] = ...
%   helper_makeDatasetsTransfer_FT( ...
%     sampcount, trialcount, samp_shift, signaltype )
%
% This builds data series used for testing calculation of transfer entropy.
% and partial transfer entropy. Signal pairs that are correlated may be
% time-lagged. All sample values are in the range 0..1.
%
% This outputs fake Field Trip structures. NOTE - These are intended to be
% used for testing entropy library functions. While the structures meet the
% minimum content requirements defined by Field Trip, they're missing header
% and config information, so they might not work with Field Trip functions.
%
% "sampcount" is the desired number of samples per trial.
% "trialcount" is the desired number of trials.
% "samp_shift" is the number of samples by which data series should be
%   shifted forward or backward in time, for time-lagged signals.
% "signaltype" is 'noise' or 'sine'.
%
% "datasets_2ch" is a Nx3 cell array. Element {k,1} is a ft_datatype_raw
%   structure containing two data channels, element {k,2} is a short plot-
%   and filename-safe label, and element {k,3} is a plot-safe verbose label
%   for data series k.
% "datasets_3ch" is a Nx3 cell array. Element {k,1} is a ft_datatype_raw
%   structure containing three data channels, element {k,2} is a short plot-
%   and filename-safe label, and element {k,3} is a plot-safe verbose label
%   for data series k.


% Wrap the data generator function.
% Make two wrappers, selecting the 2ch and 3ch outputs.

datafunc_2ch = @( nsamps ) helperFT_makeOneTransferSet( ...
  nsamps, samp_shift, signaltype, '2ch' );
datafunc_3ch = @( nsamps ) helperFT_makeOneTransferSet( ...
  nsamps, samp_shift, signaltype, '3ch' );

datasets_2ch = ...
  helper_makeDatasetsFTWrapper( sampcount, trialcount, datafunc_2ch );
datasets_3ch = ...
  helper_makeDatasetsFTWrapper( sampcount, trialcount, datafunc_3ch );


% Done.
end


%
% Helper Functions

function datasets = ...
  helperFT_makeOneTransferSet( sampcount, samp_shift, signaltype, whicharg )

  [ thisdata_2ch thisdata_3ch ] = ...
    helper_makeDatasetsTransfer( sampcount, samp_shift, signaltype );

  if strcmp('3ch', whicharg)
    datasets = thisdata_3ch;
  else
    datasets = thisdata_2ch;
  end

end


%
% This is the end of the file.
