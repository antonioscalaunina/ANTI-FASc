function Struct=read_config_json(fid)
raw=fread(fid);
str=char(raw');
Struct=jsondecode(str);
end