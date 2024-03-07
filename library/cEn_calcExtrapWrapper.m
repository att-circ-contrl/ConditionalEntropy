function [ outval extuning ] = ...
  cEn_calcExtrapWrapper( dataseries, datafunc, exparams )

% function [ outval extuning ] = ...
%   cEn_calcExtrapWrapper( dataseries, datafunc, exparams )
%
% This calls a user-supplied function to process data (typically an
% entropy-calculation function). Results at low sample counts are
% extrapolated to estimate the result at large sample counts.
%
% Extrapolation is performed using the method described in Palmigiano 2017,
% which is based on the method described in Strong 1998, which is based on
% the analysis performed in Treves 1995:
%
% (Palmigiano 2017) "Flexible Information Routing by Transient Synchrony"
% (Strong 1998) "Entropy and Information in Neural Spike Trains"
% (Treves 1995) "The Upward Bias in Measures of Information Derived From
%   Limited Data Samples"
%
% For several values of N, M subsets of size (nsamples/N) are selected from
% the sample data. The entropy calculation is run on these M subsets and the
% results averaged, producing a result for the chosen value of N. A
% A quadratic fit is performed to the results (as a function of N), and the
% Y intercept (N = 0) is taken as the estimated infinite-length output.
%
% "dataseries" is a (Nchans,Nsamples) matrix containing several data series.
% "datafunc" is a function handle, accepting one argument (the data series).
%   This function has the form:
%     function outval = datafunc( dataseries )
%   This is typically defined as a wrapper passing additional arguments:
%     datafunc = @( dataseries ) doSomething( dataseries, extra_args );
% "exparams" is a structure containing extrapolation parameters. This may
%   be empty; missing parameter values are set to default values. Fields are:
%   "divisors" is a vector containing divisors for nsamples. Default: [1:10]
%   "testcount" is the number of tests to average for each divisor. Default: 3
%
% "outval" is the extrapolated output of "datafunc".
% "extuning" is a copy of "exparams" with all missing fields filled in.


%
% Check tuning parameters and fill in defaults.

if isempty(exparams)
  exparams = struct();
end

if ~isfield(exparams, 'divisors')
  exparams.divisors = 1:10;
end

if ~isfield(exparams, 'testcount')
  exparams.testcount = 3;
end

% Force sanity.
% We get sorting for free here.
divisors = round(exparams.divisors);
divisors = unique(divisors);
divisors = divisors( divisors > 0 );
if isempty(divisors)
  divisors = 1;
end
exparams.divisors = divisors;

% Save the resulting tuning parameter structure.
extuning = exparams;


%
% Get geometry and fetch parameters.

chancount = size(dataseries,1);
sampcount = size(dataseries,2);

testcount = exparams.testcount;

% We want descending order.
% This should already be sorted, but re-sort anyways.
divisors = flip( sort(divisors) );


%
% Walk through the test sets, getting points to curve-fit.

outlist = [];

for didx = 1:length(divisors)

  thislength = round( sampcount / divisors(didx) );

  if thislength < 1
    thislength = 1;
  end

  thisavg = 0;

  for tidx = 1:testcount

    % This gets us k unique integers in the range 1 to sampcount.
    srcidx = randperm( sampcount, thislength );

    % There's probably a Matlab way to do this in one line, but I don't
    % know what it is.
    thisdata = zeros([ chancount thislength ]);
    for cidx = 1:chancount
      thisdata(cidx,:) = dataseries(cidx,srcidx);
    end

    thisoutput = datafunc(thisdata);

    thisavg = thisavg + thisoutput;

  end

  thisavg = thisavg / testcount;
  outlist(didx) = thisavg;

end


%
% Extrapolate to N = 0.

p = polyfit(divisors, outlist, 2);
outval = polyval(p, 0);


% Done.
end


%
% This is the end of the file.
