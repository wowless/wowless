rockspec_format = '3.0'
package = 'wowless'
version = 'scm-0'
source = {
  url = 'git://github.com/ferronn-dev/wowless',
}
dependencies = {
  'lua = 5.1',
  'argparse',
  'busted',
  'cluacov',
  'date',
  'http',
  'libdeflate',
  'luacheck',
  'luadbd',
  'luaexpat',
  'luamagick',
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
  install = {
    bin = { wowless = 'wowless.lua' },
  },
  modules = {
    ['wowapi.data'] = 'wowapi/data.lua',
    ['wowapi.loader'] = 'wowapi/loader.lua',
    ['wowapi.schema'] = 'wowapi/schema.lua',
    ['wowapi.uiobjects'] = 'wowapi/uiobjects.lua',
    ['wowapi.yaml'] = 'wowapi/yaml.lua',
    ['wowless.api'] = 'wowless/api.lua',
    ['wowless.env'] = 'wowless/env.lua',
    ['wowless.ext'] = 'wowless/ext.c',
    ['wowless.loader'] = 'wowless/loader.lua',
    ['wowless.runner'] = 'wowless/runner.lua',
    ['wowless.util'] = 'wowless/util.lua',
    ['wowless.xml'] = 'wowless/xml.lua',
  },
}
