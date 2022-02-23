

function val = gauss2d(x, y, sigma, center)

xc = center(1);
yc = center(2);
exponent = ((x-xc).^2 + (y-yc).^2)./(2*sigma^2);
val       = (exp(-exponent));




return