function random_string = rand_string_gen(n_chars, char_list)

if nargin < 2
    char_list = ['a':'z' 'A':'Z' '0':'9'];
end

random_string = char_list(randi(numel(char_list),[1 n_chars]));

end