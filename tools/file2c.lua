local function readfile(filename)
  local f = assert(io.open(filename, 'r'))
  local content = assert(f:read('*a'))
  f:close()
  return content
end
local package, file, output = arg[1], arg[2], arg[3]
local input = readfile(file)
io.output(output)
io.write('static const char code[] = {')
for i = 1, input:len() do
  if i % 12 == 1 then
    io.write('\n ')
  end
  io.write((' 0x%02x,'):format(input:byte(i)))
end
io.write([[

};
struct module {
  const char *name;
  const char *code;
  int size;
  const char *file;
};
]])
io.write(
  ('const struct module lua2c_%s = { "%s", code, %d, "@%s" };\n'):format(
    package:gsub('%.', '_'),
    package,
    input:len(),
    file
  )
)
