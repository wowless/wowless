local outfile = arg[1]
local preloads = {}
for i = 2, #arg do
  table.insert(preloads, arg[i])
end
table.sort(preloads)
io.output(outfile)
io.write('#include "tools/luamain.h"\n')
io.write('extern const struct module lua2c_main;\n')
if next(preloads) then
  for _, p in ipairs(preloads) do
    io.write('extern const struct preload preload_' .. p .. ';\n')
  end
  io.write('static const struct preload *preloads[] = {\n')
  for _, p in ipairs(preloads) do
    io.write('  &preload_' .. p .. ',\n')
  end
  io.write('};\n')
end
io.write('const struct luamain luamain = {\n')
io.write('  .module = &lua2c_main,\n')
io.write(('  .preloads = %s,\n'):format(next(preloads) and 'preloads' or '0'))
io.write(('  .npreloads = %s,\n'):format(#preloads))
io.write('};\n')
