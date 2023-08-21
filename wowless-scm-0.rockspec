rockspec_format = '3.0'
package = 'wowless'
version = 'scm-0'
source = {
  url = 'git+https://github.com/wowless/wowless.git',
}
build_dependencies = {
  'lsqlite3',
  'lua-cjson',
  'luacheck',
  'luadbd',
  'luaexpat < 1.5.0',
  'luamagick',
  'luasql-sqlite3',
  'wowcig',
}
dependencies = {
  'argparse',
  'date',
  'luassert',
  'lua-path',
  'lua-resty-tsort',
  'lyaml',
  'minheap',
  'penlight',
  'vstruct',
}
build = {
  type = 'builtin',
  modules = {},
}
