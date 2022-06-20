function [A] = replace_nan_inf(A)

%Replace the values where A==-inf with the minimum real number.
A(A==-inf) = min(A(isfinite(A)));
%Replace the values where A==+inf with the maximum real number.
A(A==inf)  = max(A(isfinite(A)));

A(A==inf)  = max(A(isfinite(A)));

A(isnan(A))=0;