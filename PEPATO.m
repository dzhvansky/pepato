function PEPATO(FonSize, body_side, config_filename, database_filename, muscle_list)
    if nargin < 5
        muscle_list = [];
    end
    
    pepato = PepatoApp(FonSize, body_side, config_filename, database_filename, muscle_list);
end