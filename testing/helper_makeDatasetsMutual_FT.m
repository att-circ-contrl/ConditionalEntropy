function datasets = helper_makeDatasetsMutual_FT( sampcount, trialcount )

% function datasets = helper_makeDatasetsMutual_FT( sampcount, trialcount )
%
% This builds data series used for testing calculation of mutual information
% and conditional Shannon entropy. All sample values are in the range 0..1.
%
% This outputs fake Field Trip structures. NOTE - These are intended to be
% used for testing entropy library functions. While the structures meet the
% minimum content requirements defined by Field Trip, they're missing header
% and config information, so they might not work with Field Trip functions.
%
% "sampcount" is the desired number of samples per trial.
% "trialcount" is the desired number of trials.
%
% "datasets" is a Nx3 cell array. Element {k,1} is a ft_datatype_raw
%   structure containing data samples, element {k,2} is a short plot- and
%   filename-safe label, and element {k,3} is a plot-safe verbose label
%   for data series k.


% Wrap the data generator function.

datafunc = @( nsamps ) helper_makeDatasetsMutual( nsamps );

datasets = helper_makeDatasetsFTWrapper( sampcount, trialcount, datafunc );


% Done.
end


%
% This is the end of the file.
