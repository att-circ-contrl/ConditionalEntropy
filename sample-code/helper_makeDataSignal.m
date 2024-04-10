function dataseries = helper_makeDataSignal( sampcount, signaltype )

% function dataseries = helper_makeDataSignal( sampcount, signaltype )
%
% This builds a random data signal of the specified length.
% For 'noise' and 'sine', all sample values are in the range 0..1.
% For 'counts', all sample values are non-negative integers.
%
% "sampcount" is the number of samples to generate.
% "signaltype" is 'noise', 'sine', or 'counts'.
%
% "dataseries" is a 1xNsamps vector containing signal samples.


dataseries = NaN([ 1 sampcount ]);

if strcmp(signaltype, 'noise')

  % Uniform random values.
  dataseries = rand([ 1 sampcount ]);

elseif strcmp(signaltype, 'sine')

  % Pick three harmonics with random phase shifts.
  % Make the period vary by a factor of about 3 with a minimum of about
  % 10 samples.
  % Make the harmonics far enough apart in frequency to avoid visible beat
  % frequency artifacts.

  fmax = round(sampcount / 10);
  fmin = round(fmax / 6);

  f1 = fmin + randi( fmin );
  f2 = 3 * fmin + randi( fmin );
  f3 = 5 * fmin + randi( fmin );

  p1 = rand() * 2 * pi;
  p2 = rand() * 2 * pi;
  p3 = rand() * 2 * pi;

  timeseries = 1:sampcount;
  timeseries = timeseries * 2 * pi / sampcount;

  dataseries = 0.5 * sin( f1 * timeseries + p1 ) ...
    + 0.3 * sin( f2 * timeseries + p2 ) ...
    + 0.2 * sin( f2 * timeseries + p2 );

  dataseries = 0.5 * dataseries + 0.5;

elseif strcmp(signaltype, 'counts')

  % Poisson random values, with a rate parameter drawn from a uniform
  % random range.
  lambda = rand() + 0.5;
  dataseries = poissrnd( lambda, [ 1 sampcount ] );

else

  disp([ '###  Unknown signal type "' signaltype '" requested.' ]);

end


% Done.
end


%
% This is the end of the file.
