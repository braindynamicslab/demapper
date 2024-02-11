function val = read_json(path)
fid = fopen(path);
raw = fread(fid,inf); 
str = char(raw');
fclose(fid); 
val = jsondecode(str);
end
