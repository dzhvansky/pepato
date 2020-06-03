function string = add_backslash(string, char_to_exlude)

insert = @(to_insert_, string_, n_)cat(2,  string_(1:n_), to_insert_, string_(n_+1:end));

string = flip(string);

index = strfind(string, char_to_exlude);
for idx = flip(index)
    string = insert('\', string, idx);
end

string = flip(string);

end