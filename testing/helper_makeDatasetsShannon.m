function datasets = helper_makeDatasetsShannon( sampcount )

% function datasets = helper_makeDatasetsShannon( sampcount )
%
% This builds data series used for testing calculation of Shannon entropy.
% All sample values are in the range 0..1.
%
% "sampcount" is the desired number of samples per series.
%
% "datasets" is a Nx3 cell array. Element {k,1} is a vector or matrix
%   containing data samples, element {k,2} is a short plot- and filename-safe
%   label, and element {k,3} is a plot-safe verbose label for data series k.


% Compute 2d size so that the sample count stays more or less the same.
size1d = sampcount;
size2d = round(sqrt( sampcount ));


% All of these have data ranging from 0..1.

data_1d_const = ones([ 1 size1d ]);

data_1d_ramp = 1:size1d;
data_1d_ramp = data_1d_ramp / max(data_1d_ramp);

data_1d_para = data_1d_ramp .* data_1d_ramp;

data_1d_norm = normrnd(0.5, 0.17, [ 1 size1d ]);
data_1d_norm = min(data_1d_norm, 1);
data_1d_norm = max(data_1d_norm, 0);

data_1d_unirand = rand([ 1 size1d ]);


datasets_1d = ...
{ data_1d_const,   'const1', '1D Constant' ; ...
  data_1d_ramp,    'ramp1',  '1D Ramp' ; ...
  data_1d_para,    'para1',  '1D Parabola' ; ...
  data_1d_norm,    'norm1',  '1D Normal' ; ...
  data_1d_unirand, 'urand1', '1D Uniform Random' };


data_2d_const = ones([ size2d size2d ]);

data_2d_ramp = 1:(size2d * size2d);
data_2d_ramp = reshape(data_2d_ramp, [ size2d size2d ]);
data_2d_ramp = data_2d_ramp / max(data_2d_ramp, [], 'all');

data_2d_para = data_2d_ramp .* data_2d_ramp;

data_2d_norm = normrnd(0.5, 0.17, [ size2d size2d ]);
data_2d_norm = min(data_2d_norm, 1);
data_2d_norm = max(data_2d_norm, 0);

data_2d_unirand = rand([ size2d size2d ]);


datasets_2d = ...
{ data_2d_const,   'const2', '2D Constant' ; ...
  data_2d_ramp,    'ramp2',  '2D Ramp' ; ...
  data_2d_para,    'para2',  '2D Parabola' ; ...
  data_2d_norm,    'norm2',  '2D Normal' ; ...
  data_2d_unirand, 'urand2', '2D Unif Random' };


% Combine vector and matrix data cases.

datasets = [ datasets_1d ; datasets_2d ];


% Done.
end


%
% This is the end of the file.
