function pattern_similarity = get_pattern_similarity(pattern, reference)
% pattern = [1, n_points]
% reference = [N_clusters, n_points]

C = corrcoef([pattern', reference']);
pattern_similarity = C(1, 2:end);

end