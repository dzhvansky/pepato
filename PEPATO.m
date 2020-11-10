function pepato = PEPATO(FonSize, body_side, config_filepath, database_filepath, muscle_list)

if nargin < 5
    muscle_list = [];
end

[pepato_path, ~, ~] = fileparts(mfilename('fullpath'));

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
        q = questdlg(sprintf('For PEPATO to work correctly, please add "%s" and its subdirectories to your MATLAB path. \nThis needs to be done once, paths will be saved in .pepato file in the PEPATO home directory.\n\nAdd directory and save paths?', pepato_path), ...
            'PEPATO configuration', ...
            '<html><font size="4">Yes', '<html><font size="4">No', ...
            cell2struct({'none', 'modal', '<html><font size="4">Yes'}, {'Interpreter', 'WindowStyle', 'Default'}, 2));
        switch q
            case '<html><font size="4">Yes'
                cellfun(@(x) addpath(x), dir_list, 'un', 0);
                fileID = fopen(fullfile(pepato_path, '.pepato'), 'w');
                fprintf(fileID, '%s\n', dir_list{:});
                fclose(fileID);
                msgbox(sprintf('Path "%s" successfully added to MATLAB path. Paths saved to .pepato file\nWelcome to PEPATO!', pepato_path), 'INFO');
        end
    end
end

pepato = PepatoApp(FonSize, body_side, config_filepath, database_filepath, muscle_list);

end