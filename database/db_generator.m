function db_generator(source_dir, db_name, muscle_list, nmf_set)

pepato = PepatoAuto(10, 'left', 'cfg/init_cfg.mat', db_name, muscle_list);
drawnow;

files = dir(fullfile(source_dir, '*.mat'));
files = struct2cell(files);
files = cellfun(@(x) fullfile(source_dir, x), files(1, :), 'un', 0);

for file = files
    pepato.load_preprocessed(file{:});
    drawnow;
    
    for criteria = nmf_set
        pepato.data.config.nnmf_stop_criterion = criteria;
        pepato.analyze_data();
        drawnow;
        
        pepato.database.get_database_info();
        [subjects_, ~, conditions_] = get_trial_info(pepato.data.filenames);
        assert(length(unique(subjects_))==1)
        pepato.database.add_rows(subjects_{1}, conditions_);
        drawnow;
    end
end

end