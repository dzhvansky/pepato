load('synergy_database.mat')

labels = {'GlMa', 'TeFa', 'BiFe', 'SeTe', 'VaMe', 'VaLa', 'ReFe', 'TiAn', 'GaMe', 'GaLa', 'Sol'}; %, 'PeLo'
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

weights = database{:, strcat(labels, '_weight')}; 
patterns = database{:, strcat({'pattern_'}, strsplit(num2str(1:200)))};
interp_patterns = interp1(patterns', linspace(1, 200, 12))';

features = [weights, interp_patterns];
mean_ = mean(features, 1);
std_ = std(features, 1);
features_norm = (features - repmat(mean_, size(features, 1), 1)) ./ repmat(std_, size(features, 1), 1);

N = 4;
[idx, c_norm] = kmeans(features_norm, N, 'Replicates', 100);
C = c_norm .* repmat(std_, N, 1) + repmat(mean_, N, 1);


dist = sqrt(sum((features_norm - c_norm(idx, :)) .^ 2, 2) / 23);
% 639
size(dist(dist < 0.8)); %521
size(dist(dist >= 0.8)); %118

pattern_mean = zeros(5, 200);
pattern_sd = zeros(5, 200);
for i = 1:N
    pattern_mean(i, :) = mean(patterns((dist < 0.8) & (idx == i), :), 1);
    pattern_sd(i, :) = std(patterns((dist < 0.8) & (idx == i), :), 1);
end

figure(42);clf;
for i = 1:N
    subplot(N, 2, 2*i-1);
    plot(linspace(1, 100, 200), pattern_mean(i, :), 'Color', colors(i,:)); hold on;
    fill([linspace(1, 100, 200) fliplr(linspace(1, 100, 200))], ...
        [max(pattern_mean(i, :) - pattern_sd(i, :), zeros(1, 200)) fliplr(pattern_mean(i, :) + pattern_sd(i, :))], ...
        colors(i, :), 'EdgeColor', 'None', 'FaceAlpha', .2);
    subplot(N, 2, 2*i);
    bar(1:11, C(i, 1:11), 'FaceColor', colors(i,:)); hold on;
    set(gca, 'XTick', 1:11);
    set(gca, 'XTickLabel', labels);
    set(gca, 'XTickLabelRotation', 90);
end


K = 10;
figure(43);clf;
for i = 1:K
    subplot(K, 2, 2*i-1);
    plot(linspace(1, 100, 12), features(i, 12:end), 'Color', colors(i,:)); hold on;
    subplot(K, 2, 2*i);
    bar(1:11, features(i, 1:11), 'FaceColor', colors(i,:)); hold on;
    set(gca, 'XTick', 1:11);
    set(gca, 'XTickLabel', labels);
    set(gca, 'XTickLabelRotation', 90);
end


figure(45);clf;
% Y_cos = tsne(features, 'Algorithm', 'exact', 'Distance', 'cosine');
% gscatter(Y_cos(:,1), Y_cos(:,2), idx);

Y_cos = tsne([C; features],'Algorithm','exact','Distance','cosine');
gscatter(Y_cos(N:end, 1), Y_cos(N:end, 2), idx); hold on;
plot(Y_cos(1:N, 1), Y_cos(1:N, 2), 'kx');


