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
    ['build.data.flavors'] = 'build/data/flavors.lua',
    ['build.data.products'] = 'build/data/products.lua',
    ['build.data.stringenums'] = 'build/data/stringenums.lua',
    ['build.products.wow.data'] = 'build/products/wow/data.lua',
    ['build.products.wowt.data'] = 'build/products/wowt/data.lua',
    ['build.products.wowxptr.data'] = 'build/products/wowxptr/data.lua',
    ['build.products.wow_classic.data'] = 'build/products/wow_classic/data.lua',
    ['build.products.wow_classic_era.data'] = 'build/products/wow_classic_era/data.lua',
    ['build.products.wow_classic_era_ptr.data'] = 'build/products/wow_classic_era_ptr/data.lua',
    ['build.products.wow_classic_ptr.data'] = 'build/products/wow_classic_ptr/data.lua',
    ['wowapi.data'] = 'wowapi/data.lua',
    ['wowapi.loader'] = 'wowapi/loader.lua',
    ['wowapi.schema'] = 'wowapi/schema.lua',
    ['wowapi.uiobjects'] = 'wowapi/uiobjects.lua',
    ['wowapi.yaml'] = 'wowapi/yaml.lua',
    ['wowless.api'] = 'wowless/api.lua',
    ['wowless.blp'] = 'wowless/blp.lua',
    ['wowless.env'] = 'wowless/env.lua',
    ['wowless.hlist'] = 'wowless/hlist.lua',
    ['wowless.loader'] = 'wowless/loader.lua',
    ['wowless.png'] = 'wowless/png.lua',
    ['wowless.runner'] = 'wowless/runner.lua',
    ['wowless.typecheck'] = 'wowless/typecheck.lua',
    ['wowless.util'] = 'wowless/util.lua',
    ['wowless.xml'] = 'wowless/xml.lua',
  },
}
