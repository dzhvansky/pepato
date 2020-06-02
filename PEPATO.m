function pepato = PEPATO(FonSize, body_side, config_filepath, database_filepath, muscle_list)
    if nargin < 5
        muscle_list = [];
    end
    
    pepato = PepatoApp(FonSize, body_side, config_filepath, database_filepath, muscle_list);
end