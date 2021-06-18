rockspec_format = '3.0'
package = 'wowless'
version = 'scm-0'
source = {
  url = 'git://github.com/ferronn-dev/wowless',
}
dependencies = {
  'lua = 5.1',
  'bitlib',
  'datafile',
  'lua-path',
  'xml2lua',
}
build = {
  type = 'none',
  install = {
    lua = {
      ['wowless.env'] = 'wowless/env.lua',
      ['wowless.loader'] = 'wowless/loader.lua',
      ['wowless.util'] = 'wowless/util.lua',
      ['wowless.xml'] = 'wowless/xml.lua',
    },
  },
  copy_directories = {
    'wowui',
  },
}
