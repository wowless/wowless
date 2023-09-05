rockspec_format = '3.0'
package = 'wowless'
version = 'scm-0'
source = {
  url = 'git+https://github.com/wowless/wowless.git',
}
build_dependencies = {
  'lsqlite3',
  'lua-cjson',
  'lua-path',
  'luacasc >= 1.15',
  'luacheck',
  'luadbc',
  'luadbd',
  'luaexpat < 1.5.0',
  'luamagick',
  'luasql-sqlite3',
  'lyaml',
  'penlight',
  'vstruct',
}
dependencies = {}
build = {
  type = 'builtin',
  modules = {
    ['wowapi.data'] = 'wowapi/data.lua',
    ['wowapi.schema'] = 'wowapi/schema.lua',
    ['wowapi.yaml'] = 'wowapi/yaml.lua',
    ['wowless.api'] = 'wowless/api.lua',
    ['wowless.blp'] = 'wowless/blp.lua',
    ['wowless.hlist'] = 'wowless/hlist.lua',
    ['wowless.png'] = 'wowless/png.lua',
    ['wowless.typecheck'] = 'wowless/typecheck.lua',
    ['wowless.util'] = 'wowless/util.lua',
  },
}
