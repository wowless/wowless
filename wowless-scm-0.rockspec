rockspec_format = '3.0'
package = 'wowless'
version = 'scm-0'
source = {
  url = 'git+https://github.com/ferronn-dev/wowless.git',
}
dependencies = {
  'lua = 5.1',
  'argparse',
  'busted',
  'cluacov',
  'date',
  'http',
  'libdeflate',
  'lsqlite3',
  'luacheck',
  'luadbd',
  'luaexpat < 1.5.0',
  'luamagick',
  'luasql-sqlite3',
  'lua-path',
  'lua-resty-tsort',
  'lyaml',
  'minheap',
  'penlight',
  'vstruct',
  'wowcig',
}
build = {
  type = 'builtin',
  modules = {
    ['wowless.ext'] = 'wowless/ext.c',
  },
}
