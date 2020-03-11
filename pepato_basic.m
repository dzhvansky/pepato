function pepato_basic(input_folder, output_folder, body_side, config_params, database_filename, muscle_list)
    output = PepatoBasic().init(input_folder, output_folder, body_side, config_params, database_filename, muscle_list).upload_data().pipeline().data.output_data;
end