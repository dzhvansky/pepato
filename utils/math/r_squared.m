function R2 = r_squared(M, Mhat)

y = reshape(M, 1, []);
yhat = reshape(Mhat, 1, []);

R2 = 1-sum((y-yhat).^2)/sum((y-nanmean(y)).^2);

end