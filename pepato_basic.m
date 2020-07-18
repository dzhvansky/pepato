function pepato_basic(input_folder, output_folder, body_side, config_params, database_path, muscle_list)

if nargin < 6
    muscle_list = [];
end

[pepato_path, ~, ~] = fileparts(mfilename('fullpath'));
pepato_path_ = pepato_path;
isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;
if isOctave
    % load packages
    for package_name = {'signal', 'statistics'}
        pkg('load', package_name{:});
    end
else
    insert = @(to_insert_, string_, n_)cat(2,  string_(1:n_), to_insert_, string_(n_+1:end));
    pepato_path_ = flip(pepato_path_);
    index = strfind(pepato_path_, '\');
    for idx = flip(index)
        pepato_path_ = insert('\', pepato_path_, idx);
    end
    pepato_path_ = flip(pepato_path_);
end


dir_list = {'config', 'data', 'database', 'features', 'logging', 'processing', 'utils', 'visualization'};
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
    try
        fileID = fopen(fullfile(pepato_path, '.pepato'), 'r');
        path_list = textscan(fileID, '%s', 'Delimiter', '\n');
        fclose(fileID);
        cellfun(@(x) addpath(x), path_list{1}', 'un', 0);
        
    catch
        q = input(sprintf('For PEPATO to work correctly, please add "%s" and its subdirectories to your MATLAB path and restart the application. \nThis needs to be done once, paths will be saved in .pepatopath file in the PEPATO home directory.\nAdd directory and save paths? [y/n] ', pepato_path_), 's');
        switch q
            case 'y'
                cellfun(@(x) addpath(x), dir_list, 'un', 0);
                fileID = fopen(fullfile(pepato_path, '.pepato'), 'w');
                fprintf(fileID, '%s\n', dir_list{:});
                fclose(fileID);
                fprintf('Path "%s" successfully added to MATLAB path. Paths saved to .pepatopath file.\nWelcome to PEPATO!\n', pepato_path);
        end
    end
end

pepato = PepatoBasic()...
    .init(input_folder, output_folder, body_side, config_params, database_path, muscle_list)...
    .pipeline({'speed2kmh', 'speed4kmh', 'speed6kmh'}, 4);

end