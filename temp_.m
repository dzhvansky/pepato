
loaded = load('db/db_healthy_adults_8m.mat');
module_database = loaded.module_database;

% labels = {'GlMa', 'TeFa', 'BiFe', 'SeTe', 'VaMe', 'VaLa', 'ReFe', 'TiAn', 'GaMe', 'GaLa', 'Sol'}; %, 'PeLo'
colors = [
    0    0.4470    0.7410;
    0.8500    0.3250    0.0980;
    0.9290    0.6940    0.1250;
    0.4940    0.1840    0.5560;
    0.4660    0.6740    0.1880;
    0.3010    0.7450    0.9330;
    0.6350    0.0780    0.1840;
    0    0.4470    0.7410;
    0.8500    0.3250    0.0980;
    0.9290    0.6940    0.1250;
    0.4940    0.1840    0.5560;
    0.4660    0.6740    0.1880;
    0.3010    0.7450    0.9330;
    0.6350    0.0780    0.1840;
    0    0.4470    0.7410;
    0.8500    0.3250    0.0980;
    0.9290    0.6940    0.1250
    ];



columns = module_database.Properties.VariableNames;

idx_weights = find(not(cellfun('isempty', strfind(columns, '_weight'))));
idx_patterns = find(not(cellfun('isempty', regexp(columns, 'pattern_[\d]+'))));

muscle_list = cellfun (@(x) x(1:end-7), columns(idx_weights), 'un', 0);
weights = module_database{:, idx_weights}; 
patterns = module_database{:, idx_patterns};
norm_patterns = patterns ./ repmat(sum(patterns, 2), 1, size(patterns, 2));

n_muscles = size(weights, 2);
n_points = size(patterns, 2);


interp_patterns = interp1(norm_patterns', linspace(1, length(idx_patterns), length(idx_weights)))';


features = [weights, interp_patterns];
mean_ = mean(features, 1);
std_ = std(features, 1);
features_norm = (features - repmat(mean_, size(features, 1), 1)) ./ repmat(std_, size(features, 1), 1);

N_clusers = 4;
[cluster_idx, cluster_center_norm] = kmeans(features_norm, N_clusers, 'Replicates', 100);
cluster_center = cluster_center_norm .* repmat(std_, N_clusers, 1) + repmat(mean_, N_clusers, 1);


threshold = 0.8;
dist = sqrt(sum((features_norm - cluster_center_norm(cluster_idx, :)) .^ 2, 2) / size(features, 2));
disp(size(dist, 1));

mask = max(abs(features_norm - cluster_center_norm(cluster_idx, :)), [], 2) < 2;
mask = mask & (dist < threshold);

disp(size(dist(mask), 1));
disp(size(dist(~mask), 1));

cluster_idx(~mask) = 0;

pattern_mean = zeros(5, 200);
pattern_sd = zeros(5, 200);
for i = 1:N_clusers
    pattern_mean(i, :) = mean(norm_patterns((mask) & (cluster_idx == i), :), 1);
    pattern_sd(i, :) = std(norm_patterns((mask) & (cluster_idx == i), :), 1);
end

figure(42);clf;
for i = 1:N_clusers
    subplot(N_clusers, 2, 2*i-1);
    plot(linspace(1, 100, n_points), pattern_mean(i, :), 'Color', colors(i,:)); hold on;
    fill([linspace(1, 100, n_points) fliplr(linspace(1, 100, n_points))], ...
        [max(pattern_mean(i, :) - pattern_sd(i, :), zeros(1, n_points)) fliplr(pattern_mean(i, :) + pattern_sd(i, :))], ...
        colors(i, :), 'EdgeColor', 'None', 'FaceAlpha', .2);
    set(gca, 'XTick', 0:20:100); 
    set(gca, 'XTickLabel', 0:20:100);
    xlim([1 100]);
    ylim([0 n_muscles/n_points]);
    
    subplot(N_clusers, 2, 2*i);
    bar(1:n_muscles, cluster_center(i, 1:n_muscles), 'FaceColor', colors(i,:)); hold on;
    set(gca, 'XTick', 1:n_muscles);
    set(gca, 'XTickLabel', muscle_list);
    set(gca, 'XTickLabelRotation', 90);
    ylim([0 1]);
end


inout = {'out', 'IN'};
idx_start = 1; idx_end = 6;
K = idx_end - idx_start + 1;
figure(43); clf;
for i = idx_start:idx_end
    plot_idx = i - idx_start + 1;
    
    subplot(K, 2, 2*plot_idx-1);
    plot(linspace(1, 100, n_points), norm_patterns(i, :), 'Color', colors(plot_idx, :)); hold on;
    set(gca, 'XTick', 0:20:100); 
    set(gca, 'XTickLabel', 0:20:100);
    xlim([1 100]);
    ylim([0 n_muscles/n_points]);
    ylabel(sprintf('%d clust: %s\n%s', cluster_idx(i), num2str(round(dist(i), 2)), inout{mask(i)+1}))
    
    subplot(K, 2, 2*plot_idx);
    bar(1:n_muscles, weights(i, 1:n_muscles), 'FaceColor', colors(plot_idx, :)); hold on;
    set(gca, 'XTick', 1:n_muscles);
    set(gca, 'XTickLabel', muscle_list);
    set(gca, 'XTickLabelRotation', 90);
    ylim([0 1]);
end


figure(45);clf;
% Y_cos = tsne(features, 'Algorithm', 'exact', 'Distance', 'cosine');
% gscatter(Y_cos(:,1), Y_cos(:,2), cluster_idx);

Y_cos = tsne([cluster_center; features],'Algorithm','exact','Distance','cosine');
gscatter(Y_cos(N_clusers+1:end, 1), Y_cos(N_clusers+1:end, 2), cluster_idx); hold on;
plot(Y_cos(1:N_clusers, 1), Y_cos(1:N_clusers, 2), 'kx');


figure(46);clf;
% Y_cos = tsne(features, 'Algorithm', 'exact', 'Distance', 'cosine');
% gscatter(Y_cos(:,1), Y_cos(:,2), cluster_idx);

Y_cos = tsne([cluster_center; features],'Algorithm','exact','Distance','cosine');
gscatter(Y_cos(N_clusers+1:end, 1), Y_cos(N_clusers+1:end, 2), ...
    cellfun(@(x) add_backslash(x, '_'), module_database{:, 'condition'}, 'un', 0)); hold on;
plot(Y_cos(1:N_clusers, 1), Y_cos(1:N_clusers, 2), 'kx');

