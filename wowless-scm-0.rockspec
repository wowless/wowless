rockspec_format = '3.0'
package = 'wowless'
version = 'scm-0'
source = {
  url = 'git+https://github.com/wowless/wowless.git',
}
build_dependencies = {
  'lsqlite3',
  'luacheck',
  'luadbd',
  'luaexpat < 1.5.0',
  'luamagick',
  'luasql-sqlite3',
  'lua-resty-tsort',
  'wowcig',
}
dependencies = {
  'argparse',
  'luassert',
  'date',
  'lua-path',
  'lyaml',
  'minheap',
  'penlight',
  'vstruct',
}
build = {
  type = 'builtin',
  modules = {},
}
