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
  type = 'builtin',
  modules = {
    wowless = 'wowless.lua',
  },
  copy_directories = {
    'wowui',
  },
}
