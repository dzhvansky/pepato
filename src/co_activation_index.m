function CI = co_activation_index(x, y)

x = reshape(x, 1, []);
y = reshape(y, 1, []);

x = x / max(x);
y = y / max(y);

H = max([x; y]); 
L = min([x; y]);

CI = mean((H + L/2) .* (L ./ H));

end