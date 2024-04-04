function newparams = cEn_extrapParamsNoExtrap()

% function newparams = cEn_extrapParamsNoExtrap()
%
% This returns an extrapolation parameter structure (per EXTRAPOLATION.txt)
% that results in no extrapolation being performed (just a single function
% call for calculation).
%
% NOTE - It's better to omit the extrapolation parameter structure, to
% omit the call to the extrapolation wrapper in the first place. Calling the
% wrapper does have overhead.
%
% No arguments.
%
% "newparams" is an extrapolation configuration parameter structure.


newparams = struct( 'divisors', 1, 'testcount', 1 );


% Done.
end


%
% This is the end of the file.
