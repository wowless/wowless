local function readfile(filename)
  local f = assert(io.open(filename, 'r'))
  local content = assert(f:read('*a'))
  f:close()
  return content
end
local outfile = arg[1]
local main = arg[2]
local text = readfile(main)
local etext = text:gsub('\\', '\\\\'):gsub('\n', '\\n\\\n'):gsub('"', '\\"')
local preloads = {}
local strict = arg[3] == '-strict'
for i = strict and 4 or 3, #arg do
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
static int errhandler(lua_State *L) {
  const char *msg = lua_tostring(L, 1);
  luaL_traceback(L, L, msg, 1);
  return 1;
}
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
]])
io.write(strict and '' or [[
  lua_pushstring(L, "./?.lua");
  lua_setfield(L, -2, "path");
]])
io.write([[
  lua_getfield(L, -1, "loaders");
]])
io.write(strict and [[
  lua_createtable(L, 1, 0);
  lua_rawgeti(L, -2, 1);
  lua_rawseti(L, -2, -1);
]] or [[
  lua_createtable(L, 2, 0);
  lua_rawgeti(L, -2, 1);
  lua_rawseti(L, -2, -1);
  lua_rawgeti(L, -2, 2);
  lua_rawseti(L, -2, -1);
]])
io.write([[
  lua_setfield(L, -1, "loaders");
  lua_pop(L, 2);
  lua_newtable(L);
  for (int i = 0; i < argc; ++i) {
    lua_pushstring(L, argv[i]);
    lua_rawseti(L, -2, i);
  }
  lua_setglobal(L, "arg");
  lua_pushcfunction(L, errhandler);
]])
io.write(('  int ret = luaL_loadbuffer(L, "%s", %d, "@%s");\n'):format(etext, text:len(), main))
io.write([[
  if (ret || lua_pcall(L, 0, LUA_MULTRET, -2)) {
    fprintf(stderr, "%s\n", lua_tostring(L, -1));
]])
io.write(strict and [[
    return EXIT_FAILURE;
]] or '')
io.write([[
  }
  lua_close(L);
  return EXIT_SUCCESS;
}
]])
