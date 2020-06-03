function pepato = PEPATO(FonSize, body_side, config_filepath, database_filepath, muscle_list)

if nargin < 5
    muscle_list = [];
end

[pepato_path, ~, ~] = fileparts(mfilename('fullpath'));

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
    q = questdlg(sprintf('For PEPATO to work correctly, please add "%s" and its subdirectories to your MATLAB path and restart the application.\n\nThis needs to be done once.  Add directory to the path?', pepato_path), ...
        'PEPATO configuration', ...
        '<html><font size="4">Yes', '<html><font size="4">No', ...
        cell2struct({'none', 'modal', '<html><font size="4">Yes'}, {'Interpreter', 'WindowStyle', 'Default'}, 2));
    switch q
        case '<html><font size="4">Yes'
            cellfun(@(x) addpath(x), dir_list, 'un', 0);
            msgbox(sprintf('Path "%s" successfully added to MATLAB path\nWelcome to PEPATO! Please restart pipeline.', pepato_path), 'INFO');
    end
    pepato = [];
else
    pepato = PepatoApp(FonSize, body_side, config_filepath, database_filepath, muscle_list);
end

end