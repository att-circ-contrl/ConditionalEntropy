function newparams = cEn_fillExtrapWrapperParams( oldparams )

% function newparams = cEn_fillExtrapWrapperParams( oldparams )
%
% This function fills in missing fields in extrapolation parameter
% structures used by cEn_calcExtrapWrapper(), per EXTRAPOLATION.txt.
%
% "oldparams" is an extrapolation parameter structure to modify.
%
% "newparams" is a copy of "oldparams" with missing fields filled in.


% Check for struct([]).

if isempty(oldparams)
  oldparams = struct();
end


% Check for missing fields.

if ~isfield(oldparams, 'divisors')
  % From Palmigiano 2017.
  oldparams.divisors = 1:10;
end

if ~isfield(oldparams, 'testcount')
  % From Palmigiano 2017.
  oldparams.testcount = 3;
end


% Force sanity on the divisor list.
% This sorts it, as a side effect.

divisors = oldparams.divisors;

divisors = round(divisors);
divisors = unique(divisors);
divisors = divisors( divisors > 0 );
if isempty(divisors)
  divisors = 1;
end

oldparams.divisors = divisors;


% Save the resulting extrapolation parameter structure.
newparams = oldparams;


% Done.
end


%
% This is the end of the file.
