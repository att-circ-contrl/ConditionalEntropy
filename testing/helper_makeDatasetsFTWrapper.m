function datasets = ...
  helper_makeDatasetsFTWrapper( sampcount, trialcount, datafunc )

% function datasets = ...
%   helper_makeDatasetsFTWrapper( sampcount, trialcount, datafunc )
%
% This is a wrapper for helper_makeDatasetsXX that generates fake Field Trip
% data structures. This calls the generator function for each trial,
% producing independent data (i.e. trials would have discontinuities if
% concatenated).
%
% The first channel returned is given the name "chY", and subsequent
% channels are given the names "chX1", "chX2", etc.
%
% The resulting Field Trip structures are intended to be used for testing
% entropy library functions. While the structures meet the minimum content
% requirements defined by Field Trip, they're missing header and config
% information, so they might not work with all Field Trip functions.
%
% "sampcount" is the desired number of samples per trial.
% "trialcount" is the desired number of trials.
% "datafunc" is a function handle, accepting one argument (sampcount)
%   and returning a dataset structure (a Nx3 cell array, where element {k,1}
%   contains a Nchans x Nsamples data matrix).
%   This function has the form:
%     function datasets = datafunc( sampcount )
%   This is typically defined as a wrapper passing additional arguments:
%     datafunc = @( sampcount ) doSomething( sampcount, extra_args );
%
% "datasets" is a Nx3 cell array. Element {k,1} is a ft_datatype_raw
%   structure containing data samples, element {k,2} is a short plot- and
%   filename-safe label, and element {k,3} is a plot-safe verbose label
%   for data series k.


% Build fake time metadata.

fsample = 1000;

timeseries = 1:sampcount;
timeseries = (timeseries - 1) / fsample;

timefield = {};
for tidx = 1:trialcount
  timefield{1,tidx} = timeseries;
end


% Generate a single dataset and get dataset metadata.

thisdatasetlist = datafunc(sampcount);

datacount = size(thisdatasetlist,1);

% Data matrices are Nchans x Nsamps. Get channel counts per set.

nchansbyset = [];
for didx = 1:datacount
  thisdata = thisdatasetlist{didx,1};
  nchansbyset(didx) = size(thisdata,1);
end


% Initialize output using this dataset. Squash the actual data.

datasets = thisdatasetlist;
datasets(:,1) = {[]};


% Build fake channel metadata.

labelfieldbyset = {};
for didx = 1:datacount
  thislabellist = { 'chY' };
  chancount = nchansbyset(didx);
  for cidx = 2:chancount
    thislabellist{cidx,1} = sprintf('chX%d', (cidx - 1));
  end

  labelfieldbyset{didx} = thislabellist;
end


% Build trial matrices.
% Generate each trial independently, and append to the trial matrix.

trialsbyset = {};
for tidx = 1:trialcount

  thisdatasetlist = datafunc(sampcount);

  for didx = 1:datacount
    thisdata = thisdatasetlist{didx,1};

    if tidx > 1
      trialsbyset{didx}{tidx} = thisdata;
    else
      trialsbyset{didx} = { thisdata };
    end
  end

end


% Build Field Trip structures.

for didx = 1:datacount
  thisft = struct();

  thisft.fsample = fsample;
  thisft.time = timefield;

  thisft.label = labelfieldbyset{didx};
  thisft.trial = trialsbyset{didx};

  datasets{didx,1} = thisft;
end


% Done.
end


%
% This is the end of the file.
