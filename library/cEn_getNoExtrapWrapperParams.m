function newparams = cEn_getNoExtrapWrapperParams()

% function newparams = cEn_getNoExtrapWrapperParams()
%
% This returns an extrapolation parameter structure (per EXTRAPOLATION.txt)
% that results in no extrapolation being performed (just a single function
% call for calculation).
%
% No arguments.
%
% "newparams" is an extrapolation configuration parameter structure.


newparams = struct( 'divisors', 1, 'testcount', 1 );


% Done.
end


%
% This is the end of the file.
