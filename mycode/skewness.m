function s = skewness(x)

xNorm = x - repmat(mean(x), size(x));

x2 = mean(xNorm.^2);
x3 = mean(xNorm.^3);

s = x3 ./ (x2.^(1.5));