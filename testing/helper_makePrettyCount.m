function countlabel = helper_makePrettyCount(count)

% function countlabel = helper_makePrettyCount(count)
%
% This formats a positive integer count in a concise human-readable way.
% Examples would be "5k0" or "30M".
%
% NOTE - This is only well-behaved for 0..1e+15.
%
% "count" is a positive integer value.
%
% "countlabel" is a plot- and filename-safe terse representation of "count".


% Initialize.
countlabel = '-bogus-';


% First pass: Get the scale factor.

divisor = 1;
symbol = '';

if count > 999999999999
  divisor = 1e12;
  symbol = 'T';
elseif count > 999999999
  divisor = 1e9;
  symbol = 'G';
elseif count > 999999
  divisor = 1e6;
  symbol = 'M';
elseif count > 999
  divisor = 1e3;
  symbol = 'k';
end


% Second pass: format for two significant digits.

prefix = 'XX';
suffix = 'xxx';

count = count / divisor;

if count < 2
  count = round(count * 100);
  prefix = sprintf( '%d', floor(count / 100) );
  suffix = sprintf( '%02d', mod(count, 100) );
elseif count < 20
  count = round(count * 10);
  prefix = sprintf( '%d', floor(count / 10) );
  suffix = sprintf( '%01d', mod(count, 10) );
elseif count < 200
  count = round(count);
  prefix = sprintf( '%d', count );
  suffix = '';
else
  % We should be in the range 200..999, but tolerate oversized.
  count = round(count / 10);
  prefix = sprintf( '%d', count * 10 );
  suffix = '';
end


% Assemble the output.

% NOTE - We're expecting integers, so only emit the suffix if we have a
% symbol indicating an original number larger than 999.

countlabel = prefix;

if length(symbol) > 0
  countlabel = [ countlabel symbol suffix ];
end


% Done.
end


%
% This is the end of the file.
