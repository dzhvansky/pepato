function [features, norm_patterns, scaler_mean, scaler_std] = get_cluster_features(weights, patterns, scaler_mean, scaler_std)
% prepare and normalize features for k-means

n_muscles = size(weights, 2);
n_points = size(patterns, 2);
n_rows = size(weights, 1);

% normalize and interpolate patterns
norm_patterns = patterns ./ repmat(sum(patterns, 2), 1, size(patterns, 2));
interp_patterns = interp1(norm_patterns', linspace(1, n_points, n_muscles))';

features = [weights, interp_patterns];

if nargin == 2
    scaler_mean = mean(features, 1);
    scaler_std = std(features, 1);
end

features = (features - repmat(scaler_mean, n_rows, 1)) ./ repmat(scaler_std, n_rows, 1);

end