function pepato_basic(input_folder, output_folder, body_side, config_params, database_path, muscle_list)

[pepato_path, ~, ~] = fileparts(mfilename('fullpath'));
pepato_path_ = pepato_path;
isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;
if ~isOctave
    insert = @(to_insert_, string_, n_)cat(2,  string_(1:n_), to_insert_, string_(n_+1:end));
    pepato_path_ = flip(pepato_path_);
    index = strfind(pepato_path_, '\');
    for idx = flip(index)
        pepato_path_ = insert('\', pepato_path_, idx);
    end
    pepato_path_ = flip(pepato_path_);
end


dir_list = {'config', 'data', 'database', 'features', 'logging', 'processing', 'utils', 'visualization', fullfile('utils','cells'), fullfile('utils','math')};
dir_list = cellfun(@(x) fullfile(pepato_path, x), dir_list, 'un', 0);
dir_list = [dir_list, pepato_path];

pathCell = regexp(path, pathsep, 'split');
if ispc  % Windows is not case-sensitive
  onPath = cellfun(@(x) strcmpi(x, pathCell), dir_list, 'un', 0);
else
  onPath = cellfun(@(x) strcmp(x, pathCell), dir_list, 'un', 0);
end
onPath = sum(cell2mat(onPath'), 2);
addpath_flag = sum(onPath) < length(onPath);


if addpath_flag
    q = input(sprintf('For PEPATO to work correctly, please add "%s" and its subdirectories to your MATLAB path and restart the application.\nThis needs to be done once. Add directory to the path? [y/n] ', pepato_path_), 's');
    switch q
        case 'y'
            cellfun(@(x) addpath(x), dir_list, 'un', 0);
            fprintf('Path "%s" successfully added to MATLAB path\nWelcome to PEPATO! Please restart pipeline.\n', pepato_path);
    end
    pepato = [];
else
    pepato = PepatoBasic()...
        .init(input_folder, output_folder, body_side, config_params, database_path, muscle_list)...
        .upload_data()...
        .pipeline(4, muscle_list)...
        .write_to_file();
end

end