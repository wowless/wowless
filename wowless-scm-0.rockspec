rockspec_format = '3.0'
package = 'wowless'
version = 'scm-0'
source = {
  url = 'git+https://github.com/wowless/wowless.git',
}
build_dependencies = {
  'lsqlite3',
  'lua-path',
  'luacasc >= 1.15',
  'luacheck',
  'luadbc',
  'luaexpat < 1.5.0',
  'luamagick',
  'lyaml',
  'penlight',
  'vstruct',
}
dependencies = {}
build = {
  type = 'builtin',
  modules = {},
}
