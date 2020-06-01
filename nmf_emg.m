function [Wn, Cn, R2] = nmf_emg(emg_normalized, n_synergies, n_points, replicates)
n_emg = size(emg_normalized, 2);

if nargin < 3
    n_points = 200; replicates = 10;
elseif nargin < 4
    replicates = 10;
end

% nmf_options = statset('MaxIter',1000,'TolFun',1e-5,'TolX',1e-5); %Nonnegative Matrix Factorization Options
% [W,C,~] = nnmf(emg_normalized', n_synergies, 'replicates', replicates, 'options', nmf_options, 'algorithm', 'mult'); %W = weights, C = coefficients, D = residue
% [W,C,~] = nnmf(emg_normalized', n_synergies);
nmf_options = cell2struct({[], [], 100, 1000, false, false, true}, {'isynfiltcoef', 'synfiltcoef_filter_par', 'niter', 'nmaxiter', 'print', 'plot', 'updateW'}, 2);
[W,C,~] = find_leeseung(emg_normalized', rand(size(emg_normalized, 2), n_synergies), rand(n_synergies, size(emg_normalized, 1)), n_synergies, nmf_options);

% Wmax = max(W, 1);
% Wn = W ./ repelem(Wmax, size(W,1), 1); %Normalize W and C to maximum W
Wsum = sum(W, 1);
Wn = W ./ repelem(Wsum, size(W,1), 1); %Normalize W and C to maximum W
Cn = C .* repelem(Wsum', 1, size(C,2));

if size(Cn, 2) > n_points
    tempCmean = mean(reshape(Cn, size(Cn, 1), n_points, []), 3); %  gait cycle averaging
else
    tempCmean = Cn;
end


[~,im] = max(tempCmean', [], 1);
[~,ix] = sort(im);
Cn(1:n_synergies, :) = Cn(ix(1:n_synergies), :); 
Wn(:, 1:n_synergies) = Wn(:, ix(1:n_synergies));

R2 = NaN(1, n_emg+1); %Variance accounted for (VAF)

emg_reconstr = W * C;
R2(1) = r_squared(emg_normalized, emg_reconstr'); %R_squared total

for i = 1:n_emg
    R2(i+1) = r_squared(emg_normalized(:, i), emg_reconstr(i, :)'); %R_squared for single muscles 
end

end