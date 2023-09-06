local function readfile(filename)
  local f = assert(io.open(filename, 'r'))
  local content = assert(f:read('*a'))
  f:close()
  return content
end
local outfile = arg[1]
local main = arg[2]
local text = readfile(main):gsub('\\', '\\\\'):gsub('\n', '\\n\\\n'):gsub('"', '\\"')
local preloads = {}
for i = 3, #arg do
  table.insert(preloads, arg[i])
end
table.sort(preloads)
io.output(outfile)
io.write([[
#include <stdio.h>
#include <stdlib.h>
#include "lauxlib.h"
#include "lualib.h"
]])
for _, p in ipairs(preloads) do
  io.write('extern void preload_' .. p .. '(lua_State *);\n')
end
io.write([[
int main(int argc, char **argv) {
  lua_State *L = luaL_newstate();
  if (L == NULL) {
    return EXIT_FAILURE;
  }
  luaL_openlibsx(L, LUALIB_ELUNE);
  luaL_openlibsx(L, LUALIB_STANDARD);
]])
for _, p in ipairs(preloads) do
  io.write('  preload_' .. p .. '(L);\n')
end
io.write([[
  lua_getglobal(L, "package");
  lua_getfield(L, -1, "loaders");
  lua_createtable(L, 1, 0);
  lua_rawgeti(L, -2, 1);
  lua_rawseti(L, -2, -1);
  lua_setfield(L, -1, "loaders");
  lua_pop(L, 2);
  lua_newtable(L);
  for (int i = 0; i < argc; ++i) {
    lua_pushstring(L, argv[i]);
    lua_rawseti(L, -2, i);
  }
  lua_setglobal(L, "arg");
  if (luaL_dostring(L, "]] .. text .. [[") != 0) {
    puts(lua_tostring(L, -1));
  }
  lua_close(L);
  return EXIT_SUCCESS;
}
]])
