function synergy_similarity = get_synergy_similarity(muscle_weightings, reference)
% muscle_weightings = [1, n_muscles]
% reference = [N_clusters, n_muscles]
N_clusters = size(reference, 1);

synergy_similarity = zeros(1, N_clusters);
for i = 1 : N_clusters
    synergy_similarity(i) = dot(muscle_weightings, reference(i, :)) / (norm(muscle_weightings) * norm(reference(i, :)));
end 

end