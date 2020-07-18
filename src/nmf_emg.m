function [Wn, Cn, R2] = nmf_emg(emg_normalized, n_synergies, n_points, replicates)

n_samples = size(emg_normalized, 1);
n_emg = size(emg_normalized, 2);

if nargin < 3
    n_points = 200; replicates = 10;
elseif nargin < 4
    replicates = 10;
end

% nmf_options = statset('MaxIter',1000,'TolFun',1e-5,'TolX',1e-5); %Nonnegative Matrix Factorization Options
% [W_best,C_best,~] = nnmf(emg_normalized', n_synergies, 'replicates', replicates, 'options', nmf_options, 'algorithm', 'mult'); %W = weights, C = coefficients, D = residue

nmf_options = cell2struct({[], [], [50 10 1e-5], 1000, false, false, true}, ...
    {'isynfiltcoef', 'synfiltcoef_filter_par', 'niter', 'nmaxiter', 'print', 'plot', 'updateW'}, 2);
R_best = -1;
for i = 1:replicates
    [W,C,R] = find_leeseung(emg_normalized', rand(n_emg, n_synergies), rand(n_synergies, n_samples), n_synergies, nmf_options);
    if R(end) > R_best
        W_best = W;
        C_best = C;
        R_best = R(end);
    end
end

% Wmax = max(W_best, 1);
% Wn = W_best ./ repelem(Wmax, n_emg, 1); %Normalize W and C to maximum W
Wsum = sum(W_best, 1);
Wn = W_best ./ repelem(Wsum, n_emg, 1); %Normalize W and C to sum W
Cn = C_best .* repelem(Wsum', 1, n_samples);

if n_samples > n_points
    tempCmean = mean(reshape(Cn, n_synergies, n_points, []), 3); %  gait cycle averaging
else
    tempCmean = Cn;
end


[~,im] = max(tempCmean', [], 1);
[~,ix] = sort(im);
Cn(1:n_synergies, :) = Cn(ix(1:n_synergies), :); 
Wn(:, 1:n_synergies) = Wn(:, ix(1:n_synergies));

R2 = NaN(1, n_emg+1); %Variance accounted for (VAF)

emg_reconstr = W_best * C_best;
R2(1) = r_squared(emg_normalized, emg_reconstr'); %R_squared total

for i = 1:n_emg
    R2(i+1) = r_squared(emg_normalized(:, i), emg_reconstr(i, :)'); %R_squared for single muscles 
end

end
%%
function R2 = r_squared(M, Mhat)

y = reshape(M, 1, []);
yhat = reshape(Mhat, 1, []);

R2 = 1-sum((y-yhat).^2)/sum((y-nanmean(y)).^2);

end