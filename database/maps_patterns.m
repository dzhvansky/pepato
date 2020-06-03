function output = maps_patterns(database)
% the "database" parameter can be both a string (path to the PEPATO database) and a table

% load table if the "database" parameter is a path to the database
if isa(database, 'char')
    db_path = database;
    loaded = load(database);
    database = loaded.maps_database;
else
    db_path = [];
end

columns = database.Properties.VariableNames;

sacral_idx = find_cell_contains(columns, 'sacral_pat_');
lumbar_idx = find_cell_contains(columns, 'lumbar_pat_');

[~, unique_idx] = unique(database.('condition'));
conditions = database.('condition')(unique_idx)';
n_conditions = length(conditions);

struct_2_lvl = cell2struct(cell(1, 3), {'n_samples', 'mean_val', 'std_val'}, 2);

cell_1_lvl = cell(1, 2);
[cell_1_lvl{:}] = deal(struct_2_lvl);
struct_1_lvl = cell2struct(cell_1_lvl, {'sacral', 'lumbar'}, 2);

cell_output = cell(1, n_conditions);
[cell_output{:}] = deal(struct_1_lvl);
output = cell2struct(cell_output, conditions, 2);

for i = 1:n_conditions
    condition = conditions{i};
    row_idx = cell2mat(cellfun(@(x) strcmp(x, condition), database.('condition'), 'un', 0));
    sacral_ = database{row_idx, sacral_idx};
    lumbar_ = database{row_idx, lumbar_idx};
    output.(condition).('sacral').('n_samples') = sum(row_idx);
    output.(condition).('lumbar').('n_samples') = sum(row_idx);
    output.(condition).('sacral').('mean_val') = mean(sacral_, 1);
    output.(condition).('lumbar').('mean_val') = mean(lumbar_, 1);
    output.(condition).('sacral').('std_val') = std(sacral_, 1);
    output.(condition).('lumbar').('std_val') = std(lumbar_, 1);
end

% save output structure if the path is known
if isa(db_path, 'char')
    maps_patterns = output;
    save(db_path, 'maps_patterns', '-append');
end

end