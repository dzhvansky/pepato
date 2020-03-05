function MSER2 = mse_r2(Y)

X = 1:length(Y);

P = polyfit(X,Y,1);
Yhat = polyval(P,X);

MSER2 = mean((Y - Yhat).^2);

end