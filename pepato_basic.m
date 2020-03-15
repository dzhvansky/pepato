function pepato_basic(input_folder, output_folder, body_side, config_params, database_filename, muscle_list)
    pepato = PepatoBasic().init(input_folder, output_folder, body_side, config_params, database_filename, muscle_list).upload_data().pipeline().write_to_file();
    assignin('base', 'pep_basic', pepato);
end