function is_ok = helper_writeTextFile( fname, textcontent )

% function is_ok = helper_writeTextFile( fname, textcontent )
%
% This attempts to write the specified character vector as ASCII text.
%
% "fname" is the name of the file to write to.
% "textcontent" is a character vector containing the text to write.
%
% "is_ok" is true if the operation succeeds and false otherwise.

is_ok = true;

sampcount = length(textcontent);

fid = fopen(fname, 'w');

if 0 > fid
  disp(sprintf( 'Unable to write to "%s".', fname ));
  is_ok = false;
else
  writecount = 0;
  if 0 < sampcount
    writecount = fwrite(fid, textcontent, 'char*1');
  end
  fclose(fid);

  if writecount ~= sampcount
    disp(sprintf( 'Incomplete write to "%s" (%d of %d samples).', ...
      fname, writecount, sampcount ));
    is_ok = false;
  end
end


% Done.
end


%
% This is the end of the file.
