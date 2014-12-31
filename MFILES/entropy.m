function[norment] = entropy(x)

x = abs(x(:));
N = length(x);
den = sqrt( sum(x.*x) );
x = x./den;
non_zero = find(x);
temp = ( x(non_zero).*log( x(non_zero) ) );
ent = -sum(temp(:));
maxent = -N/sqrt(N)*log(1/sqrt(N));

norment = ent/maxent;

