function filename_list = get_filenames(file_list)

% returns filenames without extension
filename_list = cell(size(file_list));
for i = 1 : length(file_list)
	[~, fname, ~] = fileparts(file_list{i});
    filename_list{i} = fname;
end

end